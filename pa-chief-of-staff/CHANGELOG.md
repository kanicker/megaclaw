# Changelog — OpenClaw PA / Chief of Staff Kit


## v3.1.0 (2026-02-15)

Alignment release. Brings the CoS kit in line with Basic v3.2.0's structured memory taxonomy and context pressure monitoring. Also fixes naming conventions, adds missing schema reference, and closes the compaction recovery gap.

### Basic v3.2.0 alignment
- Requires: `basic >= 3.2.0` (was `basic >= 3.1.0`).
- AGENTS-COS.md state write rules now reference Basic's three-tier memory taxonomy (episodic, semantic, procedural) with executive-specific guidance for each tier.
- Daily pulse workflow (step 8) adds memory maintenance — scan recent daily logs for durable facts to promote to MEMORY.md.
- Daily pulse workflow (step 9) adds context pressure check using Basic's `openclaw_context_monitor.py`.
- Weekly review workflow (step 8) adds memory hygiene — prune old episodic logs, deduplicate MEMORY.md, update stale procedural files.
- Daily pulse no longer claims to "replace" HEARTBEAT.md — it extends it.
- Installer default workspace path updated to `~/.openclaw/workspace` (was old Docker path).

### Naming convention fix
- `COS-AGENTS.md` → `AGENTS-COS.md` (matches `AGENTS-{overlay}` convention used by Basic and Multiagent Overlay).
- `COS-SOUL.md` → `SOUL-COS.md` (matches `SOUL-{overlay}` convention).
- `COS-README.md` → `README-COS.md` (consistent with above).
- All internal references updated.

### Injection directive
- README-COS.md now includes Step 3: add injection directive to AGENTS.md so the agent auto-loads CoS files on session start without manual prompting.
- Installer quick start updated to reference the injection directive.

### New files
- `EXECUTIVE-STATE-SCHEMA.md` — field reference for EXECUTIVE-STATE.yaml. Schema was previously only in the design doc (Word file); now it's in the workspace where the agent can reference it.
- `CHANGELOG.md` — this file.

### Compaction recovery extension
- AGENTS-COS.md now specifies that during Basic's 5-step post-compaction recovery, the agent must also read EXECUTIVE-STATE.yaml and STAKEHOLDERS.yaml. Includes stale-state detection (last_update > 24h) and executive context announcement.
- Pre-compaction flush now includes saving executive context to EXECUTIVE-STATE.yaml alongside the daily memory log.

### Incompatibility documented
- README-COS.md now includes a Compatibility section stating the CoS kit is not compatible with the Multiagent Overlay. They are independent branches from Basic.

### File summary
- Added: EXECUTIVE-STATE-SCHEMA.md, CHANGELOG.md (2 files)
- Renamed: COS-AGENTS.md → AGENTS-COS.md, COS-SOUL.md → SOUL-COS.md, COS-README.md → README-COS.md (3 files)
- Modified: AGENTS-COS.md, README-COS.md, INSTALLER/install.sh, workflows/daily-pulse.md, workflows/weekly-review.md, examples/daily-pulse-example.md, MIGRATION-FROM-V2.md, VERSION, .openclaw-kit (9 files)
- Total files: 26 (was 24)


## v3.0.0 (2026-02-14)

Ground-up re-architecture. Positions the PA/CoS as a pure domain layer on top of Basic v3.1 cognitive kernel.

### Architecture
- Eliminated competing authority: CoS no longer ships its own AGENTS.md, SOUL.md, SELF-CHECK.md, GLOBAL-STATE.yaml, PREDICTION-PROTOCOL.md, or CONSISTENCY-RESOLVER.md.
- EXECUTIVE-STATE.yaml demoted from "peer" to "subordinate convenience index." GLOBAL-STATE.yaml is canonical. Always.
- STATE-CONTRACT.md defines one-page authority hierarchy.
- COS-AGENTS.md (now AGENTS-COS.md) loads as addendum after AGENTS.md, explicitly delegates cognition to kernel.

### New in v3.0
- Five role modules (Chief of Staff, EA, Analyst, Comms, Ops) in `roles/`.
- Three workflow guides (Daily Pulse, Weekly Review, Meeting Cycle) in `workflows/`.
- Decision capture discipline with commitment signal detection and anti-signals.
- STAKEHOLDERS.yaml with tier-based relationship tracking.
- MIGRATION-FROM-V2.md guided checklist.

### Removed from v2
- All kernel-competing files (own AGENTS.md, SOUL.md, SELF-CHECK.md, etc.)
- 8-step preflight/4-step postflight ceremony
- Prediction-before-action for routine tasks
- STATE-INTEGRATION.md (replaced by STATE-CONTRACT.md with reversed authority)
