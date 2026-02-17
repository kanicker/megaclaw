# Choose Your Agent Roster — Workflow Guide

## Purpose
Make it explicit that Startup in a Box ships with agent templates, not mandated departments.
The founder chooses the initial organization shape before any agents activate.

## When It Runs
Immediately after installation, before the first session.

## Supported Roster Modes
- standard: cos + engineering + product + sales + finance + people
- content: cos + marketing + research + social
- consulting: cos + delivery + business_dev + operations
- opensource: cos + maintainer + community + documentation
- nonprofit: cos + programs + fundraising + communications
- minimal: cos + one domain agent (provided via --agents)
- custom: cos + founder-defined agents (provided via --agents)

## Output
- Creates only the selected agent directories
- Generates shared/MANIFEST.yaml to match the selected roster
- Baseline autonomy applies only to active agents
