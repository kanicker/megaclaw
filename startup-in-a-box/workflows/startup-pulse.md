# Startup Pulse — Workflow Guide

## Purpose
Generate a decision-focused briefing for the founder at every session start. Answer one question: what needs the founder's judgment right now?

## When to run
- Every founder session start (automatic).
- When the founder asks for a status check.

## Inputs
1. shared/MANIFEST.yaml — the agent roster (only agents with status: active are included)
2. shared/decisions/ — pending cross-department decisions
3. shared/requests/ — pending escalations and overdue requests
4. Each active agent's DEPT-STATE.yaml — last_heartbeat, trust scores, flagged items
5. COMPANY-GOALS.yaml — for context on what's at risk
6. POLICY.yaml — for overload thresholds

## Roster filtering
Only include agents listed as `status: active` in shared/MANIFEST.yaml. Skip any agent not in the manifest. Do not report missing data for agents that were never installed.

## Process
1. **Scan for pending decisions.** Check shared/decisions/ for items with status requiring founder approval.
2. **Check work loop requests.** Are any agents requesting broader scope or new action classes?
3. **Scan for risks and conflicts.** Check DEPT-STATE.yaml flagged items, overdue requests, misalignment flags.
4. **Compile agent activity.** Brief per-agent summary: what each agent accomplished since last session, current focus, any blockers.
5. **Check for overload.** If pending decisions exceed the threshold in POLICY.yaml for consecutive sessions, flag organizational overload.
6. **Propose agenda.** Three recommended actions for this session, ranked by impact.
7. **Check for unapproved drafts.** If any DEPT-STATE.yaml priorities have status: draft_pending_approval, include a consolidated "Approve draft priorities" section.

## Output
Written to agents/cos/files/board-room/STARTUP-PULSE.md and delivered conversationally.

## Strict priority order
1. Decisions awaiting founder approval
2. Work loop authorization requests
3. Risks and conflicts
4. Agent activity summary
5. Proposed agenda

The founder should be able to stop reading after section 1 if they're short on time and still have handled the most important items.
