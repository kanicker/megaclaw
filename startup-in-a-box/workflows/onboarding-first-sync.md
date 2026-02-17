# First-Sync Onboarding — Workflow Guide

## Purpose
Automatically bootstrap the startup after the founder sets company goals. Produces a working company pulse within 24 hours.

## Trigger
Runs automatically on the first session after COMPANY-GOALS.yaml is populated and agents are activated.

## Process

### Phase 1: Gap Analysis
1. Read COMPANY-GOALS.yaml.
2. Scan each department's DEPT-STATE.yaml (all will be empty templates).
3. For each company goal, identify: which departments are involved, what each department needs to define (priorities, capacity, risks), what's missing.
4. Write gap analysis to agents/cos/files/board-room/ONBOARDING-GAPS.md.

### Phase 2: Draft Initial Priorities (with Provenance)
1. Based on company goals, draft top-3 priorities for each department.
2. Write drafts to each department's DEPT-STATE.yaml with provenance:
   - source: cos_onboarding
   - status: draft_pending_approval
   - confidence: low | med | high
   - created_at: ISO timestamp
3. For each department, identify the first useful granted work loop.
4. Include a consolidated "Approve draft priorities" section in the startup pulse.

### Phase 3: Activate Baseline Autonomy
1. Activate all active agents in the selected roster with default baseline autonomy.
2. Each agent reads its draft priorities and begins domain monitoring.
3. Agents that find immediate gaps or risks flag them via shared/requests/.

### Phase 4: Baseline Sync
1. Run the weekly sync workflow even with empty or minimal department reports.
2. The sync captures starting state: what's defined, what's missing, what needs founder input.
3. Write the first COMPANY-PULSE.md and STARTUP-PULSE.md.
4. Present the startup pulse to the founder.

## Week One Success Criteria
- Within 24 hours: draft priorities, gap analysis, first pulse, all agents active, baseline sync complete.
- Within 5 business days: one artifact per department, three resolved requests, one proactive risk detected, first real weekly sync, trust scores for three agents.

## Failure Indicators
- Any department with zero artifacts after 5 days.
- Startup pulse consistently empty.
- Request volume at zero after 5 days.
- Founder has approved zero drafts after 3 days.


## Week One Success Criteria (Roster-Aware)

These outcomes are measurable and adapt to the selected roster.

### Within 24 Hours of Setting Goals
- Draft priorities exist for every active domain agent, provenance-marked as draft_pending_approval
- Gap analysis exists in the board room for active agents and goals
- Startup pulse delivered with a consolidated approval section for draft priorities
- Baseline autonomy heartbeat has run at least once for each active agent

### Within 5 Business Days
- Each active domain agent has produced at least one concrete artifact tied to a company goal
- At least one inter-agent request has been filed and resolved for each collaborating agent pair
- CoS has surfaced at least one risk, misalignment, or decision requiring founder input
- Trust calibration scores exist for at least half of active agents

### Failure Indicators
- Any active agent with zero artifacts after 5 days
- Startup pulse consistently empty
- Zero inter-agent requests across active agents
- Founder has approved zero draft priorities after 3 days

### Explicit Non-Failure
- Disabled or unselected agents producing nothing
