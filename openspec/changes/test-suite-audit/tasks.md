## 1. Audit

- [x] 1.1 Web research on game testing practice, Godot headless testing, flaky tests, mutation testing
- [x] 1.2 Baseline: 4 runs of the unchanged suite (767 checks, 0 failures, about 8 s each)
- [x] 1.3 Static review of every section (checks, weak assertions, end markers, timers)
- [x] 1.4 Mutation run, 86 mutants in 7 rounds; survivors read one by one
- [x] 1.5 Close the gaps (`test_rule_limits`, `test_presentation_limits`, tighter checks)
- [x] 1.6 End markers for `test_map_centering`, `test_heartbeat`, `test_revive`, `test_icon_safe_zone`
- [x] 1.7 Watchdog in the runner and `tools/run_tests.sh`; both shown to stop a run that cannot load
- [x] 1.8 `tools/mutation_check.py` and `tools/mutants.json`; full run: every mutant killed except the 7 equivalent ones
- [x] 1.9 Suite repeated after the changes (801 checks, 0 failures)
- [x] 1.10 Docs: `docs/development.md`, `design/test-audit.md`
- [ ] 1.11 Designer reads `design/test-audit.md` and decides on the items in "Not done" (split the runner file, frame steps instead of timers)
