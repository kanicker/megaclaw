# Weekly Sync — Workflow Guide

## Purpose
Reconcile all department work against company goals. Detect misalignment, compile the company pulse, and surface decisions for the founder.

## When to run
- At the configured sync cadence (default: Friday) or when the founder requests it.
- The CoS executes this as a bounded work loop.

## Inputs
1. shared/MANIFEST.yaml — the agent roster (only agents with status: active are included)
2. COMPANY-GOALS.yaml — north star, goals, key results
3. Each active agent's WEEKLY-REPORT.md (agents/*/files/WEEKLY-REPORT.md)
4. Each active agent's DEPT-STATE.yaml (for priority cross-reference)
5. shared/requests/ — any unresolved cross-department requests
6. shared/decisions/ — any active cross-department decisions

## Roster filtering
Only read reports and state from agents listed as `status: active` in shared/MANIFEST.yaml. Skip any agent not in the manifest. Do not flag missing reports for agents that were never installed.

## Process
1. **Read all department reports.** Do not narrate this step.
2. **Cross-reference priorities.** For each department's stated priorities, verify they link to an active company goal. Flag any work not linked to a goal.
3. **Detect conflicts.** Look for: departments with contradicting priorities, multiple departments claiming the same resource or timeline, local decisions that affect other departments without coordination.
4. **Compile wins and misses.** Extract from each department's sync summary YAML block.
5. **Compile decisions needed.** Merge department requests to the board room with any unresolved escalations.
6. **Check request status.** Are there pending inter-agent requests that are overdue or stalled?
7. **Write COMPANY-PULSE.md.** The company-level summary: priorities, decisions, commitments, risks, misalignment watchlist.
8. **Write BOARD-DECISIONS.md.** Any new decisions or updates to existing decisions.
9. **Generate directive summaries.** For each department, write what the board decided that affects them.
10. **Flag items for founder review.** These appear in the next startup pulse.

## Output
Updated COMPANY-PULSE.md and BOARD-DECISIONS.md in agents/cos/files/board-room/.

## State writes
- All state writes are proposed to the founder via the startup pulse before execution.
- Decision propagation to departments happens only after founder approval.
