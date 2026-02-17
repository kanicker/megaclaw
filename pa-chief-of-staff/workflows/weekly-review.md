# Weekly Review — Workflow Guide

## Purpose

Assess what changed over the past week, update state, and prepare for the next week.

## When to run

- Once per week, at a consistent time chosen by the user
- When the user asks for a weekly review or retrospective

## Inputs

1. GLOBAL-STATE.yaml — all ACTIVE decisions, constraints, conflicts
2. EXECUTIVE-STATE.yaml — priorities, commitments, delegations, risks, metrics
3. STAKEHOLDERS.yaml — relationship state
4. Daily pulse outputs from the past week (if available)
5. User-provided notes on progress, wins, misses

## Process

### 1. Wins
What went well this week? Decisions that landed, commitments fulfilled, risks mitigated.

### 2. Misses and lessons
What did not go as planned? What can we learn? Be factual, not judgmental.

### 3. Decision review
- Walk through ACTIVE decisions in GLOBAL-STATE.yaml.
- For each: is it still active? Has anything changed? Should it be superseded?
- Propose supersession for any stale or replaced decisions.

### 4. Priority assessment
- Are the three priorities still the right three?
- Should any be retired, replaced, or reprioritized?
- Propose updates to EXECUTIVE-STATE.yaml.

### 5. Delegation check
- Are all delegations on track?
- Any overdue deliverables?
- Any that need escalation or support?

### 6. Stakeholder review
- Were all planned touches completed?
- Any relationships that need attention next week?

### 7. Risk scan
- Any new risks surfaced this week?
- Any existing risks that escalated or de-escalated?

### 8. Memory hygiene
- Prune episodic memory: daily logs older than 30 days should be reviewed. Distill any durable facts or lessons into MEMORY.md (semantic), then archive or delete the old logs.
- Prune semantic memory: if MEMORY.md exceeds ~200 lines, deduplicate and remove stale entries.
- Update procedural memory: if any workflows in the workspace have changed this week, update the corresponding files rather than appending corrections.

### 9. Next week setup
- Propose priorities for next week (max 3).
- Identify decisions that must be made next week.
- Identify stakeholder touches needed.

## Output

A review packet (one page):

```
## Weekly Review — [date]

**Wins:** [list]
**Misses:** [list with lessons]
**Decision updates:** [superseded, renewed, or new]
**Priorities next week:** [max 3]
**Decisions to make next week:** [list with deadlines]
**Stakeholder touches next week:** [list]
**Risks:** [new, escalated, or mitigated]
**Memory cleanup:** [entries pruned, facts promoted to MEMORY.md, workflows updated]
**System improvements:** What should we stop doing? What should we automate?
```

## State writes

- Update ACTIVE decisions in GLOBAL-STATE.yaml (progress, supersession).
- Update EXECUTIVE-STATE.yaml priorities, delegations, risks.
- Log new risks or conflicts.
- All state writes are proposed to the user before execution.
