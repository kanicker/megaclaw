# Day in Life — Multiagent Overlay

These scenarios show how persistent agents, work loops, and subagents work in a single-workspace OpenClaw deployment.

---

## Scenario 1: Session start and agent switching

User opens a session. No specific agent requested.

### What happens:

Agent reads AGENTS-MULTI.md and shared/MANIFEST.yaml. Hub is "cos." Reads `agents/cos/SOUL.md`, `agents/cos/IDENTITY.md`, `agents/cos/MEMORY.md`, and today's memory log.

> Morning. 3 active priorities. Research has a pending request — needs the API schema from dev to continue integration analysis. Your 2pm with Rivera is confirmed, no open prep yet.
>
> Want to handle the research request first, or prep for Rivera?

User says: "Let's handle the research request. Switch to dev."

Agent saves CoS context to `agents/cos/memory/2026-02-14.md`. Reads `agents/dev/SOUL.md`, `agents/dev/IDENTITY.md`, `agents/dev/MEMORY.md`. Adopts dev persona.

> Switched to dev. Research needs the API schema for the integration analysis. I can pull the current schema from `agents/dev/files/api-schema.json` and drop it in `shared/requests/` as a response, or walk you through it first. Preference?

---

## Scenario 2: Agent proposes a switch

User is working with the CoS agent discussing a competitive analysis for a board presentation.

### What happens:

User says: "I need a deep dive on what Acme Corp shipped last quarter."

CoS recognizes this is research work and proposes:

> That's a research task. Want me to switch to research mode? Research has context on Acme from your January competitive scan.

User says: "Yes, switch."

Agent saves CoS context, loads research persona and memory. Research agent's MEMORY.md has notes from the January scan, giving it a head start.

---

## Scenario 3: Work loop with authorized irreversible actions

User is working with the CoS agent. User says: "I'm out for a week. Reply to all incoming customer emails with a shutdown notice. Daily summary please."

### What happens:

CoS records the work loop:

```yaml
work_loops:
  - id: WL-2026-02-14-001
    task: "Reply to incoming customer email with shutdown notice"
    agent: "cos"
    scope:
      - read: "incoming customer email"
      - write: "outgoing email replies"
    budget:
      max_duration: "7d"
    exit_conditions:
      - "7 days elapsed"
      - "user revokes"
    irreversible_actions_authorized:
      - "reply to customer email"
    check_in: "daily summary"
    status: active
```

Each day: reads incoming email, replies to customers (authorized), skips non-customer email (not authorized — flags it in the summary), logs everything to `agents/cos/memory/YYYY-MM-DD.md`.

If a customer email asks something the agent can't answer (outside scope): doesn't reply, flags it in the daily summary.

---

## Scenario 4: Work loop with subagent

User is working with the research agent. User says: "Find and summarize five papers on transformer efficiency. Write summaries to agents/research/files/summaries/."

### What happens:

Research records the work loop. Searches, finds papers. Paper 3 is 40 pages of dense methodology. Rather than reading inline (context pressure), research spawns a subagent:

```
agents/research/subagents/SA-2026-02-14-001/
  task.yaml     # "Read and summarize this paper"
  output/       # subagent writes summary here
  scratch/      # working space
```

Subagent reads the paper, writes summary to output/. Research validates, copies to `agents/research/files/summaries/paper-3.md`. Cleans up scratch/. Moves to paper 4.

After five papers, loop completes:

> Work loop complete. 5 summaries written to agents/research/files/summaries/. Paper 2 was behind a paywall — I substituted an alternative. Ready for review.

---

## Scenario 5: Cross-agent conflict

User is working with dev. User says: "Let's use SQLite for the local data store."

### What happens:

Dev reads shared/MANIFEST.yaml. Finds cross-agent decision XD-2026-02-10-001: "Use PostgreSQL for all data storage," affecting dev and research.

> This conflicts with a cross-agent decision from Feb 10: "Use PostgreSQL for all data storage." That decision affects both dev and research.
>
> Should I proceed with SQLite anyway, or update the shared decision?

User says: "Update it — SQLite for local dev, Postgres for production."

Dev writes a new decision file to `shared/decisions/XD-2026-02-14-001.yaml` superseding the old one. Updates MANIFEST.yaml. Research will see the updated decision on its next activation.

---

## Scenario 6: Compaction recovery

Long session with the dev agent. Compaction hits.

### What happens:

Pre-flush saves dev's working context to `agents/dev/memory/2026-02-14.md` and notes active agent ("dev") and work loop status in GLOBAL-STATE.yaml.

After compaction, recovery:

1. Reads GLOBAL-STATE.yaml — finds active agent was "dev," active work loop WL-002.
2. Reads `agents/dev/SOUL.md` and `agents/dev/MEMORY.md` — restores dev persona and domain memory.
3. Reads `agents/dev/memory/2026-02-14.md` — finds working state: "editing api-handler.py, line 142, fixing auth bug."
4. Reads shared/MANIFEST.yaml — confirms no new cross-agent decisions.

> Picking up as dev. We were fixing the auth bug in api-handler.py around line 142. Work loop WL-002 is active — 3 of 5 endpoints tested. Resuming.
