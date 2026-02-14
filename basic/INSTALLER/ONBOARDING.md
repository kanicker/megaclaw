# Onboarding (Basic)

## Quick start (macOS/Linux)

From the kit folder:

```bash
bash INSTALLER/bootstrap.sh
```

## Quick start (Windows PowerShell)

From the kit folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\INSTALLER\bootstrap.ps1
```

## What bootstrap does
- Chooses a workspace root: `$OPENCLAW_WORKSPACE_DIR` if set, otherwise `~/.openclaw/workspace`
- Creates required directories (`memory/`)
- Bootstraps `MEMORY.md` and daily memory log if missing
- Runs the health check
- Optionally enables local-only telemetry (default off)
- Supports non-interactive mode: `OPENCLAW_ASSUME_YES=1 bash INSTALLER/bootstrap.sh`

## Prerequisites
- OpenClaw installed and running (see https://docs.openclaw.ai/install)
- Python 3 (for optional tools)

## Next step

Start a new chat with your agent. `BOOTSTRAP.md` runs automatically on the first session — it walks the agent through the kit's rules and deletes itself afterward.

If you need to re-run onboarding manually, paste this into your agent:

> Please read AGENTS.md and CORE-SEMANTICS.md from this kit. Confirm you will follow retrieval priority and decision typing. Then summarize what you will do first.

## Manual setup (if not using bootstrap)

```bash
mkdir -p ~/.openclaw/workspace/memory
touch ~/.openclaw/workspace/MEMORY.md
touch ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md
```

Copy the kit files into your workspace root. Restart OpenClaw.

## Health check

```bash
bash INSTALLER/health-check.sh
```

Checks: core files present, memory folder exists, GLOBAL-STATE.yaml structure, AUDIT-LOG.md presence.

## Restore from backup

```bash
bash INSTALLER/restore.sh
```

Lists available backups and restores the one you choose.
