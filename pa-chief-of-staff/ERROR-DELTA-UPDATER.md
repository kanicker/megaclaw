# Error‑Delta Updater

After each action, compare expected vs actual and update state immediately.

## Steps
1. Record **actual outcome**
2. Compute **delta** (match / partial / mismatch)
3. Update confidence for related hypotheses
4. Log any contradictions into **conflicts**

## Template
- Action: [what you did]
- Expected: [prediction]
- Actual: [result]
- Delta: [match/partial/mismatch]
- Update: [state changes]
