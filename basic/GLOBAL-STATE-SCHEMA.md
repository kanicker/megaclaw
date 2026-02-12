# Global State Ledger — Schema

What it is: a single structured state file that captures the agent’s current goals, beliefs, constraints, conflicts, and predictions. It is not just a prediction log.

Create one structured state file that the agent must consult for Structural actions.

## Fields (minimum)
- goals: list of active objectives
- hypotheses: beliefs + optional confidence
- constraints: hard limits, policies
- conflicts: detected contradictions (use `execution_policy` to avoid paralysis)
- predictions: expected outcomes for next actions (Level 2 predictions for Structural work)
- last_update: timestamp

## Optional helpful fields
- operating_rules_summary: short 3 to 5 line re-anchor to reduce token drift

## Example (YAML)
```yaml
goals:
  - id: G1
    title: "Ship v2.2.0"
hypotheses: []
constraints:
  - id: K1
    title: "Ask before external actions"
conflicts:
  - id: X1
    title: "Headcount freeze vs VP Sales exemption"
    impact: "High"
    execution_policy: "analysis_allowed_execution_blocked"
    status: "open"
predictions:
  - id: P17
    action: "Update executive priorities and constraints"
    expected: "State remains consistent"
    risk: "med"
last_update: "2026-02-12T12:00:00-08:00"
operating_rules_summary:
  - "Structural vs Routine; if unsure Structural."
  - "Conflicts block execution, not analysis."
  - "Structural actions require prediction id in GLOBAL-STATE."
```
