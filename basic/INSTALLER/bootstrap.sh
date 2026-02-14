#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER_DIR="$KIT_DIR/INSTALLER"

DEFAULT_WS="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"

ASSUME_YES="${OPENCLAW_ASSUME_YES:-0}"

ask_yn() {
  local prompt="$1"
  local default="$2" # Y or N
  if [[ "$ASSUME_YES" == "1" ]]; then
    echo "$default"
    return 0
  fi
  read -r -p "$prompt" yn
  yn="${yn:-$default}"
  echo "$yn"
}


echo "OpenClaw Basic bootstrap"
echo
echo "Workspace root (default): $DEFAULT_WS"
yn="$(ask_yn "Use this workspace root? [Y/n] " "Y")"

if [[ "$yn" =~ ^[Nn]$ ]]; then
  read -r -p "Enter workspace root path: " DEFAULT_WS
fi

export OPENCLAW_WORKSPACE_DIR="$DEFAULT_WS"
echo "Using workspace: $OPENCLAW_WORKSPACE_DIR"
mkdir -p "$OPENCLAW_WORKSPACE_DIR/memory"

# bootstrap memory files if missing
if [[ ! -f "$OPENCLAW_WORKSPACE_DIR/MEMORY.md" ]]; then
  echo "# MEMORY" > "$OPENCLAW_WORKSPACE_DIR/MEMORY.md"
  echo >> "$OPENCLAW_WORKSPACE_DIR/MEMORY.md"
  echo "## Non-authoritative notice" >> "$OPENCLAW_WORKSPACE_DIR/MEMORY.md"
  echo "Unless explicitly labeled as [DECISION] with Status: ACTIVE, content here is treated as context and thinking, not authoritative intent." >> "$OPENCLAW_WORKSPACE_DIR/MEMORY.md"
fi

DAY="$(date +%Y-%m-%d)"
touch "$OPENCLAW_WORKSPACE_DIR/memory/$DAY.md"

# Telemetry opt-in (local-only)
TEL="${OPENCLAW_TELEMETRY_ENABLED:-0}"
echo
echo "Telemetry is local-only and OFF by default."
tyn="$(ask_yn "Enable local-only telemetry? [y/N] " "N")"

if [[ "$tyn" =~ ^[Yy]$ ]]; then
  TEL=1
fi
export OPENCLAW_TELEMETRY_ENABLED="$TEL"

if [[ "$OPENCLAW_TELEMETRY_ENABLED" == "1" ]]; then
  mkdir -p "$OPENCLAW_WORKSPACE_DIR/telemetry"
  cat > "$OPENCLAW_WORKSPACE_DIR/telemetry/CONSENT.yaml" <<EOF
enabled: true
scope: local_only
date: "$DAY"
kit: "OpenClaw Basic"
EOF
fi

# Run health check
echo
echo "Running health check..."
bash "$INSTALLER_DIR/health-check.sh"

# Log install completed (local only)
if [[ "$OPENCLAW_TELEMETRY_ENABLED" == "1" ]]; then
  python3 "$KIT_DIR/TOOLS/telemetry.py" install_completed --workspace "$OPENCLAW_WORKSPACE_DIR" --kit_version "$(cat "$KIT_DIR/VERSION")" || true
fi

echo
echo "Bootstrap complete."
echo ""
echo "IMPORTANT — Apply the recommended config:"
echo "  1. Review:  cat $KIT_DIR/openclaw.recommended.jsonc"
echo "  2. Copy the compaction + memoryFlush block into ~/.openclaw/openclaw.json"
echo "  3. Restart: openclaw gateway restart"
echo ""
echo "This prevents memory loss during long sessions."
echo "Then start a new chat — BOOTSTRAP.md will run automatically on first session."
