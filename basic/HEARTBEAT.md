# HEARTBEAT.md

Use heartbeats to perform periodic checks, memory upkeep, and session health monitoring.

## Suggested checks (rotate)
- Inbox for urgent messages
- Calendar for upcoming events
- Reminders and todos
- Weather (if relevant)

## Memory upkeep
- Ensure daily memory log exists (`memory/YYYY-MM-DD.md`).
- Scan episodic entries from the past 2-3 days for anything that should be promoted to semantic memory (MEMORY.md).
- Distill significant events and ACTIVE decisions into MEMORY.md.
- If MEMORY.md exceeds ~200 lines, deduplicate and prune stale entries.
- Re-read today's daily log and MEMORY.md.

## Session health
- Run the context pressure monitor if available: `python3 TOOLS/openclaw_context_monitor.py check`. If it reports warning or critical, proactively save working state to memory files and GLOBAL-STATE.yaml before compaction hits.
- Alternatively, check token usage with `/context detail` or `session_status`. If the session is above 70% of context window, save working state immediately.
- Verify GLOBAL-STATE.yaml `last_update` is recent. If stale, refresh it.

## Drift guard
- Refresh the `operating_rules_summary` field in GLOBAL-STATE.yaml if it is stale or empty. Keep it to 5 lines covering: action classification, conflict policy, prediction requirements, protected action approval, and evidence requirement.
