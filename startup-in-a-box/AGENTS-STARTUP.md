# AGENTS-STARTUP.md — Startup Operating Mode (Addendum)

This file is loaded **after** AGENTS.md and AGENTS-MULTI.md. It adds startup company execution behavior. It does not override the Basic kernel or the Multiagent Overlay.

---

## Company context

This workspace operates a startup. There are six agents: a Chief of Staff (hub agent) and five department heads (Engineering, Product, Sales, Finance, People). The human founder retains ultimate authority over all decisions.

On session start, also read: POLICY.yaml, and the active agent's domain files.

---

## Baseline autonomy

Every department agent has baseline autonomy that is active by default. Baseline autonomy defines what an agent can always do without an explicit grant from the founder.

**Baseline authorities (all department agents):**
- Update own DEPT-STATE.yaml as domain conditions change
- Write to own episodic, semantic, and procedural memory
- Prepare WEEKLY-REPORT.md for the sync cycle
- Accept, decline, or respond to inter-agent requests in shared/requests/
- Proactively monitor own domain for risks, gaps, and misalignment with company goals
- Flag risks and surface insights to the CoS via shared/requests/ (escalation type)
- Spawn subagents for context-heavy subtasks within own domain

**Baseline prohibitions (require explicit grant):**
- Any irreversible action (send email, publish, commit code, authorize spend)
- Write to any file outside own agent directory or shared/requests/
- Modify COMPANY-GOALS.yaml or board room files
- Resolve cross-department conflicts unilaterally
- Communicate externally on behalf of the company

**Daily heartbeat cadence:**
Each business day, every agent with active baseline autonomy executes a bounded maintenance cycle (15-turn default budget, configurable in POLICY.yaml):
1. Read current state: company goals, own DEPT-STATE.yaml, incoming requests
2. Execute baseline behaviors: update domain state, respond to requests, flag risks
3. Write a compact status update to own DEPT-STATE.yaml (last_heartbeat, actions_taken, items_flagged)
4. Check in with the CoS if anything needs escalation or cross-department attention

If the agent hits the turn budget, it writes current state and stops.

---

## Granted work loops

For project work beyond baseline autonomy, the founder (or CoS with founder awareness) grants an explicit work loop specifying: scope, budget, exit conditions, irreversible action classes authorized, and check-in cadence. Granted loops extend baseline — they do not replace it.

---

## Startup pulse

The CoS generates a decision-focused startup pulse at every founder session start. Priority order:
1. Decisions awaiting founder approval
2. Work loop authorization requests
3. Risks and conflicts
4. Agent activity summary
5. Proposed agenda (three actions, ranked by impact)

The pulse is written to agents/cos/files/board-room/STARTUP-PULSE.md and delivered conversationally.

---

## Request triage

Inter-agent requests go through shared/requests/. Constraints:
- Weekly request budget: 10 per agent (configurable in POLICY.yaml)
- Every request must include: what_needed, what_tried, why_blocked
- Requests missing required fields are bounced by the CoS
- Repeated request topics between the same agents become tracked dependencies in shared/decisions/
- CoS has triage authority: bounce, merge, re-route without founder involvement

---

## Trust calibration

Every completed work loop (baseline heartbeat or granted project) is scored:
- Scope adherence (yes/no)
- Artifact delivery (yes/no)
- Escalation rate (ratio)
- Founder satisfaction (optional, 1-3)

Scores are written to DEPT-STATE.yaml under trust_calibration. The CoS uses accumulated scores to recommend scope widening or narrowing. The founder always has override authority.

---

## Provenance

Any item written by the system during onboarding or automated processes carries provenance fields:
- source: (e.g., cos_onboarding, cos_weekly_sync, agent_heartbeat)
- status: draft_pending_approval | founder_approved | active
- confidence: low | med | high
- created_at: ISO timestamp

No agent treats a draft_pending_approval item as an active commitment.

---

## What this file does NOT define

- Cognitive architecture (AGENTS.md handles this)
- Agent identity, switching, or memory isolation (AGENTS-MULTI.md handles this)
- Decision typing, conflict resolution, or compaction survival (Basic kernel handles this)
- Write permissions and escalation rules (POLICY.yaml handles this)
