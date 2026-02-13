# Global State Ledger — Schema

**What it is:** a single structured state file that captures the agent’s current goals, beliefs, constraints, conflicts, and predictions. It is not just a prediction log.

Create a single structured state file that the agent must consult for all actions.

## Fields (minimum)
- **goals**: list of active objectives
- **hypotheses**: beliefs + confidence
- **constraints**: hard limits, policies
- **conflicts**: detected contradictions
- **predictions**: expected outcomes for next actions
- **last_update**: timestamp

## Example (YAML)
```yaml
goals:
  - "Launch cognitive upgrade kit"
hypotheses:
  - belief: "Users want simple drop‑in files"
    confidence: 0.7
constraints:
  - "Ask before external actions"
conflicts: []
predictions:
  - action: "Upload bundle"
    expected: "Zip available to buyer"
    confidence: 0.8
last_update: "2026‑02‑10T18:00:00‑08:00"
```
