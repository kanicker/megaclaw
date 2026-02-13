# STATE-INTEGRATION.md — GLOBAL vs EXECUTIVE State Contract

The Executive kit uses two ledgers:

## GLOBAL-STATE.yaml (cognitive layer)
Tracks:
- goals, hypotheses, constraints, conflicts, predictions, last_update
Purpose:
- Meta-reasoning, reliability loop, and cross-domain consistency

## EXECUTIVE-STATE.yaml (domain layer)
Tracks:
- priorities (max 3), commitments, decisions_pending, delegations, risks, metrics, last_update
Purpose:
- Operating system for executive work

## Contract
- EXECUTIVE-STATE priorities supersede GLOBAL goals for day-to-day execution.
- Any material contradiction between the two must be recorded as a conflict in GLOBAL-STATE.yaml.
- Predictions should reference both ledgers when actions touch executive objects.
- Consistency resolution must consider both ledgers before proceeding.

## Recommended practice
- Keep GLOBAL goals high-level.
- Keep EXECUTIVE priorities concrete and time-bounded.
