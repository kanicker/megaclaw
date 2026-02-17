# OpenClaw PA / Chief of Staff Kit — v3.1

## What this is

An executive operating system that layers on top of the OpenClaw Basic v3.2 cognitive kernel. It helps leaders think, decide, and follow through — reliably — by turning conversation into durable, governed action that survives time, interruptions, and context loss.

## What you get

**State management:**
- EXECUTIVE-STATE.yaml — your priorities, commitments, delegations, risks, and cadence
- STAKEHOLDERS.yaml — lightweight relationship tracker
- STATE-CONTRACT.md — one-page authority contract (GLOBAL-STATE is always canonical)

**Behavioral addenda:**
- AGENTS-COS.md — executive operating mode (loaded after AGENTS.md)
- SOUL-COS.md — executive tone and judgment (loaded after SOUL.md)

**Five role modules** in `roles/`:
- Chief of Staff, Executive Assistant, Analyst, Comms, Ops

**Three workflow guides** in `workflows/`:
- Daily Pulse, Weekly Review, Meeting Cycle

**Templates and surfaces:**
- DECISIONS.md — decision register view
- COMMS-DRAFTS.md — executive communication templates
- MEETINGS.md — meeting prep and follow-up templates
- `briefings/` — folder for meeting briefs

**Migration support:**
- MIGRATION-FROM-V2.md — guided checklist for v2 users

---

## Quick start (10 minutes)

### 1. Prerequisites
Basic v3.2 must be installed. Check with:
```
cat .openclaw-kit
```
You should see `kit: basic` and version 3.2 or higher.

### 2. Install
Run the CoS installer:
```
bash INSTALLER/install.sh
```
This adds CoS files alongside Basic. It never modifies kernel files.

### 3. Add injection directive to AGENTS.md
Open your workspace `AGENTS.md` and add this line at the top, after the first heading:

```markdown
**CoS extension loaded.** On every session start, also read: AGENTS-COS.md, SOUL-COS.md, EXECUTIVE-STATE.yaml, STAKEHOLDERS.yaml. Then run the daily pulse workflow.
```

This ensures the agent loads executive behavior automatically instead of requiring a manual prompt each session.

### 4. Populate your state
Open `EXECUTIVE-STATE.yaml` and fill in:
- Your top three priorities (with success criteria and due dates)
- Any active commitments
- Any pending decisions

Open `STAKEHOLDERS.yaml` and add your key relationships with tiers and next-touch dates.

### 5. Start a session
The agent will automatically read your CoS files (via the injection directive) and open with a daily pulse: priorities, decisions due, commitments at risk, and three proposed actions.

If the injection directive is not set, you can manually tell the agent:
> "Read AGENTS-COS.md, SOUL-COS.md, and run a daily pulse."

---

## How it works

### Authority hierarchy
GLOBAL-STATE.yaml is canonical. Always. EXECUTIVE-STATE.yaml is a convenience index. If they conflict, GLOBAL-STATE wins. See STATE-CONTRACT.md.

### Decision lifecycle
The product's core discipline is distinguishing thinking from deciding:
1. **Detection** — the agent notices commitment language
2. **Proposal** — the agent proposes a typed decision block
3. **Confirmation** — the user confirms or edits
4. **Recording** — the decision is written to GLOBAL-STATE.yaml
5. **Monitoring** — daily pulse and weekly review surface stale or conflicting decisions
6. **Supersession** — old decisions are marked SUPERSEDED, never deleted

### Compaction resilience
Narrative memory is fallible by design. The product does not pretend to remember. On session start or after context loss, the agent recovers from state files and says so honestly.

---

## File map

```
(inherited from Basic v3.2 — do not modify)
  AGENTS.md
  GLOBAL-STATE.yaml
  TOOLS/openclaw_context_monitor.py
  [all kernel governance files]

(CoS domain files)
  AGENTS-COS.md           — executive behavioral addendum
  SOUL-COS.md             — executive tone addendum
  STATE-CONTRACT.md       — authority hierarchy contract
  EXECUTIVE-STATE.yaml    — executive convenience index
  EXECUTIVE-STATE-SCHEMA.md — field reference for EXECUTIVE-STATE
  STAKEHOLDERS.yaml       — relationship tracker
  DECISIONS.md            — decision register view
  COMMS-DRAFTS.md         — communication templates
  MEETINGS.md             — meeting templates
  README-COS.md           — this file
  CHANGELOG.md            — version history
  MIGRATION-FROM-V2.md    — v2 migration guide
  VERSION                 — version number
  .openclaw-kit           — kit manifest

  roles/
    chief-of-staff.md
    executive-assistant.md
    analyst.md
    comms.md
    ops.md

  workflows/
    daily-pulse.md
    weekly-review.md
    meeting-cycle.md

  briefings/              — meeting briefs (created as needed)
  examples/               — populated examples for reference
```

---

## Upgrading from v2

See MIGRATION-FROM-V2.md for a guided checklist.

---

## Compatibility

This product is a standalone branch from the Basic kit. It is **not compatible** with the Multiagent Overlay. The CoS assumes it owns the workspace — session start, role routing, and executive state management. The Multiagent Overlay assumes multiple peer agents share the workspace. These are different operating models. Install one or the other on top of Basic, not both.

---

## Design principles

- **Domain layer, not competing kernel.** CoS adds executive workflows. It does not redefine memory, authority, or compaction. Basic's three-tier memory taxonomy (episodic, semantic, procedural) is used as-is for executive knowledge management.
- **Single source of truth.** GLOBAL-STATE.yaml is canonical. Everything else is a view.
- **Compaction is assumed.** Durable intent lives on disk, not in tokens. Basic's context pressure monitor provides early warning.
- **Decisions over conversations.** Thinking is exploration. Deciding is commitment. The product enforces the boundary.
- **Human authority preserved.** The system never acts autonomously. It proposes, the human confirms.
