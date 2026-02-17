# Changelog — OpenClaw Multiagent Overlay

## v0.2.0 — Single-workspace redesign (2026-02-14)

### What changed from v0.1

v0.1 assumed multiple OpenClaw instances with separate workspaces per agent. This doesn't match the actual deployment model — one OpenClaw instance, one workspace, one container.

v0.2 redesigns around a single workspace. Agents are persistent roles with subdirectories under `agents/`, each with its own persona, memory, and file space. All agents share one GLOBAL-STATE.yaml, one context window, and one compaction cycle.

### What's in this release

- **AGENTS-MULTI.md** — persistent agent roles, switching behavior, work loops, subagents, compaction survival extension
- **shared/MANIFEST.yaml** — agent roster, priorities, cross-agent decisions
- **MANIFEST-SCHEMA.md** — field definitions
- **Installer** — non-interactive, creates directory structure, default agent, shared files
- **Examples** — six scenarios: session start, agent switching, work loop with irreversible actions, work loop with subagent, cross-agent conflict, compaction recovery

### Architecture decisions

- One workspace, agents as subdirectories — not separate OpenClaw instances
- GLOBAL-STATE.yaml shared by all agents (canonical, at workspace root)
- Per-agent memory prevents domain pollution across roles
- Role switching is explicit (user directs or agent proposes with confirmation)
- Work loops with graduated irreversible-action authorization
- Subagents: one level, no recursion, parent validates output

### Removed from v0.1

- AGENTS-HUB.md — hub behavior is now handled by AGENTS-MULTI.md since there's one agent process
- MULTI-STATE-CONTRACT.md — simplified; authority is described inline in AGENTS-MULTI.md
- Multi-workspace installer — replaced with single-workspace non-interactive installer
- Symlink-based shared directory — shared/ is now just a subdirectory

### Planned for future releases

- Agent creation wizard (interactive new-agent setup with domain templates)
- Multi-agent diagnostic tool (manifest health, stale requests, orphaned subagents)
- Pre-built agent packs (starter personas for common roles)
- CoS integration guide (how CoS workflows extend with multiagent)

### File summary

- AGENTS-MULTI.md, MANIFEST-SCHEMA.md, README.md, CHANGELOG.md (4 docs)
- shared/MANIFEST.yaml, shared/decisions/README.md, shared/requests/README.md (3 shared)
- examples/day-in-life-multi.md (1 example)
- INSTALLER/install.sh, VERSION, .openclaw-kit (3 infra)
- Total: 11 files
