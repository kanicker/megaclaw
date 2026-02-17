# Daily Pulse — Workflow Guide

## Purpose

Start each session or day with a structured assessment of current state. This extends the Basic kit's HEARTBEAT.md with executive-specific checks.

## When to run

- At session start (automatic if AGENTS-COS.md is loaded)
- When the user asks for a status check or "what's on today"

## Inputs

1. GLOBAL-STATE.yaml — active decisions, constraints, conflicts
2. EXECUTIVE-STATE.yaml — priorities, commitments, delegations, pending decisions, risks
3. STAKEHOLDERS.yaml — any overdue next-touch dates
4. User-provided notes (calendar, inbox, context) — if available

## Process

1. **Read state files.** Do not narrate this step.
2. **Assess priorities.** Are the three priorities still current? Any new conflicts?
3. **Check decisions.** Any ACTIVE decisions approaching review dates? Any pending decisions past their by-date?
4. **Check commitments.** Any commitments due today or overdue?
5. **Check delegations.** Any deliverables due today or overdue?
6. **Check stakeholders.** Any next-touch dates that are today or past due?
7. **Check risks.** Any risks that have escalated or need attention?
8. **Memory maintenance.** Scan the past 2-3 days of episodic memory (daily logs) for anything that should be promoted to semantic memory (MEMORY.md) — durable facts, confirmed preferences, decisions that haven't been captured yet. This follows Basic's three-tier taxonomy.
9. **Context pressure.** If available, run `python3 TOOLS/openclaw_context_monitor.py check`. If warning or critical, save working state before continuing.
10. **Propose three moves.** What are the three most important things to do today?

## Output

A short pulse (half page max):

```
## Pulse — [date]

**Priorities:** [list of 3, with status]
**Decisions due:** [any approaching or overdue]
**Commitments at risk:** [any due or overdue]
**Stakeholder touches:** [any overdue]
**Risks:** [any escalated]
**Memory:** [facts promoted, context pressure status]

**Three moves today:**
1. [most important action]
2. [second]
3. [third]
```

## State writes

- If the pulse reveals a new commitment, propose a decision capture.
- If priorities need updating, propose changes to EXECUTIVE-STATE.yaml.
- Do not write state changes silently. Always surface to user first.
