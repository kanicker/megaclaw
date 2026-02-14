# Telemetry consent (opt-in)

OpenClaw Basic supports **local-only** telemetry that records **counts and timestamps**, not content.

Default: OFF

## What is recorded (local-only)
- install completed
- health-check runs (pass/fail counts)
- decision prompt shown (count)
- decision recorded (count)
- linter runs (issue counts)

## What is NOT recorded
- no chat text
- no email content
- no file contents
- no hostnames or device identifiers

## Where it is stored
If enabled, events are appended to:
- `telemetry/metrics.jsonl` under your workspace root

## How to enable
During bootstrap you will be asked. You can also set:
- `OPENCLAW_TELEMETRY_ENABLED=1`

## How to disable
- set `OPENCLAW_TELEMETRY_ENABLED=0`
or
- delete the `telemetry/` folder in your workspace
