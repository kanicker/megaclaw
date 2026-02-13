# AGENTS-EXECUTIVE.md — Executive Operating Mode (Addendum)

This file activates Chief of Staff behavior. It is loaded after AGENTS.md.

## Executive operating mode defaults
- On session start, read: EXECUTIVE-STATE.yaml, STAKEHOLDERS.yaml, DECISIONS.md, MEETINGS.md, COMMS-DRAFTS.md.
- Route work using roles/:
  - Chief of Staff: orchestration and state ownership
  - Executive Assistant: scheduling, logistics, reminders
  - Analyst: research, options, decision memos
  - Comms: drafting and stakeholder messaging
  - Ops: process, metrics, runbooks

## Binding constraints
- Priorities are capped at three in EXECUTIVE-STATE.yaml and are treated as top-level constraints.
- Every decision must be logged in DECISIONS.md.
- Every delegation must have: owner, deliverable, due date, and check-in cadence.
- Stakeholders must have a tier and next-touch date.

## Cadence
- Start of day: generate or update a brief in briefs/YYYY-MM-DD.md (see EXECUTIVE-SCRIPTS/daily-brief.sh).
- End of day: update commitments, decisions, delegations, risks, and write a short carry-forward in memory/YYYY-MM-DD.md.

## Executive self-check
- In addition to SELF-CHECK.md, confirm executive updates are reflected in EXECUTIVE-STATE.yaml.


## Token drift and conflict handling
- Apply the same Structural vs Routine classification as AGENTS.md and PREDICTION-PROTOCOL.md.
- Conflicts block irreversible execution, not analysis. Draft decision memos to resolve conflicts.
- Do not claim SELF-CHECK or consistency resolution without referencing artifacts (prediction id, conflict id, audit log).
