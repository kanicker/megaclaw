#!/usr/bin/env bash
set -euo pipefail

# End of day reflection plus next day predictions
# Reads today's memory and writes a prediction block to tomorrow's memory file.

WORKSPACE="${OPENCLAW_WORKSPACE_DIR:-$HOME/openclaw-docker-workspace}"
MEM_DIR="$WORKSPACE/memory"
TODAY="$(date +%Y-%m-%d)"

# Portable "tomorrow" calculation (macOS, GNU date, or python3 fallback)
tomorrow() {
  if date -v+1d +%Y-%m-%d >/dev/null 2>&1; then
    date -v+1d +%Y-%m-%d
    return
  fi
  if date -d "tomorrow" +%Y-%m-%d >/dev/null 2>&1; then
    date -d "tomorrow" +%Y-%m-%d
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import datetime
print((datetime.date.today() + datetime.timedelta(days=1)).isoformat())
PY
    return
  fi
  echo "Could not compute tomorrow date. Install python3." >&2
  exit 1
}

TOMORROW="$(tomorrow)"
TODAY_FILE="$MEM_DIR/$TODAY.md"
TOM_FILE="$MEM_DIR/$TOMORROW.md"

if [ ! -d "$MEM_DIR" ]; then
  echo "Memory dir not found: $MEM_DIR" >&2
  exit 1
fi

if [ ! -f "$TODAY_FILE" ]; then
  echo "Today's memory file not found: $TODAY_FILE" >&2
  exit 1
fi

# Ensure tomorrow file exists
if [ ! -f "$TOM_FILE" ]; then
  cat > "$TOM_FILE" <<EOF
# Daily Memory Log - $TOMORROW

## Summary (from $TODAY)
- [pending]

## Predictions (from $TODAY)
- [pending]

## Context from yesterday
- [pending]

EOF
fi

# Use openclaw CLI if available; otherwise leave placeholders
if command -v openclaw >/dev/null 2>&1; then
  PROMPT=$(cat <<'PROMPT'
Read today's memory log and produce:
1) A 3-5 bullet summary
2) 3-5 predictions for tomorrow
3) Key context to carry forward
Output in this exact format:
Summary:
- ...
Predictions:
- ...
Context:
- ...
PROMPT
)

  OUT=$(openclaw chat --prompt "$PROMPT" --file "$TODAY_FILE" 2>/dev/null || true)
  if [ -n "$OUT" ]; then
    SUMMARY=$(echo "$OUT" | awk '/^Summary:/{flag=1;next}/^Predictions:/{flag=0}flag')
    PRED=$(echo "$OUT" | awk '/^Predictions:/{flag=1;next}/^Context:/{flag=0}flag')
    CTX=$(echo "$OUT" | awk '/^Context:/{flag=1;next}flag')

    export SUMMARY PRED CTX TODAY TOMORROW

    python3 - <<'PY'
import os, re
from pathlib import Path

tom_file = Path(os.environ["TOM_FILE"]) if "TOM_FILE" in os.environ else None
# TOM_FILE is not exported by default in some shells, so rebuild safely
work = os.environ.get("OPENCLAW_WORKSPACE_DIR") or (Path.home() / "openclaw-docker-workspace")
mem_dir = Path(work) / "memory"
tomorrow = os.environ["TOMORROW"]
today = os.environ["TODAY"]
tom_file = mem_dir / f"{tomorrow}.md"

summary = (os.environ.get("SUMMARY") or "").strip()
pred = (os.environ.get("PRED") or "").strip()
ctx = (os.environ.get("CTX") or "").strip()

text = tom_file.read_text(encoding="utf-8")

def replace_section(text, header, body):
    if not body:
        return text
    pattern = rf"({re.escape(header)}\n)([\s\S]*?)(\n## |\Z)"
    m = re.search(pattern, text)
    if not m:
        return text
    pre, tail = m.group(1), m.group(3)
    return re.sub(pattern, lambda mm: pre + body + "\n\n" + tail, text, count=1)

text = replace_section(text, f"## Summary (from {today})", summary)
text = replace_section(text, f"## Predictions (from {today})", pred)
text = replace_section(text, "## Context from yesterday", ctx)

text = text.replace("- [pending]\n", "")
tom_file.write_text(text, encoding="utf-8")
PY
  fi
else
  echo "openclaw CLI not found; leaving placeholders in $TOM_FILE" >&2
fi

echo "Wrote predictions to $TOM_FILE"
