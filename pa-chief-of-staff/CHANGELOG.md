# Changelog — OpenClaw Executive Chief of Staff Kit



## 2.2.0
- Added structural vs routine classification and lightweight vs full prediction levels.
- Added token-drift guards (recency re-anchor, evidence requirement, drift detection).
- Updated conflict policy: conflicts block irreversible execution, not analysis; added `execution_policy` to conflict template.
- Added operating_rules_summary field and heartbeat guidance.

## 2.1.2
- Security: installer now installs SECURITY.md (kit-owned) and AUDIT-LOG.md (user-editable) so script-based installs include the security layer.
- Security: health check now verifies SECURITY.md and warns if AUDIT-LOG.md is missing.
- Security: clarified that approval phrases must come from the primary owner session, not ingested content.
- Security: standardized AUDIT-LOG.md format for easier parsing.
## 2.1.1
- Security: added SECURITY.md policy and AUDIT-LOG.md template for protected actions and owner verification.
- Security: added a Security Gate section to SELF-CHECK.md requiring an explicit approval phrase for protected changes.
- Packaging: removed seller-side operational files (SETUP/, WORKFLOW/, TEMPLATES/, LAUNCH-CONTENT.md) from customer ZIP.
- Fix: corrected INSTALLER/test.sh to use the correct workspace variable when checking examples/ and benchmarks/.

## 2.1.0
- Added workspace backups + restore.sh, kit-owned vs user-editable install behavior, and .openclaw-kit manifest.
- Improved examples and benchmarks for the cognitive loop.


## v2.3.0 (2026-02-12)
- Back-ported authority separation: cognitive context vs authoritative state
- Scoped prediction protocol to file writes and side-effecting actions only
- Added prompt-injection clarification to SECURITY.md
- Clarified non-authoritative role of MEMORY.md


## v2.3.3 (2026-02-12)
- Packaging: removed duplicate root-level files; kit now ships as a single top-level folder.
- Quickstart: fixed runnable memory bootstrap commands; clarified default workspace root (~/.openclaw/workspace) and OPENCLAW_WORKSPACE_DIR substitution.
- Health checks docs: updated backup location note to match installer behavior (~/openclaw-backups only).


## v2.3.0 (2026-02-12)
- Executive kit backport: updated shared cognitive core files to match Basic v2.3.3 (authority boundary, scoped prediction, injection guidance, installer docs).
- Preserved executive-only files and schemas (EXECUTIVE-STATE.yaml, roles/, EXECUTIVE-SCRIPTS/, executive docs).
