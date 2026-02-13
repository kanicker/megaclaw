# Prediction Before Action Protocol

Before any tool call or major action, generate a short prediction. This is separate from the Global State Ledger, which also tracks goals, hypotheses, constraints, conflicts, and predictions.

## Required fields
- **action**
- **expected outcome**
- **risk** (low/med/high)

Only include numeric confidence when explicitly asked.

## Template
- Action: [what you will do]
- Expected: [what should happen]
- Risk: [low/med/high]

Record the prediction in the Global State Ledger when possible, then proceed with the action.


## Enforcement note
Before acting, run **SELF-CHECK.md** and confirm the prediction is recorded in GLOBAL-STATE.yaml.
