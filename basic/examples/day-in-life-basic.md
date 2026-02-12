# Day in the Life (Basic) — End-to-End Example

This is a single, complete cycle showing how the Basic kit is supposed to operate:
prediction → action → unexpected outcome → error-delta → conflict detection → resolution.

## Scenario
User request: “Update the memory directory convention to be workspace-root/memory everywhere, and make the daily prediction script respect OPENCLAW_WORKSPACE_DIR.”

### 0) Session start (agent loads state)
Agent reads: AGENTS.md, SOUL.md, MEMORY.md, GLOBAL-STATE.yaml, PREDICTION-PROTOCOL.md, SELF-CHECK.md, CONSISTENCY-RESOLVER.md.

### 1) Preflight: log prediction (GLOBAL-STATE.yaml)
Append to `predictions`:

- date: 2026-02-12
  action: "Standardize memory path to $OPENCLAW_WORKSPACE_DIR/memory and update daily-prediction.sh accordingly"
  expected: "All docs and scripts reference the same memory directory; daily script works on macOS and Linux"
  risk: med

SELF-CHECK passes:
- prediction logged ✅
- conflicts cleared ✅
- state loaded ✅
- safety check ✅ (no destructive external actions)

### 2) Act: change files
Action taken:
- Update daily-prediction.sh to resolve workspace dir using OPENCLAW_WORKSPACE_DIR with a default fallback.
- Update any doc references that still point to ~/.openclaw/memory.

### 3) Postflight: unexpected outcome
What happened:
- The script now resolves WORKSPACE_DIR, but a doc still references the old location, creating an inconsistency.

### 4) Error-Delta (ERROR-DELTA-UPDATER.md format)
What we predicted:
- All docs and scripts would reference the same memory directory.

What happened:
- daily-prediction.sh uses $OPENCLAW_WORKSPACE_DIR/memory, but DAILY-PREDICTIONS.md still mentions ~/.openclaw/memory.

Delta update:
- Fix DAILY-PREDICTIONS.md to match the standard.
- Add a consistency check note: “Docs must match scripts for memory paths.”

### 5) Consistency Resolver: log conflict and resolve
Log a conflict to GLOBAL-STATE.yaml under `conflicts`:

- date: 2026-02-12
  conflict: "Memory path mismatch between DAILY-PREDICTIONS.md and daily-prediction.sh"
  impact: "Users may create memory files in the wrong location"
  status: open

Resolution:
- Update DAILY-PREDICTIONS.md to reference $OPENCLAW_WORKSPACE_DIR/memory with fallback default.
- Mark conflict resolved.

Update conflict status:

- date: 2026-02-12
  conflict: "Memory path mismatch between DAILY-PREDICTIONS.md and daily-prediction.sh"
  impact: "Users may create memory files in the wrong location"
  status: resolved
  resolution: "Docs updated to match script and workspace-root convention"

### 6) Final state update (GLOBAL-STATE.yaml)
- Add a constraint:
  - "All path conventions must be workspace-scoped; no user-home hidden paths unless explicitly configured."
- Update last_update timestamp.

### 7) Closeout message (to user)
- Briefly state what changed.
- Provide the updated path convention.
- Mention that a conflict was detected and resolved.
