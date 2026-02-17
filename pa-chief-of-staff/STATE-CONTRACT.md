# STATE-CONTRACT.md — Authority Hierarchy

This document defines the relationship between state files in the PA/Chief of Staff product.

---

## The rule

**GLOBAL-STATE.yaml is canonical. Always.**

Every decision, commitment, constraint, and conflict that matters lives in GLOBAL-STATE.yaml. No other file has authority to override it.

---

## File hierarchy

| File | Role | Authority |
|------|------|-----------|
| GLOBAL-STATE.yaml | Durable ledger | **Canonical.** Source of truth for decisions, commitments, constraints, conflicts. |
| EXECUTIVE-STATE.yaml | Executive index | **Subordinate.** Convenience view for daily executive work. |
| DECISIONS.md | Decision view | **Generated.** Curated view of the decision register. Not authoritative. |
| STAKEHOLDERS.yaml | Relationship index | **Reference.** Real commitments to stakeholders go to GLOBAL-STATE. |
| COMMS-DRAFTS.md | Drafting surface | **Ephemeral.** Drafts only. No authority. |
| BRIEFINGS/ | Meeting artifacts | **Ephemeral.** Briefs and memos. No authority. |
| Daily memory logs | Narrative fallback | **Fallible.** May be compacted. Not authoritative. |

---

## Conflict resolution

If EXECUTIVE-STATE.yaml conflicts with GLOBAL-STATE.yaml:

1. GLOBAL-STATE wins.
2. The conflict is surfaced to the user immediately.
3. The agent proposes a resolution but does not act unilaterally.

If narrative memory (conversation, daily logs) conflicts with state files:

1. State files win.
2. The agent acknowledges the discrepancy and asks the user to clarify.

---

## Write rules

- Decisions are written to GLOBAL-STATE.yaml first. A lightweight copy may appear in DECISIONS.md as a view.
- EXECUTIVE-STATE.yaml is updated as a convenience. It never contains commitments that are absent from GLOBAL-STATE.
- No artifact file (COMMS-DRAFTS, BRIEFINGS, etc.) is required to survive compaction.
- GLOBAL-STATE.yaml must survive compaction. This is a kernel guarantee, not a CoS responsibility.

---

## Why this matters

In v2, STATE-INTEGRATION.md declared that executive priorities "supersede" global goals for daily execution. This created ambiguous authority — the executive layer could override the cognitive layer.

v3 reverses this. The executive layer is always subordinate. This eliminates an entire class of "which file wins?" failures and makes the system predictable under compaction.
