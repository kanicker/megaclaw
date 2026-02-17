# Escalation — Workflow Guide

## Purpose
Route issues that exceed department authority to the right decision-maker.

## When to escalate
A department agent escalates when it encounters:
- Cross-department resource conflict
- Priority conflict with company goals
- Budget or spend authorization needed
- Strategic direction question
- Unresolved inter-agent request (past deadline)

## Process
1. **Agent writes escalation.** File to shared/requests/ with type: escalation, including context, options if known, and urgency.
2. **CoS triages.** On next heartbeat or session, CoS reads pending escalations.
   - If within CoS authority (request triage, low-stakes scheduling): resolve and notify.
   - If requires founder: write a decision memo to shared/decisions/ with context, options, CoS recommendation, and deadline.
3. **Founder decides.** Via the startup pulse, the founder reviews decision memos and approves, modifies, or rejects.
4. **CoS propagates.** After founder decision, CoS writes the decision to BOARD-DECISIONS.md and notifies affected department agents.

## Decision memo format
```yaml
id: ESC-{date}-{seq}
from: {agent_id}
type: escalation
category: resource_conflict | priority_conflict | budget | strategic | unresolved_request
summary: ""
context: ""
options:
  - option: A
    tradeoff: ""
  - option: B
    tradeoff: ""
cos_recommendation: ""
urgency: low | medium | high | critical
deadline: ""
status: pending_founder | resolved
```
