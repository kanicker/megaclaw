# Memory System Implementation Guide

## Goal
Build a reliable, persistent memory system that improves coherence, prediction accuracy, and error correction without claiming consciousness.

## Components
1) **Global State Ledger** — structured state of **goals, hypotheses, constraints, conflicts, predictions** (not just predictions)
2) **Prediction‑before‑Action** — explicit expected outcomes pre‑tool
3) **Error‑Delta Updater** — immediate state updates after action
4) **Consistency Resolver** — detect/resolve contradictions
5) **Benchmark Harness** — measurable stability tests

## Implementation Steps
1. Add the Global State Ledger file (see **GLOBAL-STATE-SCHEMA.md**).
2. Require a prediction step before tool calls (**PREDICTION-PROTOCOL.md**).
3. After each tool call, compute error delta (**ERROR-DELTA-UPDATER.md**).
4. Run contradiction checks after updates (**CONSISTENCY-RESOLVER.md**).
5. Test with benchmark scenarios (**BENCHMARK-HARNESS.md**).

## Guardrails
- Do **not** claim consciousness.
- Use theory as heuristics only.
- Evaluate by measurable improvements.
