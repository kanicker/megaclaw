# OpenClaw Startup‑in‑a‑Box v3.1

OpenClaw is a **file‑first, federated operating system** for AI‑run startups. It lets a human founder speak directly with AI department heads while preserving strategic coherence and preventing silent drift. Chat is transport; files are truth.

**Why it exists:** LLMs are powerful but unstable. This system anchors decisions and execution in explicit, durable state so AI teams can move fast **without corrupting company intent**.

---

## What’s included (and why)
- **company/POLICY.yaml** — constitution and authority boundaries (prevents prompt‑level hijacking)
- **company/BOARD-ROOM/COMPANY-GOALS.yaml** — canonical goals/KRs for alignment
- **company/BOARD-ROOM/COMPANY-PULSE.md** — official executive pulse
- **company/BOARD-ROOM/BOARD-DECISIONS.md** — durable decision ledger
- **company/*/DEPT-STATE.yaml** — local departmental state (autonomy without drift)
- **company/*/WEEKLY-REPORT.md** — structured weekly sync input
- **sync_v3.py** — generates **COMPANY-PULSE-DRAFT.md** from weekly reports
- **CHANNEL-MAPPING.md** — chat topology mapping roles to authority
- **requirements.txt** — runtime deps (PyYAML)

---

## Quick start
1. Copy the `company/` folder into your workspace.
2. Update `BOARD-ROOM/COMPANY-GOALS.yaml` with real goals.
3. During the week, department heads update their `DEPT-STATE.yaml`.
4. Before sync, each department completes `WEEKLY-REPORT.md`.
5. Run:
   ```bash
   python3 sync_v3.py
   ```
6. Review `BOARD-ROOM/COMPANY-PULSE-DRAFT.md`, then update `COMPANY-PULSE.md` and `BOARD-DECISIONS.md`.
7. Post directives back to department channels and update local `DEPT-STATE.yaml` as needed.

---

## v3.1 changes (intent)
- **Fenced YAML Sync Summary** — makes weekly sync deterministic for the parser
- **Legacy fallback** — preserves backward compatibility if YAML is missing
- **Sync warnings** — surfaces missing/malformed reports immediately
- **requirements.txt** — makes sync parsing install‑safe and explicit

---

## Expanded docs
See the `/docs` folder for:
- `overview.md` — what this system is and why it works
- `howto.md` — operating procedures and weekly rhythm
- `architecture.md` — system design and authority model
- `rationale.md` — intent and tradeoffs behind each feature

## Included layers
This package is a combined standalone bundle:
- Cognitive Upgrade layer (root): behavioral protocols, prediction loop, and guardrails (SOUL.md, AGENTS.md, MEMORY.md, GLOBAL-STATE.yaml, SELF-CHECK.md, SECURITY.md).
- Startup-in-a-Box layer (company/): federated org state, department sandboxes, and weekly sync tooling.

Note on invariants:
Invariants are rules enforced by the agent behavior and governance policy. They do not imply the POLICY.yaml file itself never changes.
