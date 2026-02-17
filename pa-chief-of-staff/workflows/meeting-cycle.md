# Meeting Cycle — Workflow Guide

## Purpose

Ensure every meeting has clear desired outcomes going in, and produces captured decisions coming out.

## When to run

- **Prep phase:** When the user mentions an upcoming meeting or asks to prepare
- **Follow-up phase:** When the user returns from a meeting or shares meeting notes

---

## Phase 1: Prep

### Inputs
- Meeting context (who, what, why)
- EXECUTIVE-STATE.yaml — relevant priorities, pending decisions, delegations
- STAKEHOLDERS.yaml — relationship context for attendees
- Previous meeting notes (if available in briefings/)

### Process
1. Identify the meeting's purpose and why it matters to current priorities.
2. Propose 2-3 desired outcomes.
3. Draft a stance or recommendation if a decision is expected.
4. Identify 2-3 questions to ask.
5. Flag risks or sensitivities.
6. Check prep checklist.

### Output
A one-page brief saved to `briefings/[date]-[meeting-name].md`:

```
## Meeting Brief — [meeting name]
**Date:** [date/time]
**Attendees:** [list]
**Why this matters:** [one sentence]

**Desired outcomes:**
1. [outcome]
2. [outcome]
3. [outcome]

**Your stance:** [recommendation if applicable]

**Questions to ask:**
1. [question]
2. [question]

**Risks to watch:** [list]

**Prep checklist:**
- [ ] Reviewed last meeting notes
- [ ] Confirmed open follow-ups
- [ ] Drafted post-meeting recap sentence
```

---

## Phase 2: Follow-Up

### Inputs
- User's notes or verbal debrief from the meeting
- The meeting brief (if one was created)

### Process
1. Ask: "Were any decisions made in this meeting?"
2. For each decision, propose a typed decision block for confirmation.
3. Capture action items with owner, deliverable, and due date.
4. Identify any new commitments, risks, or stakeholder signals.

### State writes
- Confirmed decisions → GLOBAL-STATE.yaml (typed decision block, status ACTIVE)
- Action items → EXECUTIVE-STATE.yaml (delegations or commitments)
- Stakeholder updates → STAKEHOLDERS.yaml (last_touch, next_touch, context)
- Offer to draft a follow-up message using COMMS-DRAFTS.md templates.

### Output
A follow-up summary appended to the meeting brief or presented inline:

```
## Follow-Up — [meeting name]

**Decisions captured:**
- [decision] → recorded as D-YYYY-MM-DD-NNN

**Actions:**
- [owner]: [deliverable] by [date]

**New commitments:**
- [commitment]

**Stakeholder notes updated:**
- [name]: [update]

**Follow-up message:** [drafted / sent / pending]
```
