#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="OpenClaw Multiagent Overlay v0.2"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
FORCE=0

if [ "${1:-}" = "--force" ]; then
  FORCE=1
  shift
fi

if [ -n "${1:-}" ]; then
  WORKSPACE_DIR="$1"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "[info] %s\n" "$1"; }
warn() { printf "[warn] %s\n" "$1"; }
err()  { printf "[error] %s\n" "$1"; }

bold "$PRODUCT_NAME — Installer"
info "Workspace: $WORKSPACE_DIR"

# --- Step 1: Check Basic kernel ---
if [ ! -f "$WORKSPACE_DIR/.openclaw-kit" ]; then
  err "Basic kernel not found at $WORKSPACE_DIR"
  err "Install OpenClaw Basic v3.1 first."
  exit 1
fi
info "Basic kernel detected"

# --- Step 2: Backup ---
BACKUP_BASE="$HOME/openclaw-backups"
BACKUP_DIR="$BACKUP_BASE/multi-$(date +%Y%m%d-%H%M%S)"

if [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A "$WORKSPACE_DIR" 2>/dev/null || true)" ]; then
  mkdir -p "$BACKUP_DIR"
  info "Backing up workspace to $BACKUP_DIR"
  cp -R "$WORKSPACE_DIR/." "$BACKUP_DIR/"
fi

# --- Step 3: Create directory structure ---
mkdir -p "$WORKSPACE_DIR/agents"
mkdir -p "$WORKSPACE_DIR/shared/decisions"
mkdir -p "$WORKSPACE_DIR/shared/requests"
info "Created agents/ and shared/ directories"

# --- Step 4: Install overlay files ---
copy_if_new() {
  local src="$1" dst="$2"
  if [ ! -f "$dst" ] || [ "$FORCE" -eq 1 ]; then
    info "Installing: $(basename "$dst")"
    cp "$src" "$dst"
  fi
}

# Behavioral files
copy_if_new "$KIT_DIR/AGENTS-MULTI.md" "$WORKSPACE_DIR/AGENTS-MULTI.md"

# Shared files
if [ ! -f "$WORKSPACE_DIR/shared/MANIFEST.yaml" ] || [ "$FORCE" -eq 1 ]; then
  info "Installing: shared/MANIFEST.yaml"
  cp "$KIT_DIR/shared/MANIFEST.yaml" "$WORKSPACE_DIR/shared/MANIFEST.yaml"
fi

# Documentation
copy_if_new "$KIT_DIR/MANIFEST-SCHEMA.md" "$WORKSPACE_DIR/MANIFEST-SCHEMA.md"
copy_if_new "$KIT_DIR/README.md" "$WORKSPACE_DIR/MULTI-README.md"

# Examples
mkdir -p "$WORKSPACE_DIR/examples"
if [ -f "$KIT_DIR/examples/day-in-life-multi.md" ] && [ ! -f "$WORKSPACE_DIR/examples/day-in-life-multi.md" ]; then
  cp "$KIT_DIR/examples/day-in-life-multi.md" "$WORKSPACE_DIR/examples/day-in-life-multi.md"
fi

# Directory READMEs
cp "$KIT_DIR/shared/decisions/README.md" "$WORKSPACE_DIR/shared/decisions/README.md" 2>/dev/null || true
cp "$KIT_DIR/shared/requests/README.md" "$WORKSPACE_DIR/shared/requests/README.md" 2>/dev/null || true

# --- Step 5: Create default agent (hub) if none exist ---
if [ ! -d "$WORKSPACE_DIR/agents/main" ] && [ -z "$(ls -A "$WORKSPACE_DIR/agents/" 2>/dev/null)" ]; then
  info "Creating default agent: main"
  mkdir -p "$WORKSPACE_DIR/agents/main/memory"
  mkdir -p "$WORKSPACE_DIR/agents/main/files"
  mkdir -p "$WORKSPACE_DIR/agents/main/subagents"

  # Copy existing SOUL.md and IDENTITY.md as the default agent's persona
  if [ -f "$WORKSPACE_DIR/SOUL.md" ]; then
    cp "$WORKSPACE_DIR/SOUL.md" "$WORKSPACE_DIR/agents/main/SOUL.md"
  else
    cat > "$WORKSPACE_DIR/agents/main/SOUL.md" <<'SOUL'
# SOUL.md — Persona & Operating Style

## Core truths
- Be genuinely helpful, not performatively helpful.
- Have opinions; don't be bland.
- Be resourceful before asking.
- Earn trust through competence.

## Vibe
Concise, direct, human. Not corporate. Not a sycophant.
SOUL
  fi

  if [ -f "$WORKSPACE_DIR/IDENTITY.md" ]; then
    cp "$WORKSPACE_DIR/IDENTITY.md" "$WORKSPACE_DIR/agents/main/IDENTITY.md"
  else
    cat > "$WORKSPACE_DIR/agents/main/IDENTITY.md" <<'ID'
# IDENTITY.md

- Name: Main
- Emoji: 🔧
- One-liner: "General-purpose agent."
ID
  fi

  # Create empty MEMORY.md
  cat > "$WORKSPACE_DIR/agents/main/MEMORY.md" <<'MEM'
## Non-Authoritative Memory Notice
This file contains cognitive memory only. It does not define goals, policy, or truth.

# MEMORY.md — Long-Term Memory (main)

MEM

  # Set manifest hub
  sed -i 's/^hub: ""/hub: "main"/' "$WORKSPACE_DIR/shared/MANIFEST.yaml" 2>/dev/null || true
fi

# --- Step 6: Update overlay identity ---
VERSION="$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "0.2.0")"
INSTALLED="$(date +"%Y-%m-%dT%H:%M:%S%z")"
cat > "$WORKSPACE_DIR/.openclaw-multi" <<EOF
overlay: multiagent
version: $VERSION
installed: $INSTALLED
EOF
info "Updated overlay identity"

# --- Done ---
echo ""
bold "Installation complete."
echo ""
info "Workspace: $WORKSPACE_DIR"
info "Backup:    ${BACKUP_DIR:-none}"
echo ""
bold "Next steps:"
echo "  1. Create agents:"
echo "     bash INSTALLER/create-agent.sh research \"Research — literature review and synthesis\""
echo "     bash INSTALLER/create-agent.sh dev \"Development — architecture, implementation, testing\""
echo "  2. Edit each agent's SOUL.md to define personality and domain expertise"
echo "  3. Edit shared/MANIFEST.yaml — verify hub and agent entries"
echo "  4. Add to AGENTS.md Memory discipline section:"
echo "     \"If AGENTS-MULTI.md exists, read it and shared/MANIFEST.yaml now.\""
echo ""
info "See MULTI-README.md for full documentation."
