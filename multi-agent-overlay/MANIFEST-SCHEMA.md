# MANIFEST-SCHEMA.md — Agent Roster Field Definitions

---

## hub

The `agent_id` of the default coordinating agent. When no specific agent is requested, the system defaults to this agent on session start.

```yaml
hub: "cos"
```

---

## agents

All persistent agents in this workspace. Each agent has a subdirectory under `agents/`.

```yaml
agents:
  - agent_id: "cos"
    role: "Chief of Staff — coordination, priorities, decisions"
    status: active
  - agent_id: "research"
    role: "Research — literature review, synthesis, analysis"
    status: active
```

- `agent_id`: Short identifier. Must match the directory name under `agents/`.
- `role`: One-line description of the agent's domain.
- `status`: `active`, `paused`, or `retired`.

---

## active_priorities

Top-level priorities. Maximum 5.

```yaml
active_priorities:
  - id: P-001
    title: "Ship Q1 product update"
    owner: "cos"
    due: "2026-03-15"
    agents_involved: ["dev", "research"]
```

- `owner`: The agent_id responsible for tracking this priority.
- `agents_involved`: Which agents contribute work.

---

## cross_agent_decisions

Decisions that affect multiple agents. Full decision files live in `shared/decisions/`.

```yaml
cross_agent_decisions:
  - id: XD-2026-02-14-001
    summary: "Use PostgreSQL for all data storage"
    affects: ["dev", "research"]
    status: ACTIVE
```

Same lifecycle as Basic decisions: ACTIVE or SUPERSEDED.

---

## pending_requests

Requests from one agent to another, routed through the hub agent.

```yaml
pending_requests:
  - id: REQ-research-2026-02-14-001
    from: "research"
    subject: "Need API schema from dev"
    urgency: normal
```

---

## conflicts

Cross-agent conflicts.

```yaml
conflicts:
  - description: "Research and dev chose different data formats"
    between: ["research", "dev"]
    status: open
    resolution: ""
```

---

## last_update

ISO timestamp. Agents should note staleness if older than 24 hours.
