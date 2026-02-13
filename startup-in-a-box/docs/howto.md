# How‑To — Operating OpenClaw v3.1

## Quick start
1. Copy the `company/` folder into your workspace.
2. Set real goals in `company/BOARD-ROOM/COMPANY-GOALS.yaml`.
3. Each department updates their `DEPT-STATE.yaml` during the week.
4. Before sync, each department completes `WEEKLY-REPORT.md`.
5. Run:
   ```bash
   python3 sync_v3.py
   ```
6. Review `company/BOARD-ROOM/COMPANY-PULSE-DRAFT.md`.
7. Chief of Staff finalizes:
   - `COMPANY-PULSE.md`
   - `BOARD-DECISIONS.md`
8. Publish directives back to department channels.

---

## Weekly rhythm (recommended)
**Mon–Thu:**
- Department heads update `DEPT-STATE.yaml` as work evolves

**Fri (or sync day):**
- Departments complete `WEEKLY-REPORT.md`
- Chief of Staff runs `sync_v3.py`
- Founder reviews decisions/risks

---

## Requirements
Install dependencies before running sync:
```bash
pip install -r requirements.txt
```

---

## Common pitfalls
- **Missing YAML sync block:** report will trigger a sync warning
- **Incomplete goals:** departments will drift without a clear north star
- **Skipping sync:** alignment degrades quickly
