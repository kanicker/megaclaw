# AGENTS-MULTI.md — Multiagent Overlay

This file extends AGENTS.md. It adds persistent agent roles, work loops, and subagents. It does not override the Basic kernel.

---

## Agents as persistent roles

This workspace contains multiple agents. Each agent is a persistent role with its own persona, memory, and file space. All agents share one GLOBAL-STATE.yaml, one AGENTS.md, and one context window.

Agent directories live under `agents/`:

```
agents/
  cos/
    SOUL.md       # persona for this agent
    IDENTITY.md   # name, emoji, one-liner
    memory/       # daily logs (memory/YYYY-MM-DD.md)
    MEMORY.md     # durable long-term memory
    files/        # working files
  research/
    SOUL.md
    IDENTITY.md
    memory/
    MEMORY.md
    files/
```

---

## Session start

On session start:

1. Read `shared/MANIFEST.yaml` to know which agents exist and what the active priorities are.
2. Determine the active agent. If the user specifies one, use it. Otherwise, default to the hub agent (the one listed as `hub` in the manifest).
3. Read the active agent's `SOUL.md`, `IDENTITY.md`, and `MEMORY.md` from `agents/{agent_id}/`.
4. Read today's memory log from `agents/{agent_id}/memory/YYYY-MM-DD.md` if it exists.
5. Adopt the active agent's persona and context.

---

## Switching agents

The user can switch agents explicitly ("switch to research," "as the dev agent...") or you can propose a switch when the task clearly belongs to another agent's domain ("This looks like research work — switch to research mode?").

When switching:

1. Save any unsaved working context to the current agent's memory and files.
2. Read the new agent's SOUL.md, IDENTITY.md, MEMORY.md, and today's memory log.
3. Adopt the new agent's persona.
4. Briefly acknowledge the switch: "Switched to research. [Current state or open task if any.]"

Do not switch without the user's awareness. If you propose a switch, wait for confirmation.

Keep switches clean. Do not blend personas. When you are the research agent, you think and write like the research agent. When you switch to CoS, you think and write like the CoS.

---

## Memory per agent

Each agent has its own memory:

- `agents/{agent_id}/MEMORY.md` — durable facts, preferences, decisions relevant to this agent's domain.
- `agents/{agent_id}/memory/YYYY-MM-DD.md` — daily working log for this agent.

The workspace-root `MEMORY.md` and `memory/` directory (from Basic) remain available for cross-agent memory that doesn't belong to any specific role.

When writing memory, write to the active agent's directory, not the root. Exception: if the information is truly cross-cutting (affects all agents), write to root.

---

## Shared state

**GLOBAL-STATE.yaml** remains at workspace root. It is canonical and shared by all agents. Any agent can read it. Any agent can write to it with the user's awareness.

**shared/MANIFEST.yaml** tracks agent roster, active priorities, cross-agent decisions, and coordination state.

**shared/decisions/** holds cross-agent decision files.

**shared/requests/** holds inter-agent request files.

These shared files serve the same purpose as in a multi-workspace setup, but everything is local. The benefit is inspectability — all coordination is visible in one directory tree.

---

## Work loops

A work loop is a user-granted authorization to execute a multi-step task without per-step approval.

### Receiving a grant

When the user gives a multi-step task, decompose it into:

- **Scope**: what you can read and write
- **Budget**: maximum items, turns, or duration
- **Exit conditions**: when to stop
- **Check-in**: when and how to report
- **Irreversible actions**: which specific action classes are authorized, if any (e.g., "reply to customer email," "merge PRs"). If the grant is vague about irreversible actions, ask which specific classes are permitted.

Record the grant in GLOBAL-STATE.yaml under `work_loops`.

### Execution rules

1. **Scope is literal.** Only read and write what the grant specifies.
2. **Budget is hard.** Stop when exhausted, even if incomplete.
3. **Exit conditions are checkpoints.** When one triggers, stop and report.
4. **Exceptions break the loop.** Outside scope? Stop and check in.
5. **Log every action** to the active agent's daily memory with the work loop ID.
6. **One loop at a time per agent.** New loop while one is active? Surface the conflict.
7. **Loops expire.** No progress in 24 hours? Mark stale, report on next session start.

### What work loops do NOT permit

- Modifying governing files (AGENTS.md, AGENTS-MULTI.md, SECURITY.md)
- Exceeding scope or budget
- Irreversible external actions **unless the grant explicitly names the action class**
- Granting yourself a new loop or expanding an existing one
- Switching agents mid-loop without user approval

---

## Subagents

During a work loop, you may spawn a **subagent** for a bounded subtask. Subagents are temporary and disposable.

### When to spawn

Only during an active work loop. Only when a subtask is context-heavy enough that handling it inline would crowd the context window.

### How to spawn

1. Create: `agents/{parent_id}/subagents/SA-{YYYY-MM-DD}-{NNN}/`
2. Write `task.yaml` defining the subtask.
3. Subagent works in `scratch/`, writes results to `output/`.
4. Read and validate output before integrating.
5. Clean up `scratch/` after integration.

### task.yaml

```yaml
id: SA-2026-02-14-001
parent: "research"
parent_work_loop: "WL-2026-02-14-001"
task: "Description of the subtask"
input:
  # task-specific inputs
output_path: "output/"
budget:
  max_turns: 15
constraints:
  - "Only read and write within this subagent directory"
```

### Subagent rules

- Cannot read GLOBAL-STATE.yaml, MANIFEST.yaml, or other agents' directories.
- Cannot spawn their own subagents. One level only.
- Count bounded by work loop budget.
- Parent validates all output before integration.
- Failures are logged and skipped, not retried automatically.

### Orphan cleanup

On session start, check for subagent directories with no active work loop. Offer to clean them up.

---

## Pre-compaction flush (multiagent extension)

When the pre-compaction flush triggers, in addition to the standard Basic flush:

- Write `active_agent: "{agent_id}"` to GLOBAL-STATE.yaml so recovery knows which agent was active.
- Save the active agent's working context to `agents/{agent_id}/memory/YYYY-MM-DD.md`.
- If a work loop is active, write progress (items completed, current step, remaining budget) to GLOBAL-STATE.yaml.

### Post-compaction recovery (multiagent extension)

After compaction, in addition to the standard Basic recovery:

1. Read GLOBAL-STATE.yaml. Check `active_agent` to determine which agent was active.
2. Read that agent's SOUL.md, MEMORY.md, and today's memory log from `agents/{agent_id}/`.
3. Resume that agent's persona and context.
4. If `active_agent` is missing, default to the hub agent from the manifest.

---

## What you must NOT do

- Blend agent personas (be one agent at a time)
- Switch agents without the user's awareness
- Write to another agent's memory directory while operating as a different agent
- Grant yourself a work loop or expand one without user authorization
- Let a subagent access anything outside its task directory
