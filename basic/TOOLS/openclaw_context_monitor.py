#!/usr/bin/env python3
"""
openclaw_context_monitor.py (v1.0)

Lightweight context pressure estimator for heartbeat integration.
Answers: "Should I save state now before compaction hits?"

Unlike the compaction diagnostics tool (which analyzes after the fact from
session transcripts), this tool estimates current context pressure from
what's on disk and provides a go/no-go signal for proactive saves.

Usage:
  # Quick check — returns exit code 0 (safe), 1 (warning), 2 (critical)
  python3 TOOLS/openclaw_context_monitor.py check

  # Detailed report
  python3 TOOLS/openclaw_context_monitor.py report

  # JSON output (for heartbeat scripts)
  python3 TOOLS/openclaw_context_monitor.py check --json

  # Custom thresholds
  python3 TOOLS/openclaw_context_monitor.py check --warn 60 --critical 80

  # Custom context window size (default: 200000 tokens)
  python3 TOOLS/openclaw_context_monitor.py check --context-window 128000

How it works:
  Estimates token usage from files that get injected or loaded per turn:
  - Auto-injected files (AGENTS.md, SOUL.md, IDENTITY.md, USER.md, TOOLS.md,
    MEMORY.md, HEARTBEAT.md)
  - Active agent files (if multiagent overlay present)
  - GLOBAL-STATE.yaml
  - Today's and yesterday's daily memory logs
  - MANIFEST.yaml (if multiagent overlay present)

  This is an estimate, not a measurement. It cannot see actual conversation
  history length, tool outputs, or model overhead. But it catches the main
  cause of surprise compaction: memory and state files growing silently
  until they crowd out working context.

Privacy: Reads file sizes only. Does not read file contents. No data
is transmitted.

Exit codes:
  0 — Safe (below warning threshold)
  1 — Warning (save recommended)
  2 — Critical (save now)
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path


def estimate_tokens(char_count: int) -> int:
    """Conservative estimate: ~4 chars per token for English markdown."""
    return char_count // 4


def file_size_chars(path: str) -> int:
    """Return file size in characters, 0 if missing."""
    try:
        return os.path.getsize(path)
    except (OSError, FileNotFoundError):
        return 0


def scan_workspace(workspace: str) -> dict:
    """Scan workspace and estimate token usage by category."""
    ws = Path(workspace)
    breakdown = {}

    # Auto-injected kernel files
    kernel_files = [
        "AGENTS.md", "SOUL.md", "IDENTITY.md", "USER.md",
        "TOOLS.md", "MEMORY.md", "HEARTBEAT.md"
    ]
    kernel_chars = sum(file_size_chars(ws / f) for f in kernel_files)
    breakdown["kernel"] = {
        "chars": kernel_chars,
        "tokens": estimate_tokens(kernel_chars),
        "detail": "Auto-injected files (AGENTS.md, SOUL.md, etc.)"
    }

    # GLOBAL-STATE.yaml
    gs_chars = file_size_chars(ws / "GLOBAL-STATE.yaml")
    breakdown["global_state"] = {
        "chars": gs_chars,
        "tokens": estimate_tokens(gs_chars),
        "detail": "GLOBAL-STATE.yaml"
    }

    # Today's and yesterday's daily memory logs
    today = datetime.now().strftime("%Y-%m-%d")
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    memory_chars = 0
    memory_chars += file_size_chars(ws / f"memory/{today}.md")
    memory_chars += file_size_chars(ws / f"memory/{yesterday}.md")
    breakdown["daily_memory"] = {
        "chars": memory_chars,
        "tokens": estimate_tokens(memory_chars),
        "detail": "Today + yesterday daily memory logs"
    }

    # Multiagent overlay files (if present)
    agents_multi = ws / "AGENTS-MULTI.md"
    manifest = ws / "shared" / "MANIFEST.yaml"
    overlay_chars = 0
    if agents_multi.exists():
        overlay_chars += file_size_chars(str(agents_multi))
        overlay_chars += file_size_chars(str(manifest))

        # Active agent's files (check GLOBAL-STATE for active_agent)
        gs_path = ws / "GLOBAL-STATE.yaml"
        active_agent = None
        if gs_path.exists():
            try:
                content = gs_path.read_text()
                for line in content.splitlines():
                    if line.strip().startswith("active_agent:"):
                        active_agent = line.split(":", 1)[1].strip().strip('"').strip("'")
                        break
            except Exception:
                pass

        if active_agent:
            agent_dir = ws / "agents" / active_agent
            if agent_dir.exists():
                agent_chars = 0
                agent_chars += file_size_chars(agent_dir / "SOUL.md")
                agent_chars += file_size_chars(agent_dir / "IDENTITY.md")
                agent_chars += file_size_chars(agent_dir / "MEMORY.md")
                agent_chars += file_size_chars(agent_dir / f"memory/{today}.md")
                agent_chars += file_size_chars(agent_dir / f"memory/{yesterday}.md")
                overlay_chars += agent_chars
                breakdown["active_agent"] = {
                    "chars": agent_chars,
                    "tokens": estimate_tokens(agent_chars),
                    "detail": f"Active agent '{active_agent}' files"
                }

    if overlay_chars > 0:
        overlay_only = file_size_chars(str(agents_multi)) + file_size_chars(str(manifest))
        breakdown["overlay"] = {
            "chars": overlay_only,
            "tokens": estimate_tokens(overlay_only),
            "detail": "AGENTS-MULTI.md + MANIFEST.yaml"
        }

    # Addendum files (CoS, etc.)
    addendum_chars = 0
    for addendum in ["AGENTS-COS.md", "AGENTS-HUB.md", "EXECUTIVE-STATE.yaml"]:
        addendum_chars += file_size_chars(ws / addendum)
    if addendum_chars > 0:
        breakdown["addenda"] = {
            "chars": addendum_chars,
            "tokens": estimate_tokens(addendum_chars),
            "detail": "Kit addenda (CoS, hub, etc.)"
        }

    # Totals
    total_chars = sum(v["chars"] for v in breakdown.values())
    total_tokens = sum(v["tokens"] for v in breakdown.values())
    breakdown["_total"] = {
        "chars": total_chars,
        "tokens": total_tokens
    }

    return breakdown


def check(workspace: str, context_window: int, warn_pct: int, critical_pct: int,
          output_json: bool) -> int:
    """Run a pressure check. Returns exit code."""
    breakdown = scan_workspace(workspace)
    total_tokens = breakdown["_total"]["tokens"]
    usage_pct = (total_tokens * 100) // context_window if context_window > 0 else 0

    # Determine status
    if usage_pct >= critical_pct:
        status = "critical"
        exit_code = 2
    elif usage_pct >= warn_pct:
        status = "warning"
        exit_code = 1
    else:
        status = "safe"
        exit_code = 0

    if output_json:
        result = {
            "status": status,
            "usage_pct": usage_pct,
            "estimated_tokens": total_tokens,
            "context_window": context_window,
            "remaining_tokens": context_window - total_tokens,
            "timestamp": datetime.now(tz=None).astimezone().isoformat()
        }
        print(json.dumps(result))
    else:
        icons = {"safe": "✅", "warning": "⚠️", "critical": "🚨"}
        icon = icons[status]
        print(f"{icon} Context pressure: {usage_pct}% of injected file budget ({total_tokens:,} tokens estimated)")
        if status == "critical":
            print("   Save working state to memory and GLOBAL-STATE.yaml NOW.")
        elif status == "warning":
            print("   Consider saving working state. Memory files are getting large.")
        else:
            print("   Healthy. No action needed.")

    return exit_code


def report(workspace: str, context_window: int) -> int:
    """Detailed breakdown report."""
    breakdown = scan_workspace(workspace)
    total_tokens = breakdown["_total"]["tokens"]
    usage_pct = (total_tokens * 100) // context_window if context_window > 0 else 0

    print("Context Pressure Report")
    print(f"Workspace: {workspace}")
    print(f"Context window: {context_window:,} tokens")
    print(f"Estimated injected file usage: {total_tokens:,} tokens ({usage_pct}%)")
    print()

    # Breakdown
    print("Breakdown:")
    for key, val in breakdown.items():
        if key.startswith("_"):
            continue
        pct = (val["tokens"] * 100) // total_tokens if total_tokens > 0 else 0
        print(f"  {val['detail']}: {val['tokens']:,} tokens ({pct}%)")

    print()

    # Recommendations
    if usage_pct >= 30:
        print("Recommendations:")
    if breakdown.get("daily_memory", {}).get("tokens", 0) > 3000:
        print("  - Daily memory logs are large. Distill key facts into MEMORY.md and trim the logs.")
    kernel_tokens = breakdown.get("kernel", {}).get("tokens", 0)
    if kernel_tokens > 5000:
        print("  - Kernel files are larger than typical (~3,250 tokens). Review AGENTS.md and MEMORY.md for bloat.")
    gs_tokens = breakdown.get("global_state", {}).get("tokens", 0)
    if gs_tokens > 2000:
        print("  - GLOBAL-STATE.yaml is growing. Archive completed goals and superseded decisions.")
    if usage_pct < 30:
        print("No concerns. File injection budget is well within limits.")

    print()
    print("Note: This estimates injected file pressure only. Actual context usage includes")
    print("conversation history, tool outputs, and model overhead — which this tool cannot measure.")
    print("Use /context detail or session_status for live context window usage.")

    return 0


def main():
    parser = argparse.ArgumentParser(
        description="Estimate context pressure from workspace files."
    )
    parser.add_argument("command", choices=["check", "report"],
                        help="'check' for quick status, 'report' for detailed breakdown")
    parser.add_argument("--workspace", default=None,
                        help="Workspace path (default: $OPENCLAW_WORKSPACE_DIR or ~/.openclaw/workspace)")
    parser.add_argument("--context-window", type=int, default=200000,
                        help="Context window size in tokens (default: 200000)")
    parser.add_argument("--warn", type=int, default=15,
                        help="Warning threshold percent of context window (default: 15)")
    parser.add_argument("--critical", type=int, default=25,
                        help="Critical threshold percent of context window (default: 25)")
    parser.add_argument("--json", action="store_true",
                        help="JSON output (for heartbeat scripts)")

    args = parser.parse_args()

    # Resolve workspace
    workspace = args.workspace
    if workspace is None:
        workspace = os.environ.get("OPENCLAW_WORKSPACE_DIR",
                                   os.path.expanduser("~/.openclaw/workspace"))

    if not os.path.isdir(workspace):
        print(f"Error: Workspace not found at {workspace}", file=sys.stderr)
        sys.exit(1)

    if args.command == "check":
        sys.exit(check(workspace, args.context_window, args.warn, args.critical, args.json))
    elif args.command == "report":
        sys.exit(report(workspace, args.context_window))


if __name__ == "__main__":
    main()
