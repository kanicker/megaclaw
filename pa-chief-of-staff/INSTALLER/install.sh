#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="OpenClaw PA / Chief of Staff Kit v3"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
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

copy_if_missing() {
  local src="$1" dst="$2"
  if [ ! -f "$dst" ]; then
    info "Installing: $(basename "$dst")"
    cp "$src" "$dst"
  elif [ "$FORCE" -eq 1 ]; then
    info "Upgrading: $(basename "$dst")"
    cp "$src" "$dst"
  fi
}

copy_always() {
  local src="$1" dst="$2"
  info "Installing: $(basename "$dst")"
  cp "$src" "$dst"
}

bold "$PRODUCT_NAME — Installer"
if [ "$FORCE" -eq 1 ]; then
  warn "Force mode: kit-owned files will be overwritten. User-editable files will not."
fi

# --- Step 1: Check Basic v3.2 prerequisite ---
if [ ! -f "$WORKSPACE_DIR/.openclaw-kit" ]; then
  err "Basic kernel not found at $WORKSPACE_DIR"
  err "Install OpenClaw Basic v3.2 first, then re-run this installer."
  exit 1
fi

BASIC_KIT=$(grep -E "^kit:" "$WORKSPACE_DIR/.openclaw-kit" | awk '{print $2}' || echo "")
if [ "$BASIC_KIT" != "basic" ] && [ "$BASIC_KIT" != "executive-cos" ]; then
  err "Expected Basic kit at $WORKSPACE_DIR, found: $BASIC_KIT"
  err "Install OpenClaw Basic v3.2 first."
  exit 1
fi

info "Basic kernel detected at $WORKSPACE_DIR"

# --- Step 2: Backup existing workspace ---
BACKUP_BASE="$HOME/openclaw-backups"
BACKUP_DIR="$BACKUP_BASE/cos-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_BASE"

if [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A "$WORKSPACE_DIR" 2>/dev/null || true)" ]; then
  info "Backing up workspace to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  cp -R "$WORKSPACE_DIR/." "$BACKUP_DIR/"
  info "Backup complete"
fi

# --- Step 3: Create directories ---
mkdir -p "$WORKSPACE_DIR/roles"
mkdir -p "$WORKSPACE_DIR/workflows"
mkdir -p "$WORKSPACE_DIR/briefings"
mkdir -p "$WORKSPACE_DIR/examples"

# --- Step 4: Install kit-owned files (overwrite on --force) ---
KIT_OWNED=(
  AGENTS-COS.md
  SOUL-COS.md
  STATE-CONTRACT.md
  EXECUTIVE-STATE-SCHEMA.md
  DECISIONS.md
  COMMS-DRAFTS.md
  MEETINGS.md
  README-COS.md
  CHANGELOG.md
  MIGRATION-FROM-V2.md
  VERSION
)

for f in "${KIT_OWNED[@]}"; do
  if [ -f "$KIT_DIR/$f" ]; then
    if [ "$FORCE" -eq 1 ]; then
      copy_always "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
    else
      copy_if_missing "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
    fi
  fi
done

# --- Step 5: Install user-editable files (never overwrite) ---
USER_EDITABLE=(
  EXECUTIVE-STATE.yaml
  STAKEHOLDERS.yaml
)

for f in "${USER_EDITABLE[@]}"; do
  if [ -f "$KIT_DIR/$f" ] && [ ! -f "$WORKSPACE_DIR/$f" ]; then
    info "Installing user-editable: $f"
    cp "$KIT_DIR/$f" "$WORKSPACE_DIR/$f"
  fi
done

# --- Step 6: Install role modules ---
for f in "$KIT_DIR"/roles/*.md; do
  name="$(basename "$f")"
  if [ "$FORCE" -eq 1 ]; then
    copy_always "$f" "$WORKSPACE_DIR/roles/$name"
  else
    copy_if_missing "$f" "$WORKSPACE_DIR/roles/$name"
  fi
done

# --- Step 7: Install workflow guides ---
for f in "$KIT_DIR"/workflows/*.md; do
  name="$(basename "$f")"
  if [ "$FORCE" -eq 1 ]; then
    copy_always "$f" "$WORKSPACE_DIR/workflows/$name"
  else
    copy_if_missing "$f" "$WORKSPACE_DIR/workflows/$name"
  fi
done

# --- Step 8: Install examples ---
for f in "$KIT_DIR"/examples/*; do
  name="$(basename "$f")"
  if [ ! -e "$WORKSPACE_DIR/examples/$name" ]; then
    cp "$f" "$WORKSPACE_DIR/examples/$name"
  fi
done

# --- Step 9: Update kit manifest ---
VERSION="$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "3.0.0")"
INSTALLED="$(date +"%Y-%m-%dT%H:%M:%S%z")"
cat > "$WORKSPACE_DIR/.openclaw-kit" <<EOF
kit: executive-cos
version: $VERSION
requires: basic >= 3.1.0
installed: $INSTALLED
EOF
info "Updated kit manifest"

# --- Done ---
bold "Installation complete."
echo ""
info "Workspace: $WORKSPACE_DIR"
info "Backup:    $BACKUP_DIR"
echo ""
bold "Quick start:"
echo "  1. Edit EXECUTIVE-STATE.yaml with your top 3 priorities"
echo "  2. Edit STAKEHOLDERS.yaml with your key relationships"
echo "  3. Add the injection directive to AGENTS.md (see README-COS.md)"
echo "  4. Start a session — the agent will auto-load CoS and run a daily pulse"
echo ""
info "See README-COS.md for full documentation."
info "Upgrading from v2? See MIGRATION-FROM-V2.md."
