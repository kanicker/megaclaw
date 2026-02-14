#!/usr/bin/env python3
"""
openclaw_resolve_decisions.py (v3.1)

Decision collision resolver with GLOBAL-STATE.yaml as canonical authority.

Features:
- Scans GLOBAL-STATE.yaml for [DECISION] blocks
- Optionally scans MEMORY.md and memory/*.md as advisory sources
- Detects:
  - duplicate ACTIVE decisions (exact normalized match)
  - near-duplicate ACTIVE decisions (token Jaccard similarity)
  - missing required fields
  - missing Superseded-by pointer on SUPERSEDED
- Writes:
  - RESOLUTION-DRAFT.yaml (machine readable)
  - RESOLUTION-DRAFT.md  (human readable)
  - RESOLUTION-PATCH.diff (optional, for GLOBAL-STATE.yaml only)
- Apply mode:
  - Applies SAFE changes automatically: exact duplicate ACTIVE -> keep newest ACTIVE, supersede older
  - Applies gated changes only with --approve "APPROVE STRUCTURAL CHANGE: DECISION-RESOLVE"

This tool never edits memory files. It edits GLOBAL-STATE.yaml only.
"""
from __future__ import annotations
import argparse
import datetime
import hashlib
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Dict, Optional, Tuple

DECISION_RE = re.compile(r"\[DECISION\](.*?)(?=\n\[|\Z)", re.DOTALL)

REQ_FIELDS = ["Decision:", "Approved by:", "Date:", "Status:"]
STATUS_OK = {"ACTIVE", "SUPERSEDED"}

STOPWORDS = {
    "the","a","an","to","of","and","or","for","in","on","at","with","we","our","is","are","be","this","that","it","as"
}

def norm_text(s: str) -> str:
    s = s.lower()
    s = re.sub(r"[^a-z0-9\s]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s

def tokens(s: str) -> List[str]:
    t = [w for w in norm_text(s).split(" ") if w and w not in STOPWORDS]
    return t

def jaccard(a: List[str], b: List[str]) -> float:
    sa, sb = set(a), set(b)
    if not sa and not sb:
        return 0.0
    return len(sa & sb) / len(sa | sb)

def sha10(s: str) -> str:
    return hashlib.sha1(s.encode("utf-8")).hexdigest()[:10]

def extract_field(block: str, prefix: str) -> Optional[str]:
    for line in block.splitlines():
        line_s = line.strip()
        if line_s.startswith(prefix):
            return line_s.split(prefix, 1)[1].strip()
    return None

def extract_multifield(block: str) -> Dict[str, str]:
    out = {}
    for p in ["Decision:", "Approved by:", "Date:", "Status:", "Domain:", "Superseded by:"]:
        v = extract_field(block, p)
        if v:
            out[p[:-1]] = v
    return out

@dataclass
class Decision:
    source: str
    block: str
    decision: str
    approved_by: Optional[str]
    date: Optional[str]
    status: str
    domain: str
    superseded_by: Optional[str]
    key: str
    key_norm: str
    line_start: int
    line_end: int

def parse_decisions(text: str, source: str) -> List[Decision]:
    decisions = []
    # compute line positions by counting newlines up to match start/end
    for m in DECISION_RE.finditer(text):
        blk = "[DECISION]" + m.group(1)
        # approximate line numbers in source text
        start_idx = m.start()
        end_idx = m.end()
        line_start = text.count("\n", 0, start_idx) + 1
        line_end = text.count("\n", 0, end_idx) + 1

        decision = extract_field(blk, "Decision:") or ""
        approved = extract_field(blk, "Approved by:")
        date = extract_field(blk, "Date:")
        status = (extract_field(blk, "Status:") or "").upper()
        domain = (extract_field(blk, "Domain:") or "unknown").strip().lower()
        superseded_by = extract_field(blk, "Superseded by:")
        key_norm = " ".join(tokens(decision))
        key = sha10(key_norm) if key_norm else sha10(norm_text(decision))
        decisions.append(Decision(
            source=source,
            block=blk,
            decision=decision,
            approved_by=approved,
            date=date,
            status=status,
            domain=domain,
            superseded_by=superseded_by,
            key=key,
            key_norm=key_norm,
            line_start=line_start,
            line_end=line_end,
        ))
    return decisions

def load_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="ignore")

def ensure_workspace(ws: Path):
    ws.mkdir(parents=True, exist_ok=True)

def write_yaml(ws: Path, obj: dict, name: str):
    # Avoid PyYAML dependency: emit simple YAML-ish format deterministically for our data.
    # This is a limited serializer sufficient for our draft structure.
    def dump(o, indent=0):
        sp = "  " * indent
        if isinstance(o, dict):
            lines = []
            for k, v in o.items():
                if isinstance(v, (dict, list)):
                    lines.append(f"{sp}{k}:")
                    lines.extend(dump(v, indent+1))
                else:
                    vv = json.dumps(v) if isinstance(v, str) else str(v).lower() if isinstance(v, bool) else str(v)
                    # remove surrounding quotes for simple strings
                    if isinstance(v, str) and re.fullmatch(r"[A-Za-z0-9_\-\.]+", v):
                        vv = v
                    lines.append(f"{sp}{k}: {vv}")
            return lines
        if isinstance(o, list):
            lines = []
            for it in o:
                if isinstance(it, (dict, list)):
                    lines.append(f"{sp}-")
                    lines.extend(dump(it, indent+1))
                else:
                    vv = json.dumps(it) if isinstance(it, str) else str(it)
                    if isinstance(it, str) and re.fullmatch(r"[A-Za-z0-9_\-\.]+", it):
                        vv = it
                    lines.append(f"{sp}- {vv}")
            return lines
        return [f"{sp}{o}"]
    txt = "\n".join(dump(obj)) + "\n"
    (ws / name).write_text(txt, encoding="utf-8")

def write_md(ws: Path, txt: str, name: str):
    (ws / name).write_text(txt, encoding="utf-8")

def build_patch(global_state_path: Path, replacements: List[Tuple[Decision, str]]) -> str:
    """
    Build a unified diff patch for GLOBAL-STATE.yaml where each replacement is
    (original decision, new block text).
    """
    import difflib
    original = load_text(global_state_path).splitlines(keepends=False)
    modified = original[:]

    # Apply replacements from bottom to top to keep line ranges stable
    for dec, new_block in sorted(replacements, key=lambda x: x[0].line_start, reverse=True):
        # replace the exact block lines (approx); safer: locate block text
        # We will search for the block string in the file and replace first occurrence.
        file_text = "\n".join(modified)
        idx = file_text.find(dec.block)
        if idx == -1:
            # fallback: skip
            continue
        before = file_text[:idx]
        after = file_text[idx+len(dec.block):]
        file_text2 = before + new_block + after
        modified = file_text2.splitlines(keepends=False)

    diff = difflib.unified_diff(original, modified, fromfile=str(global_state_path), tofile=str(global_state_path), lineterm="")
    return "\n".join(diff) + "\n"

def safe_duplicate_resolution(active: List[Decision]) -> Tuple[List[Dict], List[Tuple[Decision, str]]]:
    """
    Resolve exact duplicates (same key_norm) inside GLOBAL-STATE:
    Keep newest by Date if parseable; else keep last in file. Supersede others.
    Returns actions list and replacements list.
    """
    # group by key_norm (or decision text if empty)
    groups: Dict[str, List[Decision]] = {}
    for d in active:
        gk = d.key_norm or norm_text(d.decision)
        groups.setdefault(gk, []).append(d)
    actions = []
    replacements = []
    for gk, ds in groups.items():
        if len(ds) < 2:
            continue
        # select winner
        def date_key(d: Decision):
            try:
                return d.date or ""
            except Exception:
                return ""
        # sort by date then line_start
        ds_sorted = sorted(ds, key=lambda d: (date_key(d), d.line_start))
        winner = ds_sorted[-1]
        losers = [d for d in ds_sorted if d is not winner]

        for lo in losers:
            # create superseded block by modifying Status and adding Superseded by
            lines = lo.block.splitlines()
            out_lines = []
            saw_status = False
            saw_sup = False
            for ln in lines:
                if ln.strip().startswith("Status:"):
                    out_lines.append("Status: SUPERSEDED")
                    saw_status = True
                elif ln.strip().startswith("Superseded by:"):
                    out_lines.append(f"Superseded by: {winner.key}")
                    saw_sup = True
                else:
                    out_lines.append(ln)
            if not saw_status:
                out_lines.append("Status: SUPERSEDED")
            if not saw_sup:
                out_lines.append(f"Superseded by: {winner.key}")
            new_block = "\n".join(out_lines)
            replacements.append((lo, new_block))
            actions.append({
                "type": "auto_supersede_duplicate_active",
                "winner_key": winner.key,
                "loser_key": lo.key,
                "domain": lo.domain,
            })
    return actions, replacements

def detect_collisions(global_decisions: List[Decision], similarity_threshold: float = 0.65) -> Dict:
    issues = []
    actions = []
    gated = []

    # field validation for GLOBAL-STATE decisions
    for d in global_decisions:
        missing = []
        for f in REQ_FIELDS:
            if f not in d.block:
                missing.append(f)
        if d.status and d.status not in STATUS_OK:
            missing.append("Status: (must be ACTIVE or SUPERSEDED)")
        if missing:
            issues.append({"type":"missing_fields","key":d.key,"domain":d.domain,"missing":missing,"lines":[d.line_start,d.line_end]})
        if d.status == "SUPERSEDED" and not d.superseded_by:
            issues.append({"type":"missing_superseded_by","key":d.key,"domain":d.domain,"lines":[d.line_start,d.line_end]})

    active = [d for d in global_decisions if d.status == "ACTIVE"]
    # Safe duplicate resolution actions and replacements generated separately in apply
    # Near duplicates and competing domain actives are gated proposals
    # Build similarity comparisons within same domain first, then across unknown domain.
    for i in range(len(active)):
        for j in range(i+1, len(active)):
            a, b = active[i], active[j]
            if a.key == b.key:
                continue
            # only compare if same domain or either unknown
            if a.domain != b.domain and a.domain != "unknown" and b.domain != "unknown":
                continue
            sim = jaccard(tokens(a.decision), tokens(b.decision))
            if sim >= similarity_threshold:
                gated.append({
                    "type":"near_duplicate_active",
                    "a_key": a.key,
                    "b_key": b.key,
                    "domain": a.domain if a.domain != "unknown" else b.domain,
                    "similarity": round(sim, 2),
                    "recommendation": "Merge into one canonical ACTIVE decision and SUPERSEDE the other(s). Requires owner approval.",
                })
    return {"issues": issues, "gated": gated}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["scan", "apply"])
    ap.add_argument("--workspace", required=True, help="Workspace root where output drafts are written")
    ap.add_argument("--kit_dir", default=".", help="Kit directory containing GLOBAL-STATE.yaml if not in workspace")
    ap.add_argument("--global_state", default=None, help="Path to GLOBAL-STATE.yaml (defaults to <kit_dir>/GLOBAL-STATE.yaml)")
    ap.add_argument("--include_memory", action="store_true", help="Also scan MEMORY.md and memory/*.md as advisory")
    ap.add_argument("--approve", default="", help='Approval token for gated applies, e.g. "APPROVE STRUCTURAL CHANGE: DECISION-RESOLVE"')
    ap.add_argument("--similarity", type=float, default=0.65)
    args = ap.parse_args()

    ws = Path(args.workspace).expanduser()
    ensure_workspace(ws)

    kit_dir = Path(args.kit_dir).expanduser()
    gs_path = Path(args.global_state).expanduser() if args.global_state else (kit_dir / "GLOBAL-STATE.yaml")
    if not gs_path.exists():
        print(f"[ERROR] GLOBAL-STATE.yaml not found at {gs_path}", file=sys.stderr)
        return 2

    gs_text = load_text(gs_path)
    global_decisions = parse_decisions(gs_text, "GLOBAL-STATE.yaml")

    # Advisory memory scan
    memory_decisions = []
    if args.include_memory:
        mem_path = kit_dir / "MEMORY.md"
        if mem_path.exists():
            memory_decisions.extend(parse_decisions(load_text(mem_path), "MEMORY.md"))
        mem_dir = kit_dir / "memory"
        if mem_dir.exists() and mem_dir.is_dir():
            for p in sorted(mem_dir.glob("*.md")):
                memory_decisions.extend(parse_decisions(load_text(p), f"memory/{p.name}"))

    collisions = detect_collisions(global_decisions, similarity_threshold=args.similarity)

    # Prepare scan output
    scan_out = {
        "meta": {
            "generated": datetime.datetime.utcnow().isoformat() + "Z",
            "global_state_path": str(gs_path),
            "include_memory": bool(args.include_memory),
            "similarity_threshold": args.similarity,
        },
        "summary": {
            "global_decisions": len(global_decisions),
            "global_active": len([d for d in global_decisions if d.status=="ACTIVE"]),
            "issues": len(collisions["issues"]),
            "gated": len(collisions["gated"]),
        },
        "issues": collisions["issues"],
        "gated": collisions["gated"],
        "safe_auto_actions": [],
    }

    # Always compute what safe auto changes WOULD be (but only apply in apply)
    safe_actions, replacements = safe_duplicate_resolution([d for d in global_decisions if d.status=="ACTIVE"])
    scan_out["safe_auto_actions"] = safe_actions

    # Write drafts
    write_yaml(ws, scan_out, "RESOLUTION-DRAFT.yaml")

    md = []
    md.append("# Decision Resolution Draft")
    md.append("")
    md.append(f"- Generated: {scan_out['meta']['generated']}")
    md.append(f"- Global decisions: {scan_out['summary']['global_decisions']}")
    md.append(f"- Global ACTIVE: {scan_out['summary']['global_active']}")
    md.append(f"- Issues: {scan_out['summary']['issues']}")
    md.append(f"- Gated proposals: {scan_out['summary']['gated']}")
    md.append("")
    if scan_out["issues"]:
        md.append("## Issues (must fix)")
        for it in scan_out["issues"]:
            md.append(f"- {it['type']} | key={it['key']} | domain={it.get('domain','unknown')} | lines={it['lines']}")
            if it.get("missing"):
                md.append(f"  - missing: {', '.join(it['missing'])}")
        md.append("")
    if scan_out["safe_auto_actions"]:
        md.append("## Safe auto actions (applyable without approval)")
        for a in scan_out["safe_auto_actions"]:
            md.append(f"- {a['type']} | winner={a['winner_key']} | loser={a['loser_key']} | domain={a.get('domain','unknown')}")
        md.append("")
    if scan_out["gated"]:
        md.append("## Gated proposals (require owner approval)")
        for g in scan_out["gated"]:
            md.append(f"- {g['type']} | a={g['a_key']} | b={g['b_key']} | domain={g.get('domain','unknown')} | similarity={g.get('similarity')}")
            md.append(f"  - {g['recommendation']}")
        md.append("")
    md.append("## Apply instructions")
    md.append("")
    md.append("1) Scan:")
    md.append("```bash")
    md.append(f"python3 TOOLS/openclaw_resolve_decisions.py scan --workspace \"{ws}\" --kit_dir .")
    md.append("```")
    md.append("")
    md.append("2) Apply safe auto fixes:")
    md.append("```bash")
    md.append(f"python3 TOOLS/openclaw_resolve_decisions.py apply --workspace \"{ws}\" --kit_dir .")
    md.append("```")
    md.append("")
    md.append("3) Apply gated changes (requires approval token):")
    md.append("```bash")
    md.append("python3 TOOLS/openclaw_resolve_decisions.py apply --workspace \"<workspace>\" --kit_dir . \\")
    md.append("  --approve \"APPROVE STRUCTURAL CHANGE: DECISION-RESOLVE\"")
    md.append("```")
    write_md(ws, "\n".join(md) + "\n", "RESOLUTION-DRAFT.md")

    # Patch output (only for safe replacements computed now; gated merges are proposals)
    patch_text = build_patch(gs_path, replacements) if replacements else ""
    if patch_text.strip():
        write_md(ws, patch_text, "RESOLUTION-PATCH.diff")

    if args.cmd == "scan":
        print(f"Wrote {ws/'RESOLUTION-DRAFT.yaml'} and {ws/'RESOLUTION-DRAFT.md'}")
        if patch_text.strip():
            print(f"Wrote {ws/'RESOLUTION-PATCH.diff'} (safe auto fixes)")
        return 0

    # apply
    # apply safe replacements
    applied_any = False
    if replacements:
        # apply by replacing blocks in file text
        file_text = gs_text
        for dec, new_block in sorted(replacements, key=lambda x: x[0].line_start, reverse=True):
            idx = file_text.find(dec.block)
            if idx == -1:
                continue
            file_text = file_text[:idx] + new_block + file_text[idx+len(dec.block):]
            applied_any = True
        if applied_any:
            gs_path.write_text(file_text, encoding="utf-8")
            print("[OK] Applied safe duplicate ACTIVE supersede edits to GLOBAL-STATE.yaml")
    else:
        print("[OK] No safe duplicate ACTIVE collisions found.")

    # gated apply placeholder (future): we do not auto-merge; require approval
    if args.approve.strip():
        if args.approve.strip() != "APPROVE STRUCTURAL CHANGE: DECISION-RESOLVE":
            print("[WARN] Approval token not recognized; gated changes not applied.")
        else:
            # For now, gated changes remain proposals only.
            # Future enhancement: read RESOLUTION-DRAFT.yaml 'selected' actions and apply.
            print("[NOTE] Approval recognized. No gated actions selected in this version; proposals remain in RESOLUTION-DRAFT.md.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
