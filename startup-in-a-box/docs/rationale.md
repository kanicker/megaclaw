# Rationale — Why Each Feature Exists (v3.1)

This document explains the **intent** behind each system component, to keep the model coherent during customization.

---

## Federated state
**Feature:** Each department owns its own `DEPT-STATE.yaml`.

**Why:** Prevents a single, sprawling state file that no agent can hold. Departments get autonomy without risking global corruption.

---

## Board Room isolation
**Feature:** Only Chief of Staff can write to `/company/BOARD-ROOM/**`.

**Why:** Company‑level decisions and goals must remain stable and curated, not overwritten by local agents or chat injection.

---

## Weekly reports
**Feature:** Standardized `WEEKLY-REPORT.md`.

**Why:** Forces explicit articulation of wins, misses, risks, and decisions. It prevents “hidden work” and makes misalignment visible.

---

## Sync Summary (YAML)
**Feature:** Fenced YAML block under “Sync Summary (for Chief of Staff)”.

**Why:** LLMs are creative with prose. YAML forces deterministic extraction for automation while preserving human readability.

---

## Legacy fallback parsing
**Feature:** `sync_v3.py` falls back to bullet parsing.

**Why:** Backward compatibility and resilience during transitions or partially migrated teams.

---

## Sync warnings
**Feature:** Draft output includes a “Sync Warnings” section.

**Why:** Missing or malformed reports are a leading cause of silent drift. Warnings surface problems immediately.

---

## Chat as transport
**Feature:** `CHANNEL-MAPPING.md` defines roles, but authority lives in files.

**Why:** Chat is ephemeral and easy to manipulate. Files are durable and auditable.

---

## Decision ledger
**Feature:** `BOARD-DECISIONS.md` is the source of truth for decisions.

**Why:** Agents can’t coordinate at scale without a stable decision record. This prevents contradictory directives.

---

## Company Pulse
**Feature:** `COMPANY-PULSE.md` is the official executive summary.

**Why:** It’s the living signal of company state, used to orient all departments.

---

## Requirements file
**Feature:** `requirements.txt` includes PyYAML.

**Why:** Parsing YAML is a critical sync path. Dependencies must be explicit and install‑safe.
