# OpenClaw Multiagent Overlay — v0.2

## Installation

**Step 1: Install the overlay into your workspace.**

```bash
bash INSTALLER/install.sh /path/to/your/workspace
```

If `$OPENCLAW_WORKSPACE_DIR` is set, you can just run `bash INSTALLER/install.sh`.

This creates the directory structure (`agents/`, `shared/`) and installs AGENTS-MULTI.md and MANIFEST.yaml. It does not modify kernel files. It creates a default "main" agent.

**Step 2: Create your agents.**

```bash
bash INSTALLER/create-agent.sh cos "Chief of Staff — coordination, priorities, decisions"
bash INSTALLER/create-agent.sh research "Research — literature review, synthesis, analysis"
bash INSTALLER/create-agent.sh dev "Development — architecture, implementation, testing"
```

Each command creates the agent's full directory (`SOUL.md`, `IDENTITY.md`, `MEMORY.md`, `memory/`, `files/`, `subagents/`) and registers it in `shared/MANIFEST.yaml`. Run it once per agent you want.

**Step 3: Add the injection directive to AGENTS.md.**

Find the Memory discipline section in AGENTS.md (the line that starts with "Memory files live in the workspace root") and add this line:

```
If `AGENTS-MULTI.md` exists in the workspace, read it and `shared/MANIFEST.yaml` now.
```

This tells the agent to load the multiagent overlay on every session start.

**Step 4: Customize your agents.**

Edit each agent's `agents/{id}/SOUL.md` to define its personality, domain expertise, and communication style. The starter SOUL.md is generic — make it specific.

**That's it.** Start a session. The agent reads the manifest, loads the hub agent's persona, and opens with a status check.

---

## What this is

Persistent agent roles for a single OpenClaw workspace. Each agent has its own persona, memory, and file space. One workspace, one context window, multiple identities with durable state.

This overlay also adds work loops (bounded autonomous multi-step execution) and subagent spawning (temporary workers for context-heavy subtasks).

## What problem it solves

Without this overlay, a single OpenClaw agent has one persona, one memory, and no way to maintain separate context for different kinds of work. Executive planning, deep research, and software development all compete for the same memory space and the same behavioral style. Over time, memory becomes a jumble of unrelated domains.

With this overlay, each domain gets its own agent with its own memory and persona. The research agent remembers what it researched. The dev agent remembers what it built. The CoS agent remembers what was decided. Switching between them is clean — no persona blending, no memory pollution.

## How it works

**Agents are persistent roles, not separate processes.** Each agent has a subdirectory with its own persona, memory, and file space. All agents share one GLOBAL-STATE.yaml (canonical state), one AGENTS.md (kernel), and one context window.

**Switching is explicit.** The user directs a switch ("switch to research") or the agent proposes one ("this looks like research work — switch?"). Personas don't blend. When you're the research agent, you think like the research agent.

**Memory is per-agent.** Each agent writes memory to its own directory. Cross-cutting information goes to the workspace-root MEMORY.md. This prevents domain pollution — research notes don't clutter dev memory.

**Work loops grant bounded autonomy.** Multi-step tasks run without per-step approval, within explicit scope, budget, and exit conditions. Irreversible actions (sending email, merging code) require the grant to name the specific action class.

**Subagents are disposable workers.** During a work loop, an agent can spawn a temporary subagent for a context-heavy subtask. The subagent reads a task definition, produces output, and terminates. No recursion.

---

## Planned for future releases

- **Multi-agent diagnostic tool** — manifest health, stale requests, orphaned subagents
- **Pre-built agent packs** — curated SOUL.md files for common roles with domain-specific personas and communication styles
- **CoS integration guide** — how CoS v3.0 workflows map to the multiagent model
