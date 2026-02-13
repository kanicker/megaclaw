# Changelog — OpenClaw Startup-in-a-Box

## v3.2.1 (2026-02-12)
- Aligned SECURITY.md to the Authority & State Integrity logic (non-blocking, behavioral guardrails).
- Updated SELF-CHECK.md Step 5 to enforce cognitive vs organizational state boundaries and protected governance approval.
- Added or confirmed POLICY.yaml invariant: organizational truth lives exclusively in company/ state files.

## v3.1
- Introduced fenced YAML sync block in WEEKLY-REPORT.md templates for deterministic parsing.
- sync_v3.py parses fenced YAML sync blocks and reports warnings when missing or invalid.
- Added requirements.txt with PyYAML dependency for sync parsing.
