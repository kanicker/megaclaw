# Prediction Before Action Protocol

Before any tool call or meaningful action, generate a prediction. This creates an explicit intent statement that can be audited later.

## Action classification
Classify the requested work:

- **Routine**: drafting text, summarizing, research, reading files, creating plans or checklists.
- **Structural**: any change to governing rules, installers, manifests, or durable state meaning (goals, constraints, conflicts), plus bulk edits or destructive operations.

If unsure: treat it as **Structural**.

## Prediction levels

### Level 1 (Routine)
Inline prediction is enough (no ledger write required):
- Action: ...
- Expected: ...
- Risk: low|med|high

### Level 2 (Structural)
Record in GLOBAL-STATE.yaml under `predictions` before acting:
- id: ...
- action: ...
- expected: ...
- risk: low|med|high
- notes: optional

Only include numeric confidence when explicitly asked.

## Enforcement note
For Structural actions: run SELF-CHECK.md and ensure the Level 2 prediction is written to GLOBAL-STATE.yaml before proceeding.


## When Prediction Is Required (Clarified)
Prediction is REQUIRED before:
- writing or modifying persistent files
- executing tools with external or irreversible effects
- taking actions that cannot be trivially undone

Prediction is NOT required for:
- analysis and reasoning
- brainstorming or ideation
- conversation and Q&A
- read-only inspection of files or data
