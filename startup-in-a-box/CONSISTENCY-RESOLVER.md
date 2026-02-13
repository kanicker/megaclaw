# Consistency & Conflict Resolver

## Purpose
Detect contradictions across goals, constraints, and memory; resolve before proceeding.

## Rules
- If a new action violates constraints, **stop and ask**.
- If memory conflicts are found, **flag and reconcile**.
- Do not proceed with major actions while conflicts exist.

## Conflict Log Template
- Conflict: [description]
- Source: [files/steps]
- Resolution: [what changed]
- Status: [open/resolved]
