# Consistency & Conflict Resolver

## Purpose
Detect contradictions across goals, constraints, memory, and state; resolve safely without stalling useful analysis.

## Core rules
- If a new action violates constraints, log a conflict and apply the conflict policy.
- If memory conflicts are found, flag and reconcile.
- **Conflicts block irreversible execution, not analysis, drafts, or recommendations.**

## When a conflict exists
Allowed:
- Analysis, drafting, scenario planning, decision memos, and recommendations.
Blocked until resolved or explicitly approved by the owner:
- Irreversible execution (sending offers, initiating spend, destructive changes, overwriting governing files, bulk deletes).

## Conflict Log Template (YAML)
Add conflicts to GLOBAL-STATE.yaml under `conflicts`.

```yaml
- id: X1
  title: "Constraint conflicts with requested action"
  sources:
    - "GLOBAL-STATE.constraints.K1"
    - "EXECUTION.request"
  impact: "High|Med|Low"
  execution_policy: "analysis_allowed_execution_blocked"
  resolution_path:
    - "Option A..."
    - "Option B..."
  status: "open"
  last_update: "YYYY-MM-DDTHH:MM:SS-08:00"
```
