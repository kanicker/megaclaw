# Compaction Survival Guide

Context compaction is the #1 cause of "my agent forgot everything." This guide explains what happens and how to survive it.

## What compaction is

When your conversation exceeds the model's context window (~200k tokens for Claude), OpenClaw summarizes older messages to make room. The summary preserves the gist but drops specifics: file paths, exact commands, configuration values, the reasoning behind decisions. After compaction, the agent effectively has amnesia about details from the first part of the conversation.

## Why the default setup loses context

OpenClaw's `memoryFlush` is enabled by default, but the default `softThresholdTokens` (4000) triggers very late — at ~176k tokens. By that point the conversation is enormous, and the flush may not save everything. Also, the default flush prompt just says "write any lasting notes." It doesn't tell the agent to save structured state like decisions, predictions, or conflict status.

## What this kit does about it

Three things work together:

**1. Recommended config raises the threshold and improves the flush prompt.**

The `openclaw.recommended.jsonc` in this kit sets `reserveTokensFloor: 40000` and `softThresholdTokens: 8000`, which triggers the flush at ~152k tokens instead of ~176k. The flush prompt tells the agent to save ACTIVE decisions, open predictions, and GLOBAL-STATE.yaml — not just raw notes.

**2. GLOBAL-STATE.yaml survives compaction.**

Because GLOBAL-STATE.yaml is a file on disk (not conversation history), compaction cannot touch it. After compaction, the agent re-reads GLOBAL-STATE.yaml and immediately knows: what goals are active, what conflicts exist, what predictions are open, and what decisions have been made. This is the primary compaction survival mechanism.

**3. Decision typing prevents zombie intent.**

After compaction, the agent may find old plans in MEMORY.md that were discussed earlier in the session. Without decision typing, it might treat those old plans as current intent. With `[THINKING]` vs `[DECISION]` markers and `Status: ACTIVE` vs `SUPERSEDED`, the agent can tell which plans are still live.

## What you should do

**Apply the recommended config.** Copy the compaction and memoryFlush sections from `openclaw.recommended.jsonc` into your `~/.openclaw/openclaw.json`. Then restart: `openclaw gateway restart`.

**Enable memory search.** Without it, the agent can only find memories by reading files directly. With many daily logs, it won't find relevant context from last week. Set a `memorySearch.provider` in your config.

**For long working sessions,** periodically ask the agent: "Save your working state." This writes current context to memory files before compaction can destroy it. You shouldn't have to do this — the memoryFlush should handle it — but it's a safety net.


## When the flush fails or is incomplete

The flush can fail silently. The workspace might be read-only (sandboxed sessions), the model might respond with NO_REPLY without actually saving, or compaction might fire between turns before the flush threshold is reached. In these cases, the agent loses context with no warning.

This kit addresses this with a **post-compaction recovery protocol** in AGENTS.md. When the agent suspects compaction occurred (the conversation feels abruptly shorter, it was mid-task but lacks specifics), it runs a structured recovery:

1. Re-read GLOBAL-STATE.yaml (canonical state, on disk, untouched by compaction)
2. Re-read today's daily memory log for working state entries
3. Run memory_search for task-relevant keywords (if enabled)
4. Announce what it recovered and what's missing — ask the user to fill gaps only if state files don't cover it
5. Never silently proceed with vague intent

This isn't perfect — if the flush failed AND the agent hadn't written working state to daily memory AND GLOBAL-STATE.yaml is stale, recovery data may be thin. But it's a significant improvement over the default behavior, which is to proceed as if nothing happened.

**The architectural gap:** OpenClaw currently has no `session:compacted` hook (it's an open feature request, #11799). The agent:bootstrap hook fires every turn but can't distinguish a normal turn from a post-compaction turn. Our recovery protocol works around this by using behavioral detection (the agent notices its context feels incomplete) rather than a system signal. If OpenClaw ships the `session:compacted` hook, a future version of this kit can trigger recovery automatically.

## How to tell if compaction ate your context

Signs: the agent suddenly doesn't know what file it was editing, asks you to repeat instructions you gave 30 minutes ago, or starts a task from scratch that was half-done. Run `/context detail` to see current token usage. If you see a compaction event in the session, that's what happened.

## Measuring compaction survival

After running for a few days, use the diagnostic tool to see whether your config is working:

```bash
# Full report: flush rate, recovery rate, recommendations
python3 TOOLS/openclaw_compaction_diagnostics.py report --days 7

# Quick check
python3 TOOLS/openclaw_compaction_diagnostics.py summary
```

The report parses your session JSONL transcripts and checks:
- Did the pre-compaction flush fire before each compaction? (Were memory files written?)
- Did the agent read GLOBAL-STATE.yaml and memory files after compaction? (Recovery protocol)
- Did the agent use memory_search after compaction? (Cross-session recall)
- Did the agent announce recovery to the user? (Transparency)

Session logs may contain sensitive content. The diagnostics tool runs entirely locally and does not transmit any data.

A healthy kit shows flush rate > 80% and recovery rate > 70%. If either is low, the report tells you exactly what to fix.

You can also generate a `session:compacted` hook stub for when OpenClaw ships that feature:
```bash
python3 TOOLS/openclaw_compaction_diagnostics.py hook-stub --output hooks/compaction-hook.js
```

This creates a ready-to-use hook that will automatically trigger the recovery protocol and log compaction events to kit telemetry — no manual intervention needed.

## Config quick reference

```json
{
  "agents": {
    "defaults": {
      "compaction": {
        "mode": "default",
        "reserveTokensFloor": 40000,
        "memoryFlush": {
          "enabled": true,
          "softThresholdTokens": 8000,
          "systemPrompt": "Session nearing compaction. Save durable context now: ACTIVE decisions to GLOBAL-STATE.yaml, working state to memory/YYYY-MM-DD.md. Preserve prediction ids and conflict status.",
          "prompt": "Write any ACTIVE decisions, open predictions, unresolved conflicts, and working context to memory/YYYY-MM-DD.md and update GLOBAL-STATE.yaml. Reply with NO_REPLY if nothing to store."
        }
      }
    }
  }
}
```
