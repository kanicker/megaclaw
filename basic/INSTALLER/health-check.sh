#!/usr/bin/env bash
set -euo pipefail

# Health check for OpenClaw Cognitive Upgrade Kit (Basic)

WORKSPACE="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18799}"

ok() { echo "[OK] $1"; }
warn() { echo "[WARN] $1"; }

# 1) Gateway health (optional — may not be running locally)
if command -v lsof >/dev/null 2>&1 && lsof -iTCP:"$GATEWAY_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  ok "Gateway port $GATEWAY_PORT listening"
else
  warn "Gateway port $GATEWAY_PORT not listening (may be normal if gateway runs elsewhere)"
fi

# 2) Core files present (workspace root)
REQ=(AGENTS.md SOUL.md USER.md TOOLS.md MEMORY.md GLOBAL-STATE.yaml GLOBAL-STATE-SCHEMA.md HEARTBEAT.md SECURITY.md CORE-SEMANTICS.md COMPACTION-SURVIVAL.md)
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
  needed=(goals: hypotheses: constraints: conflicts: predictions: last_update:)
  bad=0
  for k in "${needed[@]}"; do
    if ! grep -q "^$k" "$STATE"; then
      warn "Global state missing key: $k"
      bad=1
    fi
  done
  if [ "$bad" -eq 0 ]; then
    ok "Global State Ledger looks structurally present"
  else
    warn "Global State Ledger exists but may be missing keys"
  fi
else
  warn "Global State Ledger missing: $STATE"
fi

# 5) Audit log presence
if [ ! -f "$WORKSPACE/AUDIT-LOG.md" ]; then
  warn "AUDIT-LOG.md missing (security change log). Create from template or run bootstrap."
fi

# 6) Compaction config check
OCLCONF="$HOME/.openclaw/openclaw.json"
if [ -f "$OCLCONF" ]; then
  if grep -q "memoryFlush" "$OCLCONF" 2>/dev/null; then
    ok "memoryFlush string found in openclaw.json (verify nesting is correct)"
  else
    warn "memoryFlush not found in openclaw.json — long sessions may lose context. See openclaw.recommended.jsonc"
  fi
  if grep -q "reserveTokensFloor" "$OCLCONF" 2>/dev/null; then
    ok "reserveTokensFloor string found in openclaw.json (verify nesting is correct)"
  else
    warn "reserveTokensFloor not set — using default 20000. See openclaw.recommended.jsonc for tier options"
  fi
  echo "  (For definitive compaction health, run: python3 TOOLS/openclaw_compaction_diagnostics.py summary)"
else
  warn "No openclaw.json found at $OCLCONF — recommended config not applied"
fi

echo ""
echo "Workspace: $WORKSPACE"
echo ""
echo "Tip: Run compaction diagnostics to check if your config is working:"
echo "  python3 $WORKSPACE/TOOLS/openclaw_compaction_diagnostics.py summary"
