#!/usr/bin/env python3
import re
from datetime import datetime
from pathlib import Path

ROOT = Path("company")
BOARD_ROOM = ROOT / "BOARD-ROOM"
OUTPUT = BOARD_ROOM / "COMPANY-PULSE-DRAFT.md"

DEPTS = ["ENGINEERING", "PRODUCT", "SALES", "FINANCE", "PEOPLE"]

# v3.1: prefer fenced YAML block under the Sync Summary heading
SYNC_YAML_BLOCK_RE = re.compile(
    r"##\s*Sync Summary\s*\(for Chief of Staff\).*?```yaml\s*(.*?)\s*```",
    re.DOTALL | re.IGNORECASE
)

# Legacy support: bullet list style
SYNC_LEGACY_RE = re.compile(
    r"## Sync Summary \(for Chief of Staff\)(.*?)(?:\n## |\Z)",
    re.DOTALL | re.IGNORECASE
)

REQUESTS_RE = re.compile(
    r"## 7\)\s*Requests to the Board Room(.*?)(?:\n## |\Z)",
    re.DOTALL | re.IGNORECASE
)

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""
    except Exception as e:
        return f"ERROR reading {path}: {e}"

def normalize(block: str) -> str:
    lines = [ln.rstrip() for ln in block.splitlines()]
    cleaned = []
    prev_blank = False
    for ln in lines:
        blank = (ln.strip() == "")
        if blank and prev_blank:
            continue
        cleaned.append(ln)
        prev_blank = blank
    return "\n".join(cleaned).strip()

def extract_requests(text: str) -> str:
    m = REQUESTS_RE.search(text)
    return normalize(m.group(1)) if m else ""

def parse_sync_yaml(text: str):
    """
    Returns a tuple: (data_dict or None, warning_str or "")
    Expected keys: wins, misses, decisions_needed, misalignment_concerns (all lists of strings).
    """
    m = SYNC_YAML_BLOCK_RE.search(text)
    if not m:
        return None, "Missing fenced YAML sync block."
    payload = m.group(1).strip()
    try:
        import yaml  # type: ignore
    except Exception:
        return None, "PyYAML not available; cannot parse fenced YAML sync block."
    try:
        data = yaml.safe_load(payload) or {}
    except Exception as e:
        return None, f"Invalid YAML in sync block: {e}"

    # Normalize expected keys to lists
    def as_list(v):
        if v is None:
            return []
        if isinstance(v, list):
            return [str(x).strip() for x in v if str(x).strip()]
        # allow single string
        if isinstance(v, str):
            s = v.strip()
            return [s] if s else []
        return [str(v).strip()] if str(v).strip() else []

    normalized = {
        "wins": as_list(data.get("wins")),
        "misses": as_list(data.get("misses")),
        "decisions_needed": as_list(data.get("decisions_needed")),
        "misalignment_concerns": as_list(data.get("misalignment_concerns")),
    }
    return normalized, ""

def parse_sync_legacy(text: str):
    """
    Legacy bullet parser: looks for '- Wins:' etc. under the legacy Sync Summary section.
    """
    m = SYNC_LEGACY_RE.search(text)
    if not m:
        return None
    block = normalize(m.group(1))

    def grab_list(header: str) -> list[str]:
        pat = re.compile(rf"-\s*{re.escape(header)}:\s*(.*?)(?=\n-\s*\w|\Z)", re.DOTALL | re.IGNORECASE)
        mm = pat.search(block)
        if not mm:
            return []
        body = mm.group(1).strip()
        items = []
        for ln in body.splitlines():
            s = ln.strip()
            if s.startswith("-"):
                items.append(s[1:].strip())
        return [i for i in items if i]

    return {
        "wins": grab_list("Wins"),
        "misses": grab_list("Misses"),
        "decisions_needed": grab_list("Decisions needed"),
        "misalignment_concerns": grab_list("Misalignment concerns"),
    }

def main():
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    BOARD_ROOM.mkdir(parents=True, exist_ok=True)

    sections = []
    sections.append(f"# COMPANY PULSE (Draft)\nGenerated: {now}\n")
    sections.append("## Executive Summary (fill after review)\n- \n")

    wins = []
    misses = []
    decisions_needed = []
    misalignments = []
    dept_summaries = []
    warnings = []

    for dept in DEPTS:
        report_path = ROOT / dept / "WEEKLY-REPORT.md"
        txt = read_text(report_path)
        if not txt or txt.startswith("ERROR"):
            dept_summaries.append(f"## {dept}\n- Missing report: {report_path}\n")
            warnings.append(f"{dept}: Missing WEEKLY-REPORT.md")
            continue

        sync_data, warn = parse_sync_yaml(txt)
        if sync_data is None:
            # fall back to legacy parsing
            legacy = parse_sync_legacy(txt)
            if legacy:
                sync_data = legacy
                warn = warn + " Used legacy bullet parsing."
            else:
                # no usable sync summary
                sync_data = {"wins": [], "misses": [], "decisions_needed": [], "misalignment_concerns": []}
        if warn:
            warnings.append(f"{dept}: {warn}".strip())

        req_block = extract_requests(txt)

        wins += [f"{dept}: {w}" for w in sync_data["wins"]]
        misses += [f"{dept}: {m}" for m in sync_data["misses"]]
        decisions_needed += [f"{dept}: {d}" for d in sync_data["decisions_needed"]]
        misalignments += [f"{dept}: {x}" for x in sync_data["misalignment_concerns"]]

        dept_summaries.append(f"## {dept}\n")
        dept_summaries.append("### Sync Summary (parsed)\n")
        dept_summaries.append("\n".join(
            [
                "Wins:",
                *[f"- {w}" for w in sync_data["wins"]] or ["- (none)"],
                "Misses:",
                *[f"- {m}" for m in sync_data["misses"]] or ["- (none)"],
                "Decisions needed:",
                *[f"- {d}" for d in sync_data["decisions_needed"]] or ["- (none)"],
                "Misalignment concerns:",
                *[f"- {x}" for x in sync_data["misalignment_concerns"]] or ["- (none)"],
                ""
            ]
        ))

        if req_block:
            dept_summaries.append("### Requests to the Board Room (raw)\n" + req_block + "\n")

    if warnings:
        sections.append("## Sync Warnings\n" + "\n".join(f"- {w}" for w in warnings) + "\n")

    sections.append("## Wins (compiled)\n" + ("\n".join(f"- {w}" for w in wins) if wins else "- None reported") + "\n")
    sections.append("## Misses (compiled)\n" + ("\n".join(f"- {m}" for m in misses) if misses else "- None reported") + "\n")
    sections.append("## Decisions Needed (compiled)\n" + ("\n".join(f"- {d}" for d in decisions_needed) if decisions_needed else "- None reported") + "\n")
    sections.append("## Misalignment Concerns (compiled)\n" + ("\n".join(f"- {x}" for x in misalignments) if misalignments else "- None reported") + "\n")

    sections.append("## Department Summaries\n" + "\n".join(dept_summaries))

    OUTPUT.write_text("\n".join(sections).strip() + "\n", encoding="utf-8")
    print(f"Wrote draft: {OUTPUT}")

if __name__ == "__main__":
    main()
