#!/usr/bin/env python3
"""
openclaw_compaction_diagnostics.py (v3.1)

Parses OpenClaw session JSONL transcripts and produces a compaction health
report. Answers the question: "Is your compaction config working?"

Privacy: This tool reads local session logs which may contain sensitive
content. All analysis runs locally on your machine. No data is transmitted.

Reports:
  - Total compaction events per session
  - Flush success rate (did the agent write to memory before compaction?)
  - Memory write verification (did files on disk actually get updated?)
  - Recovery assessment (did the agent re-read state files after compaction?)
  - Token usage trends (are sessions consistently hitting limits?)
  - Actionable recommendations

Usage:
  # Scan all sessions for the main agent
  python3 openclaw_compaction_diagnostics.py report

  # Scan a specific session transcript
  python3 openclaw_compaction_diagnostics.py report --session PATH_TO_JSONL

  # Scan sessions from the last N days
  python3 openclaw_compaction_diagnostics.py report --days 7

  # JSON output (for telemetry ingestion)
  python3 openclaw_compaction_diagnostics.py report --json

  # Quick summary (one-liner)
  python3 openclaw_compaction_diagnostics.py summary
"""

import argparse
import json
import os
import sys
import glob
import re
from datetime import datetime, timedelta, timezone
from pathlib import Path
from collections import defaultdict


# ── Defaults ─────────────────────────────────────────────────────────

DEFAULT_SESSIONS_DIR = os.path.expanduser("~/.openclaw/agents/main/sessions")
DEFAULT_WORKSPACE = os.path.expanduser("~/.openclaw/workspace")


# ── JSONL Parsing ────────────────────────────────────────────────────

def parse_jsonl(filepath):
    """Parse a JSONL session transcript. Yields (line_number, entry) tuples."""
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        for i, line in enumerate(f):
            line = line.strip()
            if not line:
                continue
            try:
                yield (i, json.loads(line))
            except json.JSONDecodeError:
                continue


def find_session_files(sessions_dir, days=None):
    """Find .jsonl session files, optionally filtered by modification time."""
    pattern = os.path.join(sessions_dir, "*.jsonl")
    files = glob.glob(pattern)
    if days is not None:
        cutoff = datetime.now().timestamp() - (days * 86400)
        files = [f for f in files if os.path.getmtime(f) >= cutoff]
    return sorted(files, key=os.path.getmtime, reverse=True)


# ── Analysis Engine ──────────────────────────────────────────────────

class CompactionEvent:
    """Represents a single compaction event extracted from a transcript."""
    def __init__(self, line_num, entry, timestamp=None):
        self.line_num = line_num
        self.entry = entry
        self.timestamp = timestamp
        self.pre_flush_detected = False
        self.memory_writes_before = []      # tool calls writing memory before compaction
        self.state_writes_before = []       # tool calls writing GLOBAL-STATE before compaction
        self.state_reads_after = []         # tool calls reading state after compaction
        self.memory_reads_after = []        # tool calls reading memory after compaction
        self.memory_search_after = False    # memory_search used after compaction
        self.recovery_announced = False     # agent told user what it recovered
        self.tokens_before = None
        self.tokens_after = None
        self.summary_available = False


def analyze_session(filepath, workspace=None):
    """
    Analyze a single session transcript for compaction health.

    Returns a dict with:
      - session_file: filename
      - compaction_events: list of CompactionEvent analysis results
      - total_compactions: int
      - flush_successes: int
      - flush_failures: int
      - recovery_successes: int
      - recovery_failures: int
      - peak_tokens: highest token count seen
      - recommendations: list of strings
    """
    entries = list(parse_jsonl(filepath))
    if not entries:
        return None

    compaction_indices = []
    for idx, (line_num, entry) in enumerate(entries):
        # Detect compaction entries
        entry_type = entry.get("type", "")
        # Compaction entries appear as type: "compaction" in the transcript
        if entry_type == "compaction":
            compaction_indices.append(idx)
            continue
        # Also detect via summary field (some versions)
        if "summary" in entry and "compaction" in str(entry.get("type", "")):
            compaction_indices.append(idx)
            continue
        # Detect compaction log messages
        if isinstance(entry.get("message"), str):
            msg = entry["message"]
            if "compaction" in msg.lower() and ("summary" in msg.lower() or "truncated" in msg.lower()):
                compaction_indices.append(idx)

    if not compaction_indices:
        return {
            "session_file": os.path.basename(filepath),
            "compaction_events": [],
            "total_compactions": 0,
            "flush_successes": 0,
            "flush_failures": 0,
            "recovery_successes": 0,
            "recovery_failures": 0,
            "peak_tokens": _find_peak_tokens(entries),
            "recommendations": [],
        }

    events = []
    for ci in compaction_indices:
        line_num, entry = entries[ci]
        ce = CompactionEvent(line_num, entry)

        # Extract token info from the compaction entry
        if isinstance(entry.get("summary"), str) and "token" in entry.get("summary", ""):
            ce.summary_available = True
        if "deletedCount" in entry:
            ce.summary_available = True

        # ── Look backwards for pre-compaction flush and memory writes ──
        lookback_window = min(ci, 30)  # Look at up to 30 entries before compaction
        for bi in range(ci - 1, ci - lookback_window - 1, -1):
            if bi < 0:
                break
            _, b_entry = entries[bi]

            # Detect NO_REPLY (silent flush turn)
            content = _extract_text_content(b_entry)
            if "NO_REPLY" in content or "no_reply" in content:
                ce.pre_flush_detected = True

            # Detect memory file writes (tool calls)
            tool_name, tool_args = _extract_tool_call(b_entry)
            if tool_name in ("write", "edit", "apply_patch"):
                path_arg = tool_args.get("path", "") or tool_args.get("file", "") or ""
                if "memory/" in path_arg or "MEMORY.md" in path_arg:
                    ce.memory_writes_before.append(path_arg)
                if "GLOBAL-STATE" in path_arg:
                    ce.state_writes_before.append(path_arg)

            # Detect pre-compaction flush system prompt
            if "nearing compaction" in content.lower() or "store durable" in content.lower():
                ce.pre_flush_detected = True

        # ── Look forwards for post-compaction recovery ──
        lookforward_window = min(len(entries) - ci - 1, 40)
        for fi in range(ci + 1, ci + lookforward_window + 1):
            if fi >= len(entries):
                break
            _, f_entry = entries[fi]

            # Detect state/memory reads after compaction
            tool_name, tool_args = _extract_tool_call(f_entry)
            if tool_name in ("read",):
                path_arg = tool_args.get("path", "") or tool_args.get("file", "") or ""
                if "GLOBAL-STATE" in path_arg:
                    ce.state_reads_after.append(path_arg)
                if "memory/" in path_arg or "MEMORY.md" in path_arg:
                    ce.memory_reads_after.append(path_arg)

            # Detect memory_search usage
            if tool_name in ("memory_search", "memory_get"):
                ce.memory_search_after = True

            # Detect recovery announcement
            content = _extract_text_content(f_entry)
            recovery_phrases = [
                "picking up", "where we left off", "recovered", "recovering",
                "resuming", "continuing from", "last state", "working on",
            ]
            if any(phrase in content.lower() for phrase in recovery_phrases):
                ce.recovery_announced = True

            # Stop looking if we hit another compaction
            if f_entry.get("type") == "compaction":
                break

        events.append(ce)

    # ── Compute metrics ──
    flush_successes = sum(
        1 for e in events
        if e.pre_flush_detected or e.memory_writes_before or e.state_writes_before
    )
    flush_failures = len(events) - flush_successes

    recovery_successes = sum(
        1 for e in events
        if e.state_reads_after or e.memory_reads_after or e.memory_search_after
    )
    recovery_failures = len(events) - recovery_successes

    # ── Generate recommendations ──
    recommendations = _generate_recommendations(
        events, flush_successes, flush_failures,
        recovery_successes, recovery_failures, workspace
    )

    return {
        "session_file": os.path.basename(filepath),
        "compaction_events": events,
        "total_compactions": len(events),
        "flush_successes": flush_successes,
        "flush_failures": flush_failures,
        "recovery_successes": recovery_successes,
        "recovery_failures": recovery_failures,
        "peak_tokens": _find_peak_tokens(entries),
        "recommendations": recommendations,
    }


def _extract_text_content(entry):
    """Extract readable text from a transcript entry."""
    # Direct message content
    if isinstance(entry.get("content"), str):
        return entry["content"]
    # Array content (Anthropic format)
    if isinstance(entry.get("content"), list):
        texts = []
        for block in entry["content"]:
            if isinstance(block, dict) and block.get("type") == "text":
                texts.append(block.get("text", ""))
        return " ".join(texts)
    # Message wrapper
    if isinstance(entry.get("message"), dict):
        return _extract_text_content(entry["message"])
    if isinstance(entry.get("message"), str):
        return entry["message"]
    # Summary field (compaction entries)
    if isinstance(entry.get("summary"), str):
        return entry["summary"]
    return ""


def _extract_tool_call(entry):
    """Extract tool name and args from a transcript entry."""
    # Direct tool_use block
    if entry.get("type") == "tool_use":
        return entry.get("name", ""), entry.get("input", {})
    # Nested in content array
    if isinstance(entry.get("content"), list):
        for block in entry["content"]:
            if isinstance(block, dict) and block.get("type") == "tool_use":
                return block.get("name", ""), block.get("input", {})
    # Tool result
    if entry.get("type") == "tool_result":
        return entry.get("tool_name", ""), {}
    return "", {}


def _find_peak_tokens(entries):
    """Find the highest token count in a session."""
    peak = 0
    for _, entry in entries:
        for key in ("totalTokens", "contextTokens", "inputTokens"):
            val = entry.get(key)
            if isinstance(val, (int, float)) and val > peak:
                peak = int(val)
        # Check nested usage
        usage = entry.get("usage", {})
        if isinstance(usage, dict):
            for key in ("input_tokens", "output_tokens"):
                val = usage.get(key, 0)
                if isinstance(val, (int, float)) and val > peak:
                    peak = int(val)
    return peak


def _generate_recommendations(events, flush_ok, flush_fail, recov_ok, recov_fail, workspace):
    """Generate actionable recommendations based on analysis."""
    recs = []

    if not events:
        return recs

    total = len(events)

    # Flush health
    if flush_fail > 0 and flush_fail / total > 0.3:
        recs.append(
            f"FLUSH: {flush_fail}/{total} compactions had no detectable pre-flush. "
            f"Check: (1) memoryFlush.enabled is true in openclaw.json, "
            f"(2) workspace is writable (not sandboxed with ro), "
            f"(3) softThresholdTokens is high enough to trigger before compaction."
        )

    if flush_ok == total:
        recs.append(f"FLUSH: All {total} compactions had pre-flush activity. Config is working.")

    # Recovery health
    if recov_fail > 0 and recov_fail / total > 0.3:
        recs.append(
            f"RECOVERY: {recov_fail}/{total} compactions had no post-recovery reads. "
            f"The agent may not be following the recovery protocol in AGENTS.md. "
            f"Check that AGENTS.md includes the post-compaction recovery section."
        )

    if recov_ok == total and total > 0:
        recs.append(f"RECOVERY: Agent read state files after all {total} compactions. Recovery protocol is working.")

    # Memory search usage
    search_used = sum(1 for e in events if e.memory_search_after)
    if search_used == 0 and total > 1:
        recs.append(
            "MEMORY SEARCH: Agent never used memory_search after compaction. "
            "Enable memorySearch in openclaw.json for better cross-session recall."
        )

    # GLOBAL-STATE writes
    state_writes = sum(1 for e in events if e.state_writes_before)
    if state_writes == 0 and total > 1:
        recs.append(
            "STATE: GLOBAL-STATE.yaml was never written before compaction. "
            "The flush prompt should instruct the agent to update GLOBAL-STATE.yaml. "
            "Check the memoryFlush.prompt in openclaw.json."
        )

    # Check workspace for GLOBAL-STATE.yaml freshness
    if workspace:
        gs_path = os.path.join(workspace, "GLOBAL-STATE.yaml")
        if os.path.exists(gs_path):
            gs_age = datetime.now().timestamp() - os.path.getmtime(gs_path)
            if gs_age > 86400:  # Stale for more than a day
                days_stale = int(gs_age / 86400)
                recs.append(
                    f"STATE: GLOBAL-STATE.yaml was last modified {days_stale} day(s) ago. "
                    f"If the agent has been active, it may not be maintaining canonical state."
                )
        else:
            recs.append("STATE: GLOBAL-STATE.yaml not found in workspace. Compaction firewall is missing.")

    return recs


# ── Report Formatting ────────────────────────────────────────────────

def format_report(results, output_json=False):
    """Format analysis results as human-readable report or JSON."""
    if output_json:
        serializable = []
        for r in results:
            s = dict(r)
            s["compaction_events"] = [
                {
                    "line": e.line_num,
                    "pre_flush": e.pre_flush_detected,
                    "memory_writes_before": len(e.memory_writes_before),
                    "state_writes_before": len(e.state_writes_before),
                    "state_reads_after": len(e.state_reads_after),
                    "memory_reads_after": len(e.memory_reads_after),
                    "memory_search_after": e.memory_search_after,
                    "recovery_announced": e.recovery_announced,
                }
                for e in s["compaction_events"]
            ]
            serializable.append(s)
        return json.dumps(serializable, indent=2)

    lines = []
    lines.append("=" * 64)
    lines.append("  COMPACTION HEALTH REPORT")
    lines.append("  OpenClaw Cognitive Upgrade Kit")
    lines.append(f"  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 64)

    total_compactions = sum(r["total_compactions"] for r in results)
    total_flush_ok = sum(r["flush_successes"] for r in results)
    total_flush_fail = sum(r["flush_failures"] for r in results)
    total_recov_ok = sum(r["recovery_successes"] for r in results)
    total_recov_fail = sum(r["recovery_failures"] for r in results)

    lines.append("")
    lines.append(f"  Sessions analyzed:      {len(results)}")
    lines.append(f"  Total compactions:      {total_compactions}")
    if total_compactions > 0:
        flush_rate = (total_flush_ok / total_compactions) * 100
        recov_rate = (total_recov_ok / total_compactions) * 100
        lines.append(f"  Flush success rate:     {total_flush_ok}/{total_compactions} ({flush_rate:.0f}%)")
        lines.append(f"  Recovery success rate:  {total_recov_ok}/{total_compactions} ({recov_rate:.0f}%)")
    else:
        lines.append("  No compaction events found. Sessions stayed within context limits.")

    lines.append("")

    # Per-session detail
    for r in results:
        if r["total_compactions"] == 0:
            continue
        lines.append(f"  --- {r['session_file']} ---")
        lines.append(f"  Compactions: {r['total_compactions']}  |  "
                      f"Flush OK: {r['flush_successes']}  |  "
                      f"Recovery OK: {r['recovery_successes']}  |  "
                      f"Peak tokens: {r['peak_tokens']:,}")

        for i, e in enumerate(r["compaction_events"]):
            status_parts = []
            if e.pre_flush_detected or e.memory_writes_before:
                status_parts.append("flush:YES")
            else:
                status_parts.append("flush:NO")
            if e.state_writes_before:
                status_parts.append("state-saved:YES")
            if e.state_reads_after or e.memory_reads_after:
                status_parts.append("recovery:YES")
            else:
                status_parts.append("recovery:NO")
            if e.memory_search_after:
                status_parts.append("mem-search:YES")
            if e.recovery_announced:
                status_parts.append("announced:YES")
            lines.append(f"    event {i+1}: {' | '.join(status_parts)}")

        lines.append("")

    # Recommendations
    all_recs = []
    for r in results:
        all_recs.extend(r["recommendations"])
    # Deduplicate
    seen = set()
    unique_recs = []
    for rec in all_recs:
        key = rec[:50]
        if key not in seen:
            seen.add(key)
            unique_recs.append(rec)

    if unique_recs:
        lines.append("  RECOMMENDATIONS")
        lines.append("  " + "-" * 40)
        for rec in unique_recs:
            lines.append(f"  * {rec}")
        lines.append("")

    lines.append("=" * 64)
    return "\n".join(lines)


def format_summary(results):
    """One-line summary for quick checks."""
    total_c = sum(r["total_compactions"] for r in results)
    total_fok = sum(r["flush_successes"] for r in results)
    total_rok = sum(r["recovery_successes"] for r in results)
    sessions = len(results)

    if total_c == 0:
        return f"{sessions} sessions, 0 compactions. No compaction events to analyze."

    flush_pct = (total_fok / total_c * 100) if total_c else 0
    recov_pct = (total_rok / total_c * 100) if total_c else 0
    return (
        f"{sessions} sessions, {total_c} compactions. "
        f"Flush: {total_fok}/{total_c} ({flush_pct:.0f}%). "
        f"Recovery: {total_rok}/{total_c} ({recov_pct:.0f}%)."
    )


# ── Telemetry Integration ────────────────────────────────────────────

def log_to_telemetry(results, workspace):
    """
    Append compaction diagnostic results to the kit's telemetry log.
    Only runs if telemetry is enabled (OPENCLAW_TELEMETRY_ENABLED=1).
    """
    if os.environ.get("OPENCLAW_TELEMETRY_ENABLED") != "1":
        return

    telemetry_dir = os.path.join(workspace, "telemetry")
    os.makedirs(telemetry_dir, exist_ok=True)
    telemetry_file = os.path.join(telemetry_dir, "metrics.jsonl")

    total_c = sum(r["total_compactions"] for r in results)
    total_fok = sum(r["flush_successes"] for r in results)
    total_rok = sum(r["recovery_successes"] for r in results)

    event = {
        "event": "compaction_diagnostic",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "sessions_analyzed": len(results),
        "total_compactions": total_c,
        "flush_successes": total_fok,
        "flush_failures": total_c - total_fok,
        "recovery_successes": total_rok,
        "recovery_failures": total_c - total_rok,
    }

    try:
        with open(telemetry_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(event) + "\n")
    except OSError:
        pass  # Telemetry is best-effort


# ── Hook Stub ────────────────────────────────────────────────────────

HOOK_STUB = """\
// OpenClaw Cognitive Upgrade Kit — session:compacted hook stub
// Place this in your workspace hooks directory when OpenClaw ships
// the session:compacted event (see GitHub issue #11799).
//
// Until then, use the diagnostic tool for retroactive analysis:
//   python3 TOOLS/openclaw_compaction_diagnostics.py report
//
// When the hook is available, this script will:
// 1. Log the compaction event to kit telemetry
// 2. Trigger the agent to run the post-compaction recovery protocol

module.exports = {
  name: "kit-compaction-hook",
  version: "0.1.0",
  hooks: {
    "session:compacted": async (event, { agent, workspace }) => {
      const fs = require("fs/promises");
      const path = require("path");

      // 1. Log to kit telemetry
      const telemetryDir = path.join(workspace, "telemetry");
      await fs.mkdir(telemetryDir, { recursive: true });
      const entry = JSON.stringify({
        event: "compaction_detected",
        timestamp: new Date().toISOString(),
        sessionKey: event.sessionKey,
        preCompactTokens: event.context?.preCompactTokens,
        postCompactTokens: event.context?.postCompactTokens,
        summaryLength: event.context?.compactSummary?.length || 0,
      });
      await fs.appendFile(
        path.join(telemetryDir, "metrics.jsonl"),
        entry + "\\n"
      );

      // 2. Inject recovery prompt into the session
      // The agent will see this as a system-level instruction to
      // run the post-compaction recovery protocol from AGENTS.md.
      return {
        prependContext: [
          "COMPACTION DETECTED. Run the post-compaction recovery protocol:",
          "1. Read GLOBAL-STATE.yaml for canonical state.",
          "2. Read today's memory/YYYY-MM-DD.md for working state.",
          "3. Run memory_search for task-relevant keywords.",
          "4. Announce what you recovered and what's uncertain.",
          "5. Do not proceed with vague intent.",
        ].join("\\n"),
      };
    },
  },
};
"""


# ── CLI ──────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="OpenClaw Cognitive Upgrade Kit — Compaction Diagnostics"
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Report command
    report_p = subparsers.add_parser("report", help="Full compaction health report")
    report_p.add_argument("--session", help="Path to a specific session .jsonl file")
    report_p.add_argument("--sessions-dir", default=DEFAULT_SESSIONS_DIR,
                          help=f"Sessions directory (default: {DEFAULT_SESSIONS_DIR})")
    report_p.add_argument("--workspace", default=DEFAULT_WORKSPACE,
                          help=f"Workspace directory (default: {DEFAULT_WORKSPACE})")
    report_p.add_argument("--days", type=int, help="Only analyze sessions from last N days")
    report_p.add_argument("--json", action="store_true", help="Output as JSON")

    # Summary command
    summary_p = subparsers.add_parser("summary", help="One-line summary")
    summary_p.add_argument("--sessions-dir", default=DEFAULT_SESSIONS_DIR)
    summary_p.add_argument("--workspace", default=DEFAULT_WORKSPACE)
    summary_p.add_argument("--days", type=int, default=7, help="Days to look back (default: 7)")

    # Hook stub command
    hook_p = subparsers.add_parser("hook-stub", help="Print the session:compacted hook stub")
    hook_p.add_argument("--output", help="Write to file instead of stdout")

    args = parser.parse_args()

    if args.command == "report":
        if args.session:
            files = [args.session]
        else:
            files = find_session_files(args.sessions_dir, args.days)
            if not files:
                print(f"No session files found in {args.sessions_dir}", file=sys.stderr)
                if args.days:
                    print(f"(filtered to last {args.days} days)", file=sys.stderr)
                sys.exit(1)

        results = []
        for f in files:
            r = analyze_session(f, args.workspace)
            if r:
                results.append(r)

        if not results:
            print("No analyzable sessions found.", file=sys.stderr)
            sys.exit(1)

        print(format_report(results, output_json=args.json))
        log_to_telemetry(results, args.workspace)

    elif args.command == "summary":
        files = find_session_files(args.sessions_dir, args.days)
        if not files:
            print(f"No sessions found in last {args.days} days.")
            sys.exit(0)

        results = []
        for f in files:
            r = analyze_session(f, args.workspace)
            if r:
                results.append(r)

        print(format_summary(results))
        log_to_telemetry(results, args.workspace)

    elif args.command == "hook-stub":
        if args.output:
            with open(args.output, "w") as f:
                f.write(HOOK_STUB)
            print(f"Hook stub written to {args.output}")
        else:
            print(HOOK_STUB)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
