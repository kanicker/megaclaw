# Benchmark Harness

## Goal
Validate measurable improvements in coherence and error correction.

## Metrics
- Contradiction rate across sessions
- Prediction accuracy vs outcomes
- Repeated error rate
- Recovery time after perturbation

## Tests
1) **Adversarial perturbation** — introduce conflicting constraints mid‑task
2) **Noisy feedback** — tool outputs with partial failures
3) **Scaffolding reduction** — remove parts of the protocol and observe stability

## Pass Criteria
- Improvements on all metrics versus baseline
- No collapse when scaffolding is partially removed
