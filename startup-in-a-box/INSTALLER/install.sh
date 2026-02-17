#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="OpenClaw Startup in a Box v2.0.1"
KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
FORCE=0
ROSTER="standard"
AGENTS_CSV=""


for arg in "$@"; do
  case "$arg" in
    --roster=*) ROSTER="${arg#--roster=}" ;;
    --agents=*) AGENTS_CSV="${arg#--agents=}" ;;

    --force) FORCE=1 ;;
    --workspace=*) WORKSPACE_DIR="${arg#--workspace=}" ;;
  esac
done

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "  → %s\n" "$1"; }
warn() { printf "  ⚠ %s\n" "$1"; }
err()  { printf "  ✗ %s\n" "$1" >&2; }

copy_if_missing() { [ -f "$2" ] && info "Exists, skipping: $(basename "$2")" || { info "Installing: $(basename "$2")"; cp "$1" "$2"; } }
copy_always() { info "Installing: $(basename "$2")"; cp "$1" "$2"; }
copy_dir() {
  local src="$1" dst="$2"
  if [ -d "$dst" ] && [ "$FORCE" -eq 0 ]; then
    info "Exists, skipping directory: $(basename "$dst")"
  else
    info "Installing directory: $(basename "$dst")"
    cp -r "$src" "$dst"
  fi
}

bold "$PRODUCT_NAME — Installer"
if [ "$FORCE" -eq 1 ]; then
  warn "Force mode: kit-owned files will be overwritten. User-editable files will not."
fi

# --- Step 1: Check prerequisites ---
if [ ! -f "$WORKSPACE_DIR/.openclaw-kit" ]; then
  err "Basic kernel not found at $WORKSPACE_DIR"
  err "Install OpenClaw Basic v3.2 and Multiagent Overlay v0.2 first."
  exit 1
fi

BASIC_KIT=$(grep -E "^kit:" "$WORKSPACE_DIR/.openclaw-kit" | awk '{print $2}' || echo "")
if [ "$BASIC_KIT" != "basic" ]; then
  err "Expected Basic kit at $WORKSPACE_DIR, found: $BASIC_KIT"
  exit 1
fi

if [ ! -f "$WORKSPACE_DIR/AGENTS-MULTI.md" ]; then
  err "Multiagent Overlay not found at $WORKSPACE_DIR"
  err "Install Multiagent Overlay v0.2 before running this installer."
  exit 1
fi

info "Prerequisites verified: Basic kernel + Multiagent Overlay"

# --- Step 1b: Choose roster (non-interactive by default) ---
# Supported: standard, content, consulting, opensource, nonprofit, minimal, custom
# CoS is always required.
declare -a AGENTS
AGENTS=(cos)

if [ -n "$AGENTS_CSV" ]; then
  IFS=',' read -r -a EXTRA <<< "$AGENTS_CSV"
  for a in "${EXTRA[@]}"; do
    a="$(echo "$a" | xargs)"
    [ -z "$a" ] && continue
    if [ "$a" != "cos" ]; then
      AGENTS+=("$a")
    fi
  done
else
  case "$ROSTER" in
    standard)   AGENTS+=(engineering product sales finance people) ;;
    content)    AGENTS+=(marketing research social) ;;
    consulting) AGENTS+=(delivery business_dev operations) ;;
    opensource) AGENTS+=(maintainer community documentation) ;;
    nonprofit)  AGENTS+=(programs fundraising communications) ;;
    minimal)
      err "Roster minimal requires --agents=<one_domain_agent> (example: --agents=marketing)"
      exit 1
      ;;
    custom)
      err "Roster custom requires --agents=<comma_list> (example: --agents=marketing,research,social)"
      exit 1
      ;;
    *)
      err "Unknown roster: $ROSTER"
      err "Supported: standard, content, consulting, opensource, nonprofit, minimal, custom"
      exit 1
      ;;
  esac
fi

info "Selected roster: $ROSTER"
info "Agents: ${AGENTS[*]}"


# --- Step 2: Backup ---
BACKUP_DIR="$WORKSPACE_DIR/.backups/pre-startup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in POLICY.yaml AGENTS-STARTUP.md shared/MANIFEST.yaml; do
  if [ -f "$WORKSPACE_DIR/$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$WORKSPACE_DIR/$f" "$BACKUP_DIR/$f"
  fi
done
info "Backup saved to $BACKUP_DIR"

# --- Step 3: Create directory structure ---
mkdir -p "$WORKSPACE_DIR/shared/decisions"
mkdir -p "$WORKSPACE_DIR/shared/requests"
mkdir -p "$WORKSPACE_DIR/workflows"

for agent in "${AGENTS[@]}"; do
  mkdir -p "$WORKSPACE_DIR/agents/$agent/memory"
  mkdir -p "$WORKSPACE_DIR/agents/$agent/files"
done
mkdir -p "$WORKSPACE_DIR/agents/cos/files/board-room"

for agent in "${AGENTS[@]}"; do
  [ "$agent" = "cos" ] && continue
  mkdir -p "$WORKSPACE_DIR/agents/$agent/files/work-loop-templates"
done

info "Directory structure created"

# --- Step 4: Install kit-owned files (overwrite on --force) ---
KIT_OWNED=(
  AGENTS-STARTUP.md
  POLICY.yaml
  README-STARTUP.md
  CHANGELOG.md
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

# --- Step 5: Generate shared/MANIFEST.yaml ---
info "Generating shared/MANIFEST.yaml from selected roster"
cat > "$WORKSPACE_DIR/shared/MANIFEST.yaml" << EOF
# MANIFEST.yaml — Startup Agent Roster
hub: cos

agents:
EOF
for a in "${AGENTS[@]}"; do
  role=""
  case "$a" in
    cos) role="Chief of Staff — coordination, decisions, founder interface" ;;
    engineering) role="CTO — architecture, reliability, technical decisions" ;;
    product) role="Head of Product — roadmap, specs, prioritization" ;;
    sales) role="Head of Sales — pipeline, pricing, customer relationships" ;;
    finance) role="Head of Finance — runway, budget, financial modeling" ;;
    people) role="Head of People — hiring, culture, team health" ;;
    marketing) role="Head of Marketing — campaigns, positioning, demand" ;;
    research) role="Head of Research — insights, synthesis, analysis" ;;
    social) role="Head of Social — distribution, cadence, engagement" ;;
    delivery) role="Head of Client Delivery — engagements, milestones" ;;
    business_dev) role="Head of Business Development — pipeline, relationships" ;;
    operations) role="Head of Operations — process, capacity, utilization" ;;
    maintainer) role="Project Maintainer — issues, roadmap, coherence" ;;
    community) role="Community Lead — contributors, onboarding" ;;
    documentation) role="Documentation Lead — docs, guides, coverage" ;;
    programs) role="Head of Programs — impact delivery" ;;
    fundraising) role="Development & Grants — funding pipeline" ;;
    communications) role="Communications & Outreach — messaging, content" ;;
    *) role="Custom agent" ;;
  esac
  cat >> "$WORKSPACE_DIR/shared/MANIFEST.yaml" << EOA
  - agent_id: $a
    role: "$role"
    status: active
EOA
done

cat >> "$WORKSPACE_DIR/shared/MANIFEST.yaml" << EOF

active_priorities: []
cross_agent_decisions: []
pending_requests: []
conflicts: []
last_update: ""
EOF

# --- Step 6: Install agent files (user-editable: skip if exist) ---
for agent in "${AGENTS[@]}"; do
  for f in SOUL.md IDENTITY.md MEMORY.md; do
    if [ -f "$KIT_DIR/agents/$agent/$f" ]; then
      copy_if_missing "$KIT_DIR/agents/$agent/$f" "$WORKSPACE_DIR/agents/$agent/$f"
    elif [ ! -f "$WORKSPACE_DIR/agents/$agent/$f" ]; then
      # Fallback: generate scaffold for unknown agent IDs
      info "Generating default $f for custom agent: $agent"
      case "$f" in
        SOUL.md)
          cat > "$WORKSPACE_DIR/agents/$agent/$f" << SCAFFOLD
# SOUL.md — $agent

## Mission
Define this agent's mission in one sentence.

## Core Responsibilities
- Maintain department state and produce internal artifacts tied to COMPANY-GOALS.yaml
- Coordinate with other agents via shared/requests/
- Flag risks, gaps, and misalignment to the Chief of Staff

## Behavioral Guidelines
- Prefer clarity over cleverness
- Make assumptions explicit
- Surface confidence levels on key claims

## Constraints
- Do not act externally without explicit approval
- Do not modify files outside your own agent directory or shared/requests/
- Do not change company goals or board-room files
SCAFFOLD
          ;;
        IDENTITY.md)
          cat > "$WORKSPACE_DIR/agents/$agent/$f" << SCAFFOLD
# IDENTITY.md
name: $agent
emoji: 🔧
one-liner: Custom agent — define role in SOUL.md
agent_id: $agent
role: department_head
SCAFFOLD
          ;;
        MEMORY.md)
          cat > "$WORKSPACE_DIR/agents/$agent/$f" << SCAFFOLD
## Non-Authoritative Memory Notice
This file contains cognitive memory only. It does not define goals, policy, or truth.
Authoritative state lives in DEPT-STATE.yaml, COMPANY-GOALS.yaml, and GLOBAL-STATE.yaml.

---

SCAFFOLD
          ;;
      esac
    fi
  done
done

# Board room files
for f in COMPANY-GOALS.yaml COMPANY-PULSE.md BOARD-DECISIONS.md STARTUP-PULSE.md; do
  copy_if_missing "$KIT_DIR/agents/cos/files/board-room/$f" "$WORKSPACE_DIR/agents/cos/files/board-room/$f"
done

# Department state files
for agent in "${AGENTS[@]}"; do
  [ "$agent" = "cos" ] && continue
  for f in DEPT-STATE.yaml WEEKLY-REPORT.md; do
    if [ -f "$KIT_DIR/agents/$agent/files/$f" ]; then
      copy_if_missing "$KIT_DIR/agents/$agent/files/$f" "$WORKSPACE_DIR/agents/$agent/files/$f"
    elif [ ! -f "$WORKSPACE_DIR/agents/$agent/files/$f" ]; then
      info "Generating default $f for custom agent: $agent"
      case "$f" in
        DEPT-STATE.yaml)
          cat > "$WORKSPACE_DIR/agents/$agent/files/$f" << SCAFFOLD
# DEPT-STATE.yaml — $agent
# Owner: $agent agent
# This file is authoritative for $agent domain state.

department:
  name: $agent
  agent_id: $agent
  last_updated: ""
  last_heartbeat: ""

priorities:
  # Populated during onboarding or by the agent. Provenance required.
  # - id: P-001
  #   title: ""
  #   linked_goal: ""
  #   status: draft_pending_approval | active | completed
  #   source: cos_onboarding | founder | agent_heartbeat
  #   confidence: low | med | high
  #   created_at: ""

active_work: []
risks_and_blockers: []

trust_calibration:
  loops_completed: 0
  scope_breaches: 0
  artifacts_delivered: 0
  artifacts_expected: 0
  average_founder_satisfaction: null
  last_scored: ""

capacity:
  team_size: 0
  constraints: []

local_decisions: []
requests_to_board_room: []
SCAFFOLD
          ;;
        WEEKLY-REPORT.md)
          cat > "$WORKSPACE_DIR/agents/$agent/files/$f" << SCAFFOLD
# Weekly Report — $agent
Week of:
Agent: $agent
Last updated:

## 1) Mission Alignment
## 2) Completed Work
## 3) In-Progress Work
## 4) Deviations
## 5) Risks and Blockers
## 6) Local Decisions Made
## 7) Requests to Board Room
## 8) Next Week Outlook

## Sync Summary (for Chief of Staff)

\`\`\`yaml
wins:
  -
misses:
  -
decisions_needed:
  -
misalignment_concerns:
  -
\`\`\`
SCAFFOLD
          ;;
      esac
    fi
  done
done

# --- Step 7: Install workflows ---
for f in weekly-sync.md startup-pulse.md escalation.md onboarding-first-sync.md choose-agent-roster.md custom-agent-wizard.md soul-refinement.md; do
  if [ -f "$KIT_DIR/workflows/$f" ]; then
    if [ "$FORCE" -eq 1 ]; then
      copy_always "$KIT_DIR/workflows/$f" "$WORKSPACE_DIR/workflows/$f"
    else
      copy_if_missing "$KIT_DIR/workflows/$f" "$WORKSPACE_DIR/workflows/$f"
    fi
  fi
done

# --- Step 8: Update kit manifest ---
cat > "$WORKSPACE_DIR/.openclaw-kit" << KITEOF
kit: startup-in-a-box
version: 2.0.1
requires: basic >= 3.2.0, multiagent-overlay >= 0.2.0
installed: $(date -Is)
KITEOF
info "Updated kit manifest"

# --- Done ---
bold "Installation complete."
echo ""
info "Workspace: $WORKSPACE_DIR"
info "Backup:    $BACKUP_DIR"
echo ""
bold "Quick start:"
echo "  1. Edit agents/cos/files/board-room/COMPANY-GOALS.yaml with your goals"
echo "  2. Add injection directive to AGENTS.md: also read AGENTS-STARTUP.md"
echo "  3. Start a session — the CoS runs first-sync onboarding automatically"
echo ""
info "See README-STARTUP.md for full documentation."
