# Changelog — OpenClaw Cognitive Upgrade Kit (Basic)


## v3.2.0 (2026-02-15)

Memory quality and session awareness release. v3.1 added compaction survival infrastructure. v3.2 adds structured memory guidance and runtime context monitoring so the agent writes better memory and knows when to save before compaction hits.

### Structured memory taxonomy
- AGENTS.md "Writing memory" section rewritten with three-tier taxonomy: episodic (daily logs — what happened), semantic (MEMORY.md — what I know), procedural (named workspace files — how to do things). Maps onto existing file structure — no new directories, no migration needed.
- Each tier includes guidance on when to write, what to write, and when to retrieve.
- Writing discipline rules: don't duplicate across tiers, distill episodic into semantic when durable, prune MEMORY.md at ~200 lines.
- HEARTBEAT.md memory upkeep now includes episodic-to-semantic promotion during review and MEMORY.md size management.

### Context pressure monitor (new)
- Added `TOOLS/openclaw_context_monitor.py` — estimates token pressure from injected workspace files (kernel files, GLOBAL-STATE, daily memory, addenda) against the context window.
- `check` command returns exit code 0 (safe), 1 (warning at 15%), 2 (critical at 25%) for heartbeat integration.
- `report` command shows detailed breakdown by file category with recommendations.
- Supports `--json` output for scripted heartbeats, `--context-window` for non-200k models, custom `--warn` and `--critical` thresholds.
- Complements the compaction diagnostics tool: monitor runs during sessions to trigger proactive saves, diagnostics runs after to measure how well compaction survival worked.
- HEARTBEAT.md session health now references the context monitor as the preferred check.

### Why this matters
- Without the taxonomy, agents dump everything into MEMORY.md or daily logs with no structure. Over weeks, memory files become noisy and retrieval degrades. The taxonomy gives the agent a decision framework for every write.
- Without the context monitor, the agent only discovers context pressure reactively (compaction happens, then recovery). The monitor catches growing files early, before they crowd out conversation context.

### File summary
- Added: TOOLS/openclaw_context_monitor.py (1 file)
- Modified: AGENTS.md, HEARTBEAT.md, VERSION, .openclaw-kit, CHANGELOG.md (5 files)
- Total files: 34 (was 33)


## v3.1.0 (2026-02-14)

Infrastructure release. v3.0 built the governance layer; v3.1 adds the infrastructure that prevents the problems OpenClaw users actually hit.

### Problem-first redesign
- README rewritten around three user problems (memory loss, decision contradictions, unauthorized actions) instead of feature descriptions
- Example scenario now leads with compaction survival, showing before/after with and without the kit

### Compaction diagnostics (new)
- Added `TOOLS/openclaw_compaction_diagnostics.py` — parses session JSONL transcripts and produces a compaction health report: flush success rate, recovery success rate, per-event detail, and actionable recommendations
- Diagnostic tool supports: `report` (full analysis), `summary` (one-liner), `--json` (for dashboards/scripting), `--days N` (time filter), `--session FILE` (single session)
- Diagnostic tool includes `hook-stub` command that generates a ready-to-use `session:compacted` hook for when OpenClaw ships that event (GitHub #11799)
- When hook is deployed, it auto-triggers the recovery protocol and logs to kit telemetry — zero manual intervention
- Agent logs compaction recovery outcomes to telemetry (when enabled) for longitudinal tracking
- COMPACTION-SURVIVAL.md now includes "Measuring compaction survival" section with diagnostic tool usage and healthy benchmark targets (flush > 80%, recovery > 70%)

### Compaction survival
- Added `openclaw.recommended.jsonc` — recommended OpenClaw config addressing the top 3 user complaints: compaction memory loss, unsearchable memory, and group session security
- Added `COMPACTION-SURVIVAL.md` — practical guide explaining what compaction is, why defaults lose context, and how to configure OpenClaw to survive it
- AGENTS.md "Memory discipline" section rewritten as "Memory discipline and compaction survival" — agent now writes working state proactively during long sessions, not just during flush
- AGENTS.md now includes **post-compaction recovery protocol** — a 5-step structured recovery that the agent runs when it detects compaction happened (re-read GLOBAL-STATE.yaml, re-read daily memory, run memory_search, announce recovery and gaps, never silently proceed with vague intent)
- AGENTS.md now includes context budget section — agent knows it consumes ~2,300 tokens per turn and manages accordingly
- HEARTBEAT.md now includes session health monitoring: token usage checks, proactive state saves when context runs hot
- COMPACTION-SURVIVAL.md documents the flush failure case and the recovery protocol as a workaround for the missing `session:compacted` hook (OpenClaw #11799)
- Pre-compaction flush prompts are kit-aware: save ACTIVE decisions, open predictions, unresolved conflicts, and GLOBAL-STATE.yaml — not just "lasting notes"
- Example now includes a flush-failure scenario showing partial recovery

### Installer improvements
- bootstrap.sh now tells user to apply recommended config (the most important post-install step)
- health-check.sh now checks for memoryFlush and reserveTokensFloor in openclaw.json
- BOOTSTRAP.md now prompts the agent to suggest recommended config if not applied
- COMPACTION-SURVIVAL.md added to health-check required files list

### File summary
- Added: openclaw.recommended.jsonc, COMPACTION-SURVIVAL.md, TOOLS/openclaw_compaction_diagnostics.py (3 files)
- Modified: AGENTS.md, HEARTBEAT.md, BOOTSTRAP.md, README.md, examples/day-in-life-basic.md, INSTALLER/bootstrap.sh, INSTALLER/bootstrap.ps1, INSTALLER/health-check.sh, VERSION, .openclaw-kit, CHANGELOG.md, TOOLS/openclaw_lint_decisions.py, TOOLS/openclaw_resolve_decisions.py, TOOLS/telemetry.py, TOOLS/advanced/telemetry_report.py (15 files)
- Total files: 33 (was 30)


## v3.0.0 (2026-02-14)

Major consolidation release. Restructured around OpenClaw's injection model — the operational contract now lives entirely in AGENTS.md (auto-injected every turn) instead of being spread across 14 files that required explicit reads.

### Architecture changes
- AGENTS.md is now the complete operational contract: prediction-before-action, conflict policy, decision typing, authority boundaries, preflight checklist, ask-vs-act heuristics, decision detection, postflight, and drift detection — all inline.
- SELF-CHECK.md, CORE-PATTERNS.md, PREDICTION-PROTOCOL.md, CONSISTENCY-RESOLVER.md, ERROR-DELTA-UPDATER.md, and DEPRECATIONS.md are eliminated. Their content is consolidated into AGENTS.md (operational rules) and CORE-SEMANTICS.md (reference definitions).
- CORE-SEMANTICS.md is now the single reference doc for semantic vocabulary, decision lifecycle, decision templates, and deprecated patterns.
- SOUL.md trimmed — prediction-before-action rule removed (now in AGENTS.md), no duplication.
- HEARTBEAT.md trimmed to essential checks and drift guard.

### New files
- IDENTITY.md added (OpenClaw-native agent identity: name, emoji, one-liner).
- BOOTSTRAP.md added (OpenClaw-native first-run onboarding — auto-injected once, then deleted).

### Onboarding
- First-run onboarding now uses OpenClaw's native BOOTSTRAP.md injection instead of asking users to paste a message.
- Bootstrap scripts updated to inform users that BOOTSTRAP.md handles first-run automatically.

### Tooling
- All tool docstrings updated to v3.0.
- Decision collision resolver clearly marked as power-user tool in README.

### Removed files
- SELF-CHECK.md (consolidated into AGENTS.md preflight checklist)
- CORE-PATTERNS.md (consolidated into AGENTS.md)
- PREDICTION-PROTOCOL.md (consolidated into AGENTS.md)
- CONSISTENCY-RESOLVER.md (consolidated into AGENTS.md postflight)
- ERROR-DELTA-UPDATER.md (consolidated into AGENTS.md postflight)
- DEPRECATIONS.md (consolidated into CORE-SEMANTICS.md)
- DECISION-TEMPLATE.md (consolidated into CORE-SEMANTICS.md)
- SAFETY-PRINCIPLES.md (covered by AGENTS.md safety + OpenClaw system prompt)
- BENCHMARK-HARNESS.md (no runnable tests existed)
- MEMORY-SYSTEM-GUIDE.md (described the kit's own contents — redundant)
- README-START-HERE.md (merged into README.md)
- CONSTITUTION.md (deprecated since v2.0)
- INSTALLER/install.sh (OpenClaw installation is not this kit's job)
- INSTALLER/test.sh (tested Docker install, not the kit)
- INSTALLER/daily-prediction.sh (broken against current OpenClaw CLI)
- INSTALLER/QUICKSTART.md (replaced by ONBOARDING.md)
- INSTALLER/DAILY-PREDICTIONS.md (docs for removed script)
- INSTALLER/README-README.md (internal-only doc)
- INSTALLER/HEALTH-CHECKS.md (inlined into ONBOARDING.md)
- INSTALLER/doctor.sh (marginal value)
- benchmarks/ directory (no runnable benchmarks)
- examples/conflict-resolution-example.md, error-delta-example.md, prediction-example.md (too trivial)

### Installer
- health-check.sh updated for v3 file list.
- bootstrap.sh and bootstrap.ps1 updated to reference AGENTS.md instead of SELF-CHECK.md.
- ONBOARDING.md is now the single onboarding doc.
- SECURITY.md updated: protected actions list matches v3 files; removed references to deleted files and knowledge/ folder.

### File count
- v2.5.3: 51 files
- v3.0.0: 25 files

### What did NOT change
- GLOBAL-STATE.yaml concept and schema
- Decision typing vocabulary ([THINKING], [DECISION], [REFERENCE], [SUPERSEDED])
- Authority boundary (cognitive vs authoritative)
- Security model (honest about scope, approval flow)
- Telemetry (local-only, off by default)
- All tools (linter, resolver, telemetry, pre-commit hook)
- USER.md, TOOLS.md, AUDIT-LOG.md


## v2.5.3 (2026-02-14)
- Fix: added missing `import datetime` in openclaw_resolve_decisions.py.
- Fix: updated VERSION and .openclaw-kit to reflect actual release version.
- Fix: bootstrap scripts now read kit version dynamically from VERSION file.
- Fix: bootstrap.ps1 falls back to native PowerShell health checks when bash is unavailable.
- Fix: restore.sh default workspace path now matches bootstrap default.
- Fix: health-check.sh AUDIT-LOG.md check moved to independent section.
- Lean: removed duplicate section from PREDICTION-PROTOCOL.md.
- Lean: replaced inline duplicated content in SELF-CHECK.md with pointers.
- Lean: removed unused import from telemetry_report.py.
- Packaging: removed deprecated CONSTITUTION.md.


## v2.5.2 (2026-02-14)
- Lean core: moved telemetry report generator to TOOLS/advanced/telemetry_report.py.
- Onboarding: bootstrap.sh supports OPENCLAW_ASSUME_YES=1 for non-interactive runs.
- Docs: clarified CORE-SEMANTICS (authority) vs CORE-PATTERNS (behavioral defaults).
- Docs: reduced prominence of doctor.sh.


## v2.5.1 (2026-02-14)
- Tooling: added TOOLS/openclaw_resolve_decisions.py.
- Docs: updated CORE-PATTERNS.md and README.md with resolver usage.


## v2.5.0 (2026-02-14)
- Onboarding: added bootstrap.sh and bootstrap.ps1 (no Docker required).
- Onboarding: added ONBOARDING.md and .env.example.
- Support: added doctor.sh for best-effort bootstrap.
- Telemetry: added opt-in local-only telemetry tools.
- Tooling: added optional pre-commit hook sample.


## v2.4.1 (2026-02-14)
- Docs: added DEPRECATIONS.md and CORE-PATTERNS.md.
- Tools: added optional advisory linter.


## v2.4.0 (2026-02-13)
- Core: added CORE-SEMANTICS.md with closed semantic vocabulary and authority boundaries.
- Core: introduced optional semantic markers and decision lifecycle guidance.
- Self-check: documented retrieval priority and decision detection prompt.
- Docs: added README.md with v2.4 release notes; added DECISION-TEMPLATE.md.
- Installer: ensured scripts default to OPENCLAW_WORKSPACE_DIR or ~/.openclaw/workspace.
