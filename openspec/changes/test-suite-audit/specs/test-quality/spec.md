## ADDED Requirements

### Requirement: Tests notice broken rules
The suite SHALL fail when a rule that decides a game is broken, including at its limits.

#### Scenario: Mutation run
- **WHEN** `python3 -I tools/mutation_check.py` puts each listed bug in the game code and runs the suite
- **THEN** every mutant is killed except those listed in `tools/mutants.json` with a reason (equivalent behaviour), and the tool exits 0

#### Scenario: Exact limits
- **WHEN** the whole balance is spent, a wave reaches its exact start time, or a leak happens
- **THEN** the money, the wave and the body health are checked at those exact values

### Requirement: A run that cannot finish fails
The suite SHALL end with a failure, not hang, when a section waits forever or the test script does not load.

#### Scenario: Parse error
- **WHEN** `tests/test_runner.gd` has a parse error and is run with `tools/run_tests.sh`
- **THEN** the run stops at the time limit with a `FAIL` message and a non-zero exit code

#### Scenario: Section that never ends
- **WHEN** a section waits for something that never happens
- **THEN** the watchdog prints `FAIL` after `WATCHDOG_SECONDS` and exits with 1

### Requirement: Every section reports its end
Every `test_*` section SHALL call `done("<name>")` as its last line and be in the list the runner checks.

#### Scenario: Script error inside a section
- **WHEN** a script error stops a section before its last line
- **THEN** the runner prints `FAIL: <name> stopped before its end` and the run fails

### Requirement: Stable runs
The suite SHALL give the same checks and result on every run.

#### Scenario: Repeated runs
- **WHEN** the suite runs several times on the same code
- **THEN** the number of checks and the failures are the same each time
