#!/usr/bin/env python3
"""
telemetry.py (v3.1)

Local-only event logger. Writes JSON lines to:
  <workspace>/telemetry/metrics.jsonl

No content is logged. Events are counts and timestamps only.
"""
from __future__ import annotations
import argparse, json, os, time, uuid
from pathlib import Path

def workspace_id(workspace: Path) -> str:
    tid = workspace / "telemetry" / "workspace_id"
    if tid.exists():
        return tid.read_text(encoding="utf-8").strip()
    wid = str(uuid.uuid4())
    tid.parent.mkdir(parents=True, exist_ok=True)
    tid.write_text(wid, encoding="utf-8")
    return wid

def emit(workspace: Path, event: str, kit_version: str, data: dict):
    tel_dir = workspace / "telemetry"
    tel_dir.mkdir(parents=True, exist_ok=True)
    row = {
        "ts": int(time.time()),
        "event": event,
        "kit_version": kit_version,
        "workspace_id": workspace_id(workspace),
        "data": data or {},
    }
    with (tel_dir / "metrics.jsonl").open("a", encoding="utf-8") as f:
        f.write(json.dumps(row, separators=(",", ":")) + "\n")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("event")
    ap.add_argument("--workspace", required=True)
    ap.add_argument("--kit_version", default="unknown")
    ap.add_argument("--data", default="{}")
    args = ap.parse_args()

    if os.environ.get("OPENCLAW_TELEMETRY_ENABLED", "0") != "1":
        return 0

    ws = Path(args.workspace).expanduser()
    try:
        data = json.loads(args.data)
        if not isinstance(data, dict):
            data = {}
    except Exception:
        data = {}
    emit(ws, args.event, args.kit_version, data)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
