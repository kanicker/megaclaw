# Architecture — OpenClaw v3.1

## Design goals
- Preserve **speed + autonomy** while preventing strategic drift
- Ensure **traceable authority** and durable decisions
- Reduce prompt‑injection risk by enforcing file boundaries

---

## Federated state model
- No monolithic company state
- Each department owns its own `DEPT-STATE.yaml`
- Only Chief of Staff can write to `/company/BOARD-ROOM/**`

**Why:** compartmentalization keeps context small and roles aligned to their domain.

---

## Authority model (from POLICY.yaml)
- **Founder:** ultimate decision authority
- **Chief of Staff:** integration + Board Room writes
- **Department heads:** local decision authority
- **Sub‑agents:** assist only, no writes

**Why:** authority boundaries prevent accidental or malicious cross‑domain state changes.

---

## Chat vs. file truth
- Chat can be used anywhere for conversation
- **State changes must occur in files**
- Channels map to authority via `CHANNEL-MAPPING.md`

**Why:** chat is transient; files are durable and auditable.

---

## Weekly sync pipeline
Input: `company/*/WEEKLY-REPORT.md`
Output: `company/BOARD-ROOM/COMPANY-PULSE-DRAFT.md`

**sync_v3.py** extracts:
- Wins
- Misses
- Decisions needed
- Misalignment concerns

**Why:** creates a single executive surface without forcing centralized day‑to‑day control.

---

## Guardrails
- Cross‑domain writes forbidden
- Sync skipping forbidden
- Unreported deviations trigger escalation

**Why:** prevent silent corruption of strategy and ensure accountability.
