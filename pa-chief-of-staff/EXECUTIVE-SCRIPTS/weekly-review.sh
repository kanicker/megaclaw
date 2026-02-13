#!/usr/bin/env bash
set -euo pipefail

# Generate a weekly review packet
# Output: reviews/YYYY-MM-DD.md

WORKSPACE="${OPENCLAW_WORKSPACE_DIR:-$HOME/openclaw-docker-workspace}"
OUTDIR="$WORKSPACE/reviews"
TODAY="$(date +%Y-%m-%d)"
OUT="$OUTDIR/$TODAY.md"

mkdir -p "$OUTDIR"

python3 - <<PY
from pathlib import Path
today = "$TODAY"
out = Path("$OUT")
content = f"""# Weekly Review - {today}

## Wins
- 

## Misses and lessons
- 

## Priorities next week (max 3)
1)
2)
3)

## Decisions to make next week
- 

## Stakeholder touches
- 

## Risks to mitigate
- 

## Systems
- What should we stop doing?
- What should we automate?
"""
out.write_text(content, encoding="utf-8")
print(str(out))
PY
