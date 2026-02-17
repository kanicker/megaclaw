# Changelog — OpenClaw Startup in a Box

## 2.0.1 — 2026-02-15

### Added
- Agent roster selection (Standard, Content/Research, Consulting, Open-Source, Nonprofit, Minimal, Custom)
- Custom agent creation wizard documentation
- SOUL refinement onboarding flow with preview and rollback guidance
- Additional agent template packs (marketing/research/social, consulting, open-source, nonprofit)
- Dynamic, roster-aware week one success criteria

### Changed
- Installer now supports `--roster` and `--agents` to install only selected agents (CoS always included)
- README updated to reflect role flexibility and SOUL refinement
- MANIFEST.yaml generated from selected roster


## v2.0.0 (2026-02-15)

Ground-up rebuild on Basic v3.2 + Multiagent Overlay v0.2. Replaces v1 entirely.

### Architecture
- Five-layer architecture: Basic Kernel → Multiagent Overlay → Company State → Coordination → Agent Roster
- Six preconfigured agents with persistent identity, memory, and domain state
- Federated state model from v1 preserved, now backed by real agent infrastructure
- POLICY.yaml defines authority, budgets, escalation rules, and guardrails

### Baseline Autonomy
- All agents ship with baseline autonomy active by default
- Daily heartbeat cadence (15-turn budget) ensures agents work without founder sessions
- Burst multiplier (2-3x for 24-72 hours) for real-world surges, auto-reverts
- Baseline authorities: self-maintenance, request handling, proactive domain monitoring
- Baseline prohibitions: irreversible actions, cross-domain writes, external communications

### Startup Pulse
- Decision-focused founder interface generated at every session start
- Priority order: decisions → authorizations → risks → activity → proposed agenda
- Written to STARTUP-PULSE.md and delivered conversationally

### First-Sync Onboarding
- CoS automatically runs four-phase onboarding after goals are set
- Gap analysis, provenance-marked draft priorities, agent activation, baseline sync
- Week one success criteria with measurable benchmarks and failure indicators

### Coordination
- Inter-agent requests with weekly quotas (10 per agent), quality gates, dependency linking
- Escalation protocol: agent → CoS triage → founder decision
- Enhanced weekly sync as CoS work loop with cross-reference and conflict detection

### Trust Calibration
- Per-loop scoring: scope adherence, artifact delivery, escalation rate, founder satisfaction
- CoS recommends scope widening (3+ passes) or narrowing (2+ breaches)
- Founder always has override authority

### What's Gone from v1
- sync_v3.py (replaced by CoS weekly sync work loop)
- Flat AGENTS.md and SOUL.md (replaced by per-agent personas)
- SELF-CHECK.md, PREDICTION-PROTOCOL.md, CONSISTENCY-RESOLVER.md (Basic kernel handles these)
- company/ directory tree (state files now live inside agent directories)
- CHANNEL-MAPPING.md (channels are transport, authority lives in POLICY.yaml)