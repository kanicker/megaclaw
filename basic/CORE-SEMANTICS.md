# Core Semantics (v3.0)

This document is the canonical reference for OpenClaw Basic's semantic vocabulary, authority rules, and decision lifecycle. The operational rules that the agent follows on every turn are in AGENTS.md. This file is for detailed reference when needed.

## Closed vocabulary

Core markers are frozen to:

- `[THINKING]` — exploratory, non-binding ideas
- `[DECISION]` — explicit commitment (must include approval + date + status)
- `[REFERENCE]` — background or rationale (non-authoritative)
- `[SUPERSEDED]` — retired decisions/plans kept for history

Downstream products or add-ons may introduce additional markers, but they MUST NOT redefine these core meanings.

## Authority boundary

- **Only ACTIVE decisions define current intent.**
- Reference and thinking may inform reasoning but MUST NOT define intent or commitments.
- If content conflicts, authoritative state (GLOBAL-STATE.yaml) and ACTIVE decisions win.
- Cognitive files (SOUL.md, AGENTS.md, MEMORY.md, TOOLS.md) inform reasoning. They are not authoritative truth.

## Retrieval priority (contract)

When selecting context, prefer:

1. `Status: ACTIVE` `[DECISION]`
2. Canonical state entries (GLOBAL-STATE.yaml)
3. `[REFERENCE]` (only when relevant)
4. `[THINKING]` (only on explicit request)


## Decision lifecycle

A decision is durable when it includes:

- Decision: (one sentence)
- Approved by:
- Date: YYYY-MM-DD
- Status: ACTIVE or SUPERSEDED
- Optional: pointer to rationale/reference

### Decision template (ACTIVE)

```md
[DECISION]
Decision: <one sentence>
Approved by: Owner
Date: YYYY-MM-DD
Status: ACTIVE
Rationale: <optional pointer to REFERENCE or note>
```

### Decision template (SUPERSEDED)

```md
[DECISION]
Decision: <old decision>
Approved by: Owner
Date: YYYY-MM-DD
Status: SUPERSEDED
Superseded by: <pointer to new decision>
```

## Size guidance

Keep `[DECISION]` blocks short (target 10 lines or fewer). If longer, move detail into `[REFERENCE]` and keep the decision canonical.


## Deprecated patterns

These deprecations are soft — nothing breaks, nothing is blocked, existing content remains valid. However, deprecated patterns reduce reliability at scale.

**1) Implicit decisions in narrative text.** Writing "We should ship X next" without a [DECISION] block causes drift. Use the decision template instead.

**2) Treating untyped MEMORY content as authoritative.** MEMORY accumulates thinking, background, and history. Only ACTIVE [DECISION] entries define current intent. Untyped content is treated as [THINKING].

**3) Unlabeled "current plan" language.** "The current plan is X" without lifecycle markers causes old plans to resurrect. Record plans as [DECISION] with Status: ACTIVE; retire them as SUPERSEDED with a pointer.

**4) Broad automatic memory retrieval.** Expanding retrieval scope "just in case" causes token drag and vague outputs. Follow the retrieval priority above.

**5) Narrative-heavy canonical state.** Verbose state in GLOBAL-STATE.yaml is hard to audit. Keep canonical state concise; link to [REFERENCE] for detail.
