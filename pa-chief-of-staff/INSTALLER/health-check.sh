#!/usr/bin/env bash
set -euo pipefail

# Health check for OpenClaw Cognitive Upgrade Kit
# Checks: gateway health, core files, state file presence, basic infra sanity.

WORKSPACE="${OPENCLAW_WORKSPACE_DIR:-$HOME/openclaw-docker-workspace}"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18799}"
LOG="/tmp/openclaw-health.log"

ok() { echo "[OK] $1"; }
warn() { echo "[WARN] $1"; }
fail() { echo "[FAIL] $1"; }

# 1) Gateway health
if command -v lsof >/dev/null 2>&1 && lsof -iTCP:"$GATEWAY_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  ok "Gateway port $GATEWAY_PORT listening"
else
  warn "Gateway port $GATEWAY_PORT not listening"
fi

# 2) Core files present (workspace root)
REQ=(SELF-CHECK.md SAFETY-PRINCIPLES.md AGENTS.md SOUL.md USER.md TOOLS.md MEMORY.md GLOBAL-STATE-SCHEMA.md GLOBAL-STATE.yaml MEMORY-SYSTEM-GUIDE.md PREDICTION-PROTOCOL.md HEARTBEAT.md SECURITY.md)
missing=0
for f in "${REQ[@]}"; do
  if [ ! -f "$WORKSPACE/$f" ]; then
    warn "Missing core file: $WORKSPACE/$f"
    missing=1
  fi
done

if [ "$missing" -eq 0 ]; then
  ok "Core files present in workspace"
else
  warn "One or more core files missing in workspace"
fi

# 3) Memory folder sanity
if [ -d "$WORKSPACE/memory" ]; then
  ok "Memory folder exists: $WORKSPACE/memory"
else
  warn "Memory folder missing: $WORKSPACE/memory"
fi

# 4) Global State Ledger sanity check (lightweight)
STATE="$WORKSPACE/GLOBAL-STATE.yaml"
if [ -f "$STATE" ]; then
  # Check for required keys (not a full YAML parse)
  needed=(goals: hypotheses: constraints: conflicts: predictions: last_update:)
  bad=0
  for k in "${needed[@]}"; do
    if ! grep -q "^$k" "$STATE"; then
      warn "Global state missing key: $k"
      bad=1
    fi
  done
  if [ "$bad" -eq 0 ]; then
    
# Optional: warn if audit log missing
if [ ! -f "$WORKSPACE/AUDIT-LOG.md" ]; then
  warn "AUDIT-LOG.md missing (security change log). Install will create it; otherwise create from template."
fi
ok "Global State Ledger looks structurally present"
  else
    warn "Global State Ledger exists but may be missing keys"
  fi
else
  warn "Global State Ledger missing: $STATE"
fi

echo ""
echo "Workspace: $WORKSPACE"
echo "Log: $LOG"
