## Method

1. **Research.** Web search on automated game testing, Godot headless testing, flaky tests and test smells, mutation testing (sources in `design/test-audit.md`). What applies here: deterministic fixed-step simulation (the game already has it), bots for regression, a runner that exits non-zero, no waiting on wall-clock time, specific assertions, and a measure of test strength that is not line coverage.
2. **Stability.** The suite ran 4 times on the unchanged code: same 767 checks, 0 failures, about 8 s.
3. **Static review of the 31 sections.** Checks per section, assertions that only test existence or use `or`, sections without the end marker, timers, labels that promise more than the check does.
4. **Mutation run.** For each section's subject code, small deliberate bugs (a boundary `<` to `<=`, a rule removed, a number changed, an order swapped). The whole suite runs for each mutant. A mutant is killed when a check fails or the run crashes. Survivors were read one by one: equivalent (same behaviour) or a gap.
5. **Close the gaps**, rerun the survivors until each real gap is killed, run the whole list again.

## Decisions

- **Mutation score, not line coverage.** GDScript has no coverage tool here, and coverage would count a line as tested even when no check looks at its result. Mutation testing measures exactly that.
- **Hand-written mutants, not generated ones.** There is no mutation tool for GDScript. 86 mutants chosen from the rules that decide a game (damage, money, waves, win and loss, slots, difficulty, language, volume) are a sample, not the whole code; the score is reported for that sample.
- **Equivalent mutants are listed, not hidden.** 7 survive for a stated reason (a fallback equal to the data value, a redundant condition, a floor that never acts). `tools/mutation_check.py` exits non-zero only for survivors without a reason.
- **New checks go in two new sections** (`test_rule_limits`, `test_presentation_limits`) named after what they cover: the limits of rules, which tests written for the normal case had skipped. The checks use values that differ from their neighbours (13/20, not 20/20).
- **The watchdog is two layers.** Inside the runner, a timer fails a run whose section waits forever. Outside, `tools/run_tests.sh` uses `timeout`, because a parse error stops the script from loading and no code inside it can run.
- **`match_locale` is a small change to game code for testability.** `from_os` read `OS.get_locale()` itself; the mapping is now a pure function.

## Not done

- Splitting the 2100-line `tests/test_runner.gd` into one file per section: useful, but a move of a file that every change touches; it should not share a commit with the new checks.
- Replacing the few `create_timer` waits in `test_hud` and `test_splash` (about 3 s of real time) with frame steps. They did not fail in any run, but they are the kind of wait that fails on a slow machine.
- Mutating the screens (splash, intro, menu layout) and the art: their tests check that things exist and have the right size, not how they look. The designer's check on the phone stays the control for that.
- Generated mutants. A GDScript mutation tool would remove the sampling.
