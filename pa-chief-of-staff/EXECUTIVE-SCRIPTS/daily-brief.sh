#!/usr/bin/env bash
set -euo pipefail

# Generate a morning brief file from EXECUTIVE-STATE.yaml
# Output: briefs/YYYY-MM-DD.md

WORKSPACE="${OPENCLAW_WORKSPACE_DIR:-$HOME/openclaw-docker-workspace}"
STATE="$WORKSPACE/EXECUTIVE-STATE.yaml"
OUTDIR="$WORKSPACE/briefs"
TODAY="$(date +%Y-%m-%d)"
OUT="$OUTDIR/$TODAY.md"

mkdir -p "$OUTDIR"

if [ ! -f "$STATE" ]; then
  echo "Missing $STATE" >&2
  exit 1
fi

python3 - <<PY
import datetime, re
from pathlib import Path

state = Path("$STATE").read_text(encoding="utf-8")

def grab_block(key):
    m = re.search(rf"^{key}:\n([\s\S]*?)(\n\w+:|\Z)", state, re.M)
    return (m.group(1).strip() if m else "")

priorities = grab_block("priorities")
decisions = grab_block("decisions_pending")
risks = grab_block("risks")
commitments = grab_block("commitments")

today = "$TODAY"
out = Path("$OUT")

content = f"""# Morning Brief - {today}

## Top priorities (keep to 3)
{priorities or "- [update EXECUTIVE-STATE.yaml]"}

## Decisions pending
{decisions or "- [none]"}

## Commitments coming due
{commitments or "- [none]"}

## Risks
{risks or "- [none]"}

## Today, the three moves
1)
2)
3)
"""

out.write_text(content, encoding="utf-8")
print(str(out))
PY
