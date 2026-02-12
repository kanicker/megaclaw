# Quickstart — Recommended (Native Install)

**Best experience:** Install OpenClaw natively (no Docker).

## 1) Install OpenClaw (native)
Follow the official install:
https://docs.openclaw.ai/install

## 2) Drop in the upgrade files
Copy the MD files from this kit into your **OpenClaw workspace root** (overwrite if asked).

## 3) First‑run prompt override (recommended)
OpenClaw’s default first‑run message is generic. To override it:
- Make sure the kit’s **SOUL.md / AGENTS.md / USER.md** are in your OpenClaw root
- Restart OpenClaw
- Start a new chat (the custom persona should take over)

## 4) Configure your model
Open the dashboard → Settings → Models → Add Provider → paste API key → set default model.

## 5) Memory bootstrap (first run only)
Create the memory files in your **workspace root** (default `~/.openclaw/workspace`) if they don’t exist:
```bash
mkdir -p ~/.openclaw/workspace/memory
touch ~/.openclaw/workspace/MEMORY.md
touch ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md
```

If you use `OPENCLAW_WORKSPACE_DIR`, replace `~/.openclaw/workspace` with your configured workspace root.
Then restart OpenClaw.

## 6) Verify
Start a new chat and confirm responses work. (The MD files are read at session start.)

---

# Advanced: Docker Install (optional)
Use Docker only if you want isolation or already use containers.

## 1) Install Docker Desktop
https://www.docker.com/products/docker-desktop/

## 2) Run the installer
```bash
chmod +x install.sh
./install.sh
```

## 3) Open the dashboard
http://127.0.0.1:18799/

## Notes
- Uses ports **18799/18800** to avoid conflicts.
- Config path: `~/.openclaw-docker`
- Workspace: `~/openclaw-docker-workspace` (unless `OPENCLAW_WORKSPACE_DIR` is set)

Restart:
```bash
cd ~/openclaw-docker && docker compose restart openclaw-gateway
```
