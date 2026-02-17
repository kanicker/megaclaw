# OpenClaw Startup in a Box — v2.0

## What this is

A preconfigured multiagent workspace that runs a startup's operating system. Five AI department heads work autonomously within their domains, coordinated by an AI Chief of Staff, governed by a human founder who retains ultimate authority.

Built on OpenClaw Basic v3.2 + Multiagent Overlay v0.2.

## What you get

**Six preconfigured agents** with personas, baseline autonomy, and domain state:
- Chief of Staff (hub) — coordination, decisions, founder interface
- CTO / Engineering — architecture, reliability, technical debt
- Head of Product — roadmap, specs, prioritization
- Head of Sales — pipeline, pricing, customer relationships
- Head of Finance — runway, budget, financial modeling
- Head of People — hiring, culture, team health

**Baseline autonomy** active by default — agents work daily without explicit grants.

**Decision-focused startup pulse** at every founder session — what needs your judgment, not what agents are doing.

**Proactive first-sync onboarding** — set goals, get a working company pulse within 24 hours.

**Trust calibration** — per-agent scoring that makes autonomy expansion mechanical, not subjective.

**Inter-agent coordination** — requests with quality gates and quotas, escalation protocol, weekly sync with conflict detection.

---


## Choose your agent roster

Startup in a Box ships with agent templates. You are not required to use all of them.

The Chief of Staff agent is required. All other agents are optional.

Supported starting models:
- Standard Startup: cos + engineering + product + sales + finance + people
- Content / Research: cos + marketing + research + social
- Consulting: cos + delivery + business_dev + operations
- Open-Source: cos + maintainer + community + documentation
- Nonprofit: cos + programs + fundraising + communications
- Minimal: cos + one domain agent
- Custom: cos + your own agent list

You can add, remove, rename, or disable agents later.

## Quick start (3 steps)

### 1. Prerequisites
Basic v3.2 and Multiagent Overlay v0.2 must be installed.

### 2. Install
```bash
bash INSTALLER/install.sh
```

### 3. Set goals and start
Edit `agents/cos/files/board-room/COMPANY-GOALS.yaml` with your north star and goals. Start a session. The CoS runs first-sync onboarding automatically.

---

## What happens in week one

**Day 1:** Set goals. CoS generates gap analysis, drafts department priorities (with provenance), activates all agents, runs baseline sync. You review the startup pulse and approve or adjust.

**Days 2-4:** Agents run daily heartbeats — monitoring domains, responding to requests, flagging risks. You review the startup pulse each session and make decisions that surface.

**Day 5:** CoS runs the first real weekly sync. You review the company pulse and set direction for week two.

**Week 2+:** Autonomy widens as trust scores accumulate. The startup pulse gets shorter as fewer things need your judgment.

---

## Compatibility

This product requires both the Basic v3.2 kernel and the Multiagent Overlay v0.2. It is not compatible with the Executive CoS Kit (they serve different use cases — CoS Kit is a personal assistant, this is a company operating system).

---

## What this system will not do

- **Replace human judgment** on consequential decisions. It surfaces options; you decide.
- **Execute in the real world by default.** Agents produce documents and analyses, not emails or commits, unless you explicitly grant irreversible action classes.
- **Guarantee good output.** AI agents are probabilistic. Trust calibration makes quality visible and adjustable.
- **Manage real humans.** If you have human employees, the AI agent is a planning tool, not a manager.
- **Scale itself.** Six departments is the v2.0 scope.
- **Work without goals.** Empty COMPANY-GOALS.yaml = drifting agents.

---

## File map

```
(inherited from Basic v3.2 — do not modify)
  AGENTS.md, GLOBAL-STATE.yaml, TOOLS/, etc.

(inherited from Multiagent Overlay v0.2)
  AGENTS-MULTI.md

(Startup in a Box)
  AGENTS-STARTUP.md       — startup behavioral addendum
  POLICY.yaml             — authority model and governance
  README-STARTUP.md       — this file
  CHANGELOG.md
  VERSION
  .openclaw-kit

  shared/
    MANIFEST.yaml          — agent roster (pre-populated)
    decisions/             — cross-department decisions
    requests/              — inter-agent requests

  agents/
    cos/                   — Chief of Staff (hub)
      SOUL.md, IDENTITY.md, MEMORY.md, memory/
      files/board-room/
        COMPANY-GOALS.yaml
        COMPANY-PULSE.md
        BOARD-DECISIONS.md
        STARTUP-PULSE.md
    engineering/           — CTO
    product/               — Head of Product
    sales/                 — Head of Sales
    finance/               — Head of Finance
    people/                — Head of People
      (each with SOUL.md, IDENTITY.md, MEMORY.md, memory/,
       files/DEPT-STATE.yaml, files/WEEKLY-REPORT.md,
       files/work-loop-templates/)

  workflows/
    weekly-sync.md
    startup-pulse.md
    escalation.md
    onboarding-first-sync.md
```


## Refine an agent role (optional)

Agents ship with working SOUL.md role definitions. You do not write them from scratch.
If you want adjustments, use the SOUL refinement workflow to make a small behavioral change,
preview a diff, and apply or discard.

See: workflows/soul-refinement.md
