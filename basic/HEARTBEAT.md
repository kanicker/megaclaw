# HEARTBEAT.md

Use heartbeats to perform periodic checks and memory upkeep.

## Suggested checks (rotate)
- Inbox for urgent messages
- Calendar for upcoming events
- Reminders/todos
- Weather (if relevant)

## Memory upkeep
- Ensure daily memory log exists
- Distill significant events into MEMORY.md
- **Daily memory refresh:** re-read today’s `memory/YYYY-MM-DD.md` and `MEMORY.md`


## Operating Rules Summary (token drift guard)
- Periodically refresh a short 5-line summary in GLOBAL-STATE.yaml (recommended field: `operating_rules_summary`).
- Include at minimum:
  - Structural vs Routine classification
  - Conflicts block irreversible execution, not analysis
  - Structural actions require Level 2 prediction id
  - Protected actions require owner approval phrase
  - Do not claim compliance without artifacts
