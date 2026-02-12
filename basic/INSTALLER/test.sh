#!/usr/bin/env bash
set -euo pipefail

# Test script for OpenClaw Cognitive Upgrade Kit
# Assumes Docker install in ~/openclaw-docker

ROOT="$HOME/openclaw-docker"
CFG="$HOME/openclaw-docker-workspace"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "[info] %s\n" "$1"; }
fail() { printf "[fail] %s\n" "$1"; exit 1; }

bold "OpenClaw Cognitive Upgrade Kit — Test Runner"

# 1) Basic checks
[ -d "$ROOT" ] || fail "Missing repo at $ROOT"
[ -d "$CFG" ] || fail "Missing config dir at $CFG"

# 2) Required files in config
REQ=(AGENTS.md SOUL.md USER.md TOOLS.md MEMORY.md MEMORY-SYSTEM-GUIDE.md GLOBAL-STATE-SCHEMA.md PREDICTION-PROTOCOL.md ERROR-DELTA-UPDATER.md CONSISTENCY-RESOLVER.md BENCHMARK-HARNESS.md)
for f in "${REQ[@]}"; do
  [ -f "$CFG/$f" ] || fail "Missing $CFG/$f"
done
info "Workspace files present"

# 3) Memory path sanity check
if grep -q "workspace root" "$CFG/AGENTS.md"; then
  info "AGENTS.md memory path rule present"
else
  fail "AGENTS.md missing memory path rule"
fi

# 4) Gateway running
cd "$ROOT"
if ! docker compose ps | grep -q openclaw-gateway; then
  fail "Gateway container not found"
fi
info "Gateway container exists"

# 5) Dashboard reachable (port 18799)
if lsof -iTCP:18799 -sTCP:LISTEN >/dev/null 2>&1; then
  info "Dashboard port 18799 is listening"
else
  fail "Port 18799 not listening"
fi

bold "All checks passed."
info "Next: open http://127.0.0.1:18799/ and start a NEW chat to verify behavior."


echo "[INFO] Checking examples and benchmarks present..."
[ -d "$CFG/examples" ] && echo "[OK] examples/ present" || echo "[WARN] examples/ missing"
[ -d "$CFG/benchmarks" ] && echo "[OK] benchmarks/ present" || echo "[WARN] benchmarks/ missing"
