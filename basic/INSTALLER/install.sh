#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="OpenClaw Cognitive Upgrade Kit (Basic)"
REPO_URL="https://github.com/openclaw/openclaw.git"
INSTALL_DIR="$HOME/openclaw-docker"
CONFIG_DIR="$HOME/.openclaw-docker"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/openclaw-docker-workspace}"
GATEWAY_PORT="18799"
BRIDGE_PORT="18800"

FORCE=0
if [ "${1:-}" = "--force" ]; then
  FORCE=1
  shift
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "[info] %s\n" "$1"; }
warn() { printf "[warn] %s\n" "$1"; }
err()  { printf "[error] %s\n" "$1"; }

copy_tree() {
  # cp -a is preferred; fall back to cp -R -p for older BSD cp variants
  local src="$1"
  local dst="$2"
  if cp -a "$src" "$dst" 2>/dev/null; then
    return 0
  fi
  cp -R -p "$src" "$dst"
}

bold "$PRODUCT_NAME — Installer"
if [ "$FORCE" -eq 1 ]; then
  warn "Force mode enabled: kit-owned files will be overwritten (user-editable files will not)."
fi

# 1) Check Docker
if ! command -v docker >/dev/null 2>&1; then
  err "Docker not found. Install Docker Desktop first: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

# 2) Clone repo if missing
if [ ! -d "$INSTALL_DIR" ]; then
  info "Cloning OpenClaw repo to $INSTALL_DIR"
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  info "OpenClaw repo already exists at $INSTALL_DIR"
fi

# 3) Create dirs
mkdir -p "$CONFIG_DIR" "$WORKSPACE_DIR"

# 3a) Backup existing workspace snapshot (before any changes)
BACKUP_BASE="$HOME/openclaw-backups"
BACKUP_DIR="$BACKUP_BASE/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_BASE"
if [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A "$WORKSPACE_DIR" 2>/dev/null || true)" ]; then
  info "Backing up existing workspace to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  copy_tree "$WORKSPACE_DIR/." "$BACKUP_DIR/"
  info "Backup complete: $BACKUP_DIR"
else
  info "No existing workspace contents to back up"
fi

# 3b) Install kit-owned files (overwrite only in --force mode)
KIT_OWNED=(PREDICTION-PROTOCOL.md ERROR-DELTA-UPDATER.md CONSISTENCY-RESOLVER.md SELF-CHECK.md SAFETY-PRINCIPLES.md BENCHMARK-HARNESS.md MEMORY-SYSTEM-GUIDE.md GLOBAL-STATE-SCHEMA.md HEARTBEAT.md README-START-HERE.md CHANGELOG.md VERSION SECURITY.md)
for f in "${KIT_OWNED[@]}"; do
  if [ -f "$KIT_DIR/$f" ]; then
    if [ "$FORCE" -eq 1 ]; then
      info "Upgrading kit-owned file: $f"
      cp "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
    else
      if [ ! -f "$WORKSPACE_DIR/$f" ]; then
        info "Installing kit-owned file: $f"
        cp "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
      fi
    fi
  fi
done

# 3c) Install user-editable files (never overwrite)
USER_EDITABLE=(AGENTS.md SOUL.md USER.md TOOLS.md MEMORY.md GLOBAL-STATE.yaml AUDIT-LOG.md)
for f in "${USER_EDITABLE[@]}"; do
  if [ -f "$KIT_DIR/$f" ] && [ ! -f "$WORKSPACE_DIR/$f" ]; then
    info "Installing user-editable file: $f"
    cp "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
  fi
done

# 3d) Copy directories
DIRS_TO_COPY=(examples benchmarks)
for d in "${DIRS_TO_COPY[@]}"; do
  if [ -d "$KIT_DIR/$d" ]; then
    mkdir -p "$WORKSPACE_DIR/$d"
    if [ "$FORCE" -eq 1 ]; then
      info "Upgrading directory: $d"
      cp -R "$KIT_DIR/$d/." "$WORKSPACE_DIR/$d/"
    else
      # Copy only missing items to avoid overwriting user edits
      for item in "$KIT_DIR/$d"/*; do
        name="$(basename "$item")"
        if [ ! -e "$WORKSPACE_DIR/$d/$name" ]; then
          cp -R "$item" "$WORKSPACE_DIR/$d/$name"
        fi
      done
    fi
  fi
done

# 3e) Write kit manifest (always overwrite)
VERSION="$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "unknown")"
INSTALLED="$(date +"%Y-%m-%dT%H:%M:%S%z")"
cat > "$WORKSPACE_DIR/.openclaw-kit" <<EOF
kit: basic
version: $VERSION
installed: $INSTALLED
EOF
info "Wrote kit manifest: $WORKSPACE_DIR/.openclaw-kit"

# 3f) Bootstrap memory files (workspace root)
mkdir -p "$WORKSPACE_DIR/memory"
touch "$WORKSPACE_DIR/MEMORY.md"
touch "$WORKSPACE_DIR/memory/$(date +%Y-%m-%d).md"

# 4) Write .env for compose
cat > "$INSTALL_DIR/.env" <<ENV
OPENCLAW_CONFIG_DIR=$CONFIG_DIR
OPENCLAW_WORKSPACE_DIR=$WORKSPACE_DIR
OPENCLAW_GATEWAY_PORT=$GATEWAY_PORT
OPENCLAW_BRIDGE_PORT=$BRIDGE_PORT
OPENCLAW_GATEWAY_TOKEN=change-me-after-install
ENV

# 5) Start gateway
cd "$INSTALL_DIR"
info "Starting gateway on ports $GATEWAY_PORT/$BRIDGE_PORT"
docker compose up -d openclaw-gateway

# 6) Run setup (non-interactive check)
info "Running setup"
docker compose run --rm openclaw-cli setup

bold "Done."
info "Dashboard: http://127.0.0.1:${GATEWAY_PORT}/"
info "Workspace: $WORKSPACE_DIR"
info "Backup:   $BACKUP_DIR"
info "To restore a backup, use: $KIT_DIR/INSTALLER/restore.sh"
info "Optional: update OPENCLAW_GATEWAY_TOKEN in $INSTALL_DIR/.env"
