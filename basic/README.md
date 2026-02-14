# OpenClaw Cognitive Upgrade Kit — Basic (v3.1)

A workspace overlay for OpenClaw that fixes three problems:

**1. Your agent forgets everything during long sessions.** Context compaction summarizes older messages and loses details. This kit gives the agent a structured state file (GLOBAL-STATE.yaml) that lives on disk and survives compaction, plus a compaction-aware flush that saves working state before context is destroyed.

**2. Your agent contradicts its own past decisions.** Without explicit markers, old plans and new plans coexist in memory with no way to tell which is current. This kit adds decision typing — `[THINKING]` vs `[DECISION]` with `Status: ACTIVE` or `SUPERSEDED` — so the agent knows what's exploratory and what's committed.

**3. Your agent takes unauthorized actions from ingested content.** Emails, web pages, and group chat messages can trick the agent into modifying files or running commands. This kit treats all ingested content as data (not instructions) and gates protected changes behind an explicit approval phrase.

## Quick start

Unzip this kit into your OpenClaw workspace root (default `~/.openclaw/workspace`) and run bootstrap from there. OpenClaw auto-injects files from the workspace — if the kit is somewhere else, the agent won't see it.

macOS/Linux:
```bash
bash INSTALLER/bootstrap.sh
```

Windows PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\INSTALLER\bootstrap.ps1
```

Then **apply the recommended config** — this is the most important step:

```bash
# Review the recommended settings
cat openclaw.recommended.jsonc

# Copy the sections you want into your config
# At minimum, copy the compaction + memoryFlush block
nano ~/.openclaw/openclaw.json

# Restart
openclaw gateway restart
```

`BOOTSTRAP.md` runs automatically on the agent's first session and walks it through the kit's rules.


## What's in this kit

**Auto-injected by OpenClaw every turn** (~2,300 tokens):
- **AGENTS.md** — operating contract: prediction rules, compaction-aware memory discipline, conflict policy, decision typing, authority boundaries
- **SOUL.md** — persona and tone
- **IDENTITY.md** — agent name and emoji
- **USER.md** — user profile template
- **TOOLS.md** — environment-specific notes
- **MEMORY.md** — long-term memory with decision markers
- **HEARTBEAT.md** — periodic checks, token monitoring, drift guard
- **BOOTSTRAP.md** — first-run onboarding (auto-injected and deleted by OpenClaw; if your environment doesn't support this, paste "Read BOOTSTRAP.md and follow the first-run tasks" to your agent)

**Canonical state (on disk, survives compaction):**
- **GLOBAL-STATE.yaml** — goals, constraints, conflicts, predictions — the agent's compaction firewall

**Configuration:**
- **openclaw.recommended.jsonc** — compaction, memoryFlush, memorySearch, and sandbox settings that address the most common OpenClaw problems

**Reference docs (read on demand):**
- **COMPACTION-SURVIVAL.md** — what compaction is, why it loses context, how to survive it
- **CORE-SEMANTICS.md** — decision typing vocabulary, lifecycle, retrieval priority, deprecated patterns
- **SECURITY.md** — threat model, protected actions, prompt injection guard
- **GLOBAL-STATE-SCHEMA.md** — ledger field definitions and examples
- **AUDIT-LOG.md** — change log for protected actions

**Optional tools:**
- `TOOLS/openclaw_compaction_diagnostics.py` — parses session transcripts and reports compaction survival rates, flush success/failure, and recovery quality (see below)
- `TOOLS/openclaw_lint_decisions.py` — advisory linter for decision records
- `TOOLS/openclaw_resolve_decisions.py` — decision collision resolver (power-user tool for workspaces with many decisions)
- `TOOLS/telemetry.py` — local-only event logger (opt-in, default off)
- `TOOLS/advanced/telemetry_report.py` — local telemetry summary
- `TOOLS/hooks/pre-commit.sample` — optional Git pre-commit hook


## Compaction diagnostics

After running for a few days, check whether your compaction config is working:

```bash
# Full report across all recent sessions
python3 TOOLS/openclaw_compaction_diagnostics.py report --days 7

# Quick one-liner
python3 TOOLS/openclaw_compaction_diagnostics.py summary

# JSON output for scripting/dashboards
python3 TOOLS/openclaw_compaction_diagnostics.py report --json --days 7

# Generate the session:compacted hook stub (for when OpenClaw ships it)
python3 TOOLS/openclaw_compaction_diagnostics.py hook-stub --output hooks/compaction-hook.js
```

The report tells you: how many compaction events occurred, whether the pre-compaction flush fired successfully, whether the agent read state files after compaction (recovery), and specific recommendations if something's wrong.

## The recommended config matters

The workspace files (AGENTS.md, GLOBAL-STATE.yaml, etc.) give the agent better rules to follow. But rules alone don't prevent memory loss — you also need OpenClaw's infrastructure configured correctly.

The `openclaw.recommended.jsonc` file in this kit sets:
- **memoryFlush.enabled: true** with kit-aware prompts that save decisions and structured state, not just raw notes
- **reserveTokensFloor: 40000** — triggers compaction earlier, giving more time to save
- **softThresholdTokens: 8000** — triggers the flush earlier still
- **sandbox.mode: "non-main"** — group/channel sessions run in Docker, so prompt injection from group chats can't access your filesystem
- **memorySearch** — makes memory files semantically searchable so the agent can find relevant context from weeks ago

Without these settings, the workspace files are governance without infrastructure. With them, you get both.


## Telemetry (opt-in, local-only)

Telemetry is OFF by default. If enabled, events are stored locally at `telemetry/metrics.jsonl`. Details: `INSTALLER/telemetry-consent.md`.


## Decision collision resolver (power-user tool)

For workspaces with many decisions, you can scan for collisions. Most users won't need this — the linter covers the common case.

```bash
python3 TOOLS/openclaw_resolve_decisions.py scan --workspace "$OPENCLAW_WORKSPACE_DIR" --kit_dir .
python3 TOOLS/openclaw_resolve_decisions.py apply --workspace "$OPENCLAW_WORKSPACE_DIR" --kit_dir .
```
