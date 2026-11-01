## ADDED Requirements

### Requirement: Repeatable performance tools
`perf_bench`, `perf_render`, `perf_load` and `perf_shot` produce numbers or images that are identical or within machine noise between runs.

#### Scenario: Screenshot noise
- **WHEN** `perf_shot` runs twice on the same code
- **THEN** `compare_shots.py` reports 0.000 % difference
