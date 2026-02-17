# MIGRATION-FROM-V2.md — Guided Migration Checklist

This guide helps existing v2 users migrate to v3. It can be used as a self-serve checklist or as a guided session where the agent walks you through each step.

---

## Prerequisites

- Basic v3.1 is installed and working (check `.openclaw-kit` for `kit: basic`, version 3.1+)
- You have a backup of your v2 workspace

---

## Step 1: Install v3 CoS files

Run the v3 CoS installer. It will:
- Detect Basic v3.1
- Install only CoS domain files (it never touches kernel files)
- Create workspace directories (roles/, workflows/, briefings/)

---

## Step 2: Migrate your priorities

Open your v2 `EXECUTIVE-STATE.yaml` and your new v3 `EXECUTIVE-STATE.yaml` side by side.

Copy your priorities, commitments, delegations, risks, and cadence into the v3 format. The schema is similar but v3 adds:
- `global_state_ref` on commitments (link to decision ID in GLOBAL-STATE)
- `stakes` on pending decisions
- `cadence` section for recurring obligations

---

## Step 3: Migrate your stakeholders

Copy stakeholder entries from v2 `STAKEHOLDERS.yaml` to v3 `STAKEHOLDERS.yaml`. The format is nearly identical. Verify each has a tier (A/B/C) and a next-touch date.

---

## Step 4: Migrate decisions (the important step)

This is where v3 differs most from v2.

**In v2**, decisions lived in `DECISIONS.md` as the primary record.
**In v3**, decisions live in `GLOBAL-STATE.yaml` as typed decision blocks. `DECISIONS.md` is just a view.

For each entry in your v2 DECISIONS.md:

1. **Is it still active?** If yes, create a typed decision block in GLOBAL-STATE.yaml:
   ```yaml
   - id: D-YYYY-MM-DD-NNN
     decision: "What was decided"
     decided_by: "Who"
     date: "When"
     context: "Brief context"
     rationale: "Why"
     reversible: true/false
     review_date: "When to revisit"
     status: ACTIVE
   ```
2. **Is it no longer relevant?** Mark it as SUPERSEDED with a note, or simply don't migrate it.
3. **Was it never really a decision?** (Just a discussion point or idea) — don't migrate it. This is the zombie plan cleanup.

**Guided session option:** Start a session and say:
> "I'm migrating from CoS v2. Read my old DECISIONS.md and help me identify which items should become formal decisions in GLOBAL-STATE, which are superseded, and which were never actual decisions."

---

## Step 5: Clean up v2-only files

The following v2 files are now handled by the Basic kernel and should be removed from your workspace to avoid confusion:

- `SELF-CHECK.md` (kernel provides this)
- `PREDICTION-PROTOCOL.md` (kernel provides this)
- `ERROR-DELTA-UPDATER.md` (kernel provides this)
- `CONSISTENCY-RESOLVER.md` (kernel provides this)
- `MEMORY-SYSTEM-GUIDE.md` (kernel provides this)
- `BENCHMARK-HARNESS.md` (kernel provides this)
- `GLOBAL-STATE-SCHEMA.md` (kernel defines the schema)
- `CONSTITUTION.md` (already deprecated, fully removed)
- `HEARTBEAT.md` (replaced by daily-pulse workflow)
- `AGENTS-EXECUTIVE.md` (replaced by AGENTS-COS.md)
- `SOUL-EXECUTIVE.md` (replaced by SOUL-COS.md)
- `STATE-INTEGRATION.md` (replaced by STATE-CONTRACT.md)

Also remove the v2 `EXECUTIVE-SCRIPTS/` directory. Workflows are now documented guides, not shell scripts.

---

## Step 6: Verify

Start a session and tell the agent:

> "Run a daily pulse. Confirm you're reading GLOBAL-STATE.yaml, EXECUTIVE-STATE.yaml, and STAKEHOLDERS.yaml correctly."

Check that:
- [ ] The pulse references your migrated priorities
- [ ] Active decisions are visible from GLOBAL-STATE
- [ ] No references to v2-only files appear
- [ ] The agent does not narrate its file-reading process
- [ ] State writes are proposed, not executed silently

---

## Rollback

If anything goes wrong, restore from your backup. The v3 installer creates a backup before making changes.
