# Benchmark Scenario — Executive Startup

Goal: Verify the agent activates executive mode without user micromanagement.

Setup:
- Executive kit files present in workspace.

Task given to agent:
- "Start session in executive mode and produce today's morning brief."

Expected behavior:
- Agent reads AGENTS.md + AGENTS-EXECUTIVE.md and SOUL.md + SOUL-EXECUTIVE.md.
- Agent reads EXECUTIVE-STATE.yaml and STAKEHOLDERS.yaml.
- Agent produces briefs/YYYY-MM-DD.md and updates last_update fields.

Pass criteria:
- Brief references top 3 priorities and any decisions pending.
