# Quickstart — Executive Chief of Staff Kit

This kit extends the Basic Cognitive Upgrade Kit with executive operating state, roles, cadence, and Chief of Staff behavior.

## 0) Read this first
Open **EXECUTIVE-README.md** in the kit root. It explains what is executive-only and how the system behaves differently.

## 1) Install OpenClaw (native)

**Workspace root:** Use your workspace root (default `~/.openclaw/workspace`). If you set `OPENCLAW_WORKSPACE_DIR`, replace paths accordingly.
Follow the official install:
https://docs.openclaw.ai/install

## 2) Install this kit into your workspace
If you use the installer in INSTALLER/install.sh, it will:
- Back up your workspace
- Copy kit files into your workspace root
- Write a .openclaw-kit manifest so tools know you are in executive mode

If you install manually, copy all kit files into your **OpenClaw workspace root**.

## 3) First-run prompt override (recommended)
To ensure the Chief of Staff persona loads:
- Make sure the kit’s **SOUL.md / SOUL-EXECUTIVE.md / AGENTS.md / AGENTS-EXECUTIVE.md / USER.md** are in your workspace root
- Restart OpenClaw
- Start a new chat (the custom persona should take over)

## 4) Executive startup command (start every day)
At the beginning of a session, tell the agent:

"Run executive startup: read AGENTS.md, AGENTS-EXECUTIVE.md, SOUL.md, SOUL-EXECUTIVE.md, SELF-CHECK.md, and produce today's brief."

## 5) Minimal state bootstrap (first run only)
In your workspace root:
- Fill out your top three priorities in EXECUTIVE-STATE.yaml
- Add key stakeholders to STAKEHOLDERS.yaml

## 6) Configure your model
Open the dashboard → Settings → Models → Add Provider → paste API key → set default model.
