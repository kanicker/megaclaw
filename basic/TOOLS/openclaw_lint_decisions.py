#!/usr/bin/env python3
"""
openclaw_lint_decisions.py (v3.1)

Advisory linter for decision records.
- Detects DECISION blocks missing required fields
- Flags multiple ACTIVE decisions with the same "Decision:" line (simple collision heuristic)
Non-blocking: returns non-zero on issues, but does not modify files.
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

REQ_FIELDS = ["Decision:", "Approved by:", "Date:", "Status:"]

DECISION_BLOCK_RE = re.compile(r"\[DECISION\](.*?)(?=\n\[|\Z)", re.DOTALL)

def scan_text(text: str):
    blocks = []
    for m in DECISION_BLOCK_RE.finditer(text):
        blk = m.group(0)
        blocks.append(blk)
    return blocks

def extract_field(block: str, prefix: str):
    for line in block.splitlines():
        if line.strip().startswith(prefix):
            return line.split(prefix,1)[1].strip()
    return None

def main():
    # Default: lint MEMORY.md and GLOBAL-STATE.yaml if present in cwd.
    paths = [Path("MEMORY.md"), Path("GLOBAL-STATE.yaml")]
    # allow args
    if len(sys.argv) > 1:
        paths = [Path(a) for a in sys.argv[1:]]
    issues = 0
    active_decisions = []
    for p in paths:
        if not p.exists():
            continue
        text = p.read_text(encoding="utf-8", errors="ignore")
        blocks = scan_text(text)
        for b in blocks:
            missing = [f for f in REQ_FIELDS if f not in b]
            if missing:
                issues += 1
                print(f"[WARN] {p}: DECISION block missing fields: {', '.join(missing)}")
            status = extract_field(b, "Status:")
            decision = extract_field(b, "Decision:")
            if status and status.upper() == "ACTIVE" and decision:
                active_decisions.append((decision, p))
    # collision heuristic: same decision string repeated ACTIVE
    seen = {}
    for d, p in active_decisions:
        if d in seen:
            issues += 1
            print(f"[WARN] ACTIVE decision appears multiple times: '{d}' in {seen[d]} and {p}")
        else:
            seen[d] = p
    if issues:
        print(f"\nLint complete: {issues} issue(s) found.")
        return 2
    print("Lint complete: no issues found.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
