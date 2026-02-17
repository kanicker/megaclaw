# EXECUTIVE-STATE-SCHEMA.md — Field Reference

EXECUTIVE-STATE.yaml is a **convenience index** subordinate to GLOBAL-STATE.yaml. If they conflict, GLOBAL-STATE wins. See STATE-CONTRACT.md.

---

## priorities (max 3)

Current top priorities. Capping at three forces rank-order discipline.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Stable identifier (e.g., "P-2026-02-15-001") |
| title | string | One-line description |
| why | string | Why this matters now |
| success_criteria | string | How you know it's done |
| due | date | Target completion date |
| status | enum | `active`, `completed`, `paused`, `dropped` |

## commitments

Promises made to others. Every commitment needs an owner and a deadline.

| Field | Type | Description |
|-------|------|-------------|
| who | string | Person or group you committed to |
| what | string | What you promised |
| due | date | When it's due |
| status | enum | `on_track`, `at_risk`, `overdue`, `completed` |
| global_state_ref | string | Links to decision ID in GLOBAL-STATE (if applicable) |

## decisions_pending

Decisions that need to be made. Not yet committed — these are open questions.

| Field | Type | Description |
|-------|------|-------------|
| decision | string | What needs to be decided |
| options | list | Known options under consideration |
| recommendation | string | Agent's recommendation (if asked) |
| by | date | Decision deadline |
| stakes | string | What's at risk if delayed or wrong |

## delegations

Work assigned to others.

| Field | Type | Description |
|-------|------|-------------|
| owner | string | Who is responsible |
| deliverable | string | What, specifically |
| due | date | Expected delivery date |
| cadence | string | Check-in frequency (e.g., "weekly", "on completion") |

## stakeholders_active

Key people relevant to current work. Lightweight — not a CRM.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Person's name |
| tier | enum | `A` (high-touch), `B` (regular), `C` (as-needed) |
| next_touch | date | When to next reach out |

Full stakeholder details (role, relationship notes, last contact) live in STAKEHOLDERS.yaml.

## risks

Active risks that need monitoring.

| Field | Type | Description |
|-------|------|-------------|
| risk | string | What could go wrong |
| severity | enum | `low`, `medium`, `high`, `critical` |
| mitigation | string | What's being done about it |
| owner | string | Who owns the mitigation |

## cadence

Standing rhythms and recurring obligations.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Name of the rhythm (e.g., "Weekly team sync") |
| frequency | string | How often (e.g., "weekly", "biweekly", "monthly") |
| next | date | Next occurrence |

## last_update

ISO timestamp of the most recent modification to this file. Updated by the agent after any write.
