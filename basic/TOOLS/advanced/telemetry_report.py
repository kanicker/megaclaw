#!/usr/bin/env python3
"""
telemetry_report.py (v3.1)

Generates a local summary of telemetry metrics.jsonl.
"""
from __future__ import annotations
import json
from collections import Counter, defaultdict
from pathlib import Path
import argparse

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--workspace", required=True)
    args = ap.parse_args()
    ws = Path(args.workspace).expanduser()
    path = ws / "telemetry" / "metrics.jsonl"
    if not path.exists():
        print("No telemetry found (metrics.jsonl missing).")
        return 1

    events = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line=line.strip()
            if not line: 
                continue
            try:
                events.append(json.loads(line))
            except Exception:
                continue

    c = Counter(e.get("event","") for e in events if e.get("event"))
    print("Telemetry summary")
    print("=================")
    print(f"Events: {len(events)}")
    for k,v in c.most_common():
        print(f"- {k}: {v}")

    # Basic compliance proxies
    decision_prompt = c.get("decision_prompt_shown", 0)
    decision_recorded = c.get("decision_recorded", 0)
    lint_runs = c.get("lint_run", 0)
    print("")
    if decision_prompt:
        ratio = decision_recorded / decision_prompt
        print(f"Decision prompt -> decision recorded ratio: {ratio:.2f}")
    if lint_runs:
        print(f"Linter runs: {lint_runs}")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
