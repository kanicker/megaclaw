# Executive Chief of Staff Kit — Start Here

This product layers an executive operating system on top of the OpenClaw Cognitive Upgrade foundation.

## What you get (executive-only additions)
- EXECUTIVE-STATE.yaml: priorities, commitments, decisions, delegations, risks, metrics
- STAKEHOLDERS.yaml: lightweight relationship tracker
- DECISIONS.md: decision log
- MEETINGS.md: meeting prep, notes, and follow-up templates
- COMMS-DRAFTS.md: reusable executive communication patterns
- roles/: Chief of Staff, Executive Assistant, Analyst, Comms, Ops
- EXECUTIVE-SCRIPTS/: daily brief and weekly review generators
- AGENTS-EXECUTIVE.md and SOUL-EXECUTIVE.md: behavioral activation
- STATE-INTEGRATION.md: ledger relationship contract
- examples/: worked samples

## How it behaves differently than the Basic kit
- On startup, the agent must read executive state and route tasks through roles/.
- Priorities are capped at three and are treated as binding constraints.
- Decisions, delegations, and stakeholder touches are first-class artifacts.

## Quick start
1) Copy all kit files into your workspace root (installer can do this).
2) Populate EXECUTIVE-STATE.yaml with your current top three priorities.
3) Add key stakeholders to STAKEHOLDERS.yaml.
4) Start a session by telling the agent: "Run executive startup: read AGENTS.md, AGENTS-EXECUTIVE.md, SOUL.md, SOUL-EXECUTIVE.md, SELF-CHECK.md, and produce today's brief."

## Notes
- The executive kit is designed to remain file-first and framework-agnostic.
- If the openclaw CLI is not installed, scripts still create brief skeletons; the agent can fill them in.

## Security and change control
This kit does not secure your device or workspace. It adds an owner-verification gate for protected actions that would change core kit behavior, and a lightweight AUDIT-LOG.md for approved changes. See SECURITY.md.
