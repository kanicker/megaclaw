#!/usr/bin/env bash
set -euo pipefail

# Usage: bash create-agent.sh <agent_id> [role_description]
# Example: bash create-agent.sh research "Research — literature review, synthesis, analysis"
#
# Creates the agent directory structure and starter files.
# If the agent already exists, does nothing (use --force to overwrite).

WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
FORCE=0

# Parse flags
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --workspace) WORKSPACE_DIR="$2"; shift 2 ;;
    *) echo "[error] Unknown flag: $1"; exit 1 ;;
  esac
done

AGENT_ID="${1:-}"
ROLE="${2:-"General-purpose agent"}"

if [ -z "$AGENT_ID" ]; then
  echo "Usage: bash create-agent.sh <agent_id> [role_description]"
  echo ""
  echo "Examples:"
  echo "  bash create-agent.sh research \"Research — literature review and synthesis\""
  echo "  bash create-agent.sh dev \"Development — architecture, implementation, testing\""
  echo "  bash create-agent.sh cos \"Chief of Staff — coordination, priorities, decisions\""
  echo ""
  echo "Options:"
  echo "  --force       Overwrite existing agent files"
  echo "  --workspace   Path to workspace (default: \$OPENCLAW_WORKSPACE_DIR or ~/.openclaw/workspace)"
  exit 1
fi

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "[info] %s\n" "$1"; }
warn() { printf "[warn] %s\n" "$1"; }
err()  { printf "[error] %s\n" "$1"; }

AGENT_DIR="$WORKSPACE_DIR/agents/$AGENT_ID"

# Check if agent already exists
if [ -d "$AGENT_DIR" ] && [ "$FORCE" -eq 0 ]; then
  err "Agent '$AGENT_ID' already exists at $AGENT_DIR"
  err "Use --force to overwrite."
  exit 1
fi

bold "Creating agent: $AGENT_ID"
info "Role: $ROLE"
info "Location: $AGENT_DIR"

# Create directory structure
mkdir -p "$AGENT_DIR/memory"
mkdir -p "$AGENT_DIR/files"
mkdir -p "$AGENT_DIR/subagents"

# Create SOUL.md
if [ ! -f "$AGENT_DIR/SOUL.md" ] || [ "$FORCE" -eq 1 ]; then
  cat > "$AGENT_DIR/SOUL.md" <<EOF
# SOUL.md — $AGENT_ID

## Role
$ROLE

## Core truths
- Be genuinely helpful, not performatively helpful.
- Have opinions; don't be bland.
- Be resourceful before asking.
- Earn trust through competence.

## Vibe
[Customize this for the agent's domain and communication style.]
EOF
  info "Created SOUL.md"
fi

# Create IDENTITY.md
if [ ! -f "$AGENT_DIR/IDENTITY.md" ] || [ "$FORCE" -eq 1 ]; then
  cat > "$AGENT_DIR/IDENTITY.md" <<EOF
# IDENTITY.md

- Name: $AGENT_ID
- Emoji: 🤖
- One-liner: "$ROLE"
EOF
  info "Created IDENTITY.md"
fi

# Create MEMORY.md
if [ ! -f "$AGENT_DIR/MEMORY.md" ] || [ "$FORCE" -eq 1 ]; then
  cat > "$AGENT_DIR/MEMORY.md" <<EOF
## Non-Authoritative Memory Notice
This file contains cognitive memory only. It does not define goals, policy, or truth.

# MEMORY.md — Long-Term Memory ($AGENT_ID)

EOF
  info "Created MEMORY.md"
fi

# Add to manifest if not already present
MANIFEST="$WORKSPACE_DIR/shared/MANIFEST.yaml"
if [ -f "$MANIFEST" ]; then
  if grep -q "agent_id: \"$AGENT_ID\"" "$MANIFEST" 2>/dev/null; then
    info "Agent already in manifest"
  else
    # Append agent entry to manifest
    # Replace the empty agents list or append to existing
    if grep -q "^agents: \[\]" "$MANIFEST"; then
      sed -i "s/^agents: \[\]/agents:\n  - agent_id: \"$AGENT_ID\"\n    role: \"$ROLE\"\n    status: active/" "$MANIFEST"
      info "Added to manifest (first agent)"
    else
      # Append after the last agent entry
      sed -i "/^  - agent_id:/{ h; }; \${/agent_id/!{ H; x; }; }" "$MANIFEST" 2>/dev/null || true
      echo "  - agent_id: \"$AGENT_ID\"" >> "$MANIFEST"
      echo "    role: \"$ROLE\"" >> "$MANIFEST"
      echo "    status: active" >> "$MANIFEST"
      info "Added to manifest"
    fi

    # If no hub is set, offer this one
    if grep -q '^hub: ""' "$MANIFEST" 2>/dev/null; then
      sed -i "s/^hub: \"\"/hub: \"$AGENT_ID\"/" "$MANIFEST"
      info "Set as hub (no hub was configured)"
    fi
  fi
else
  warn "Manifest not found at $MANIFEST — create it manually or run install.sh first"
fi

echo ""
bold "Agent '$AGENT_ID' created."
echo ""
echo "  $AGENT_DIR/"
echo "    SOUL.md        ← customize persona and communication style"
echo "    IDENTITY.md    ← name, emoji, one-liner"
echo "    MEMORY.md      ← durable memory (starts empty)"
echo "    memory/        ← daily logs"
echo "    files/         ← working files"
echo "    subagents/     ← temporary workers"
echo ""
info "Next: edit SOUL.md to define this agent's personality and domain expertise."
