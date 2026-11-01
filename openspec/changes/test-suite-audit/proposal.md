## Why

The suite had 767 checks and all of them passed, but passing says nothing about whether the tests would notice a bug. A web search on game testing practice (determinism, fixed steps, bots for regression, flaky tests, mutation testing; sources in `design/test-audit.md`) and a mutation run on this suite gave a measured answer: of 86 deliberate bugs put in the rules, the HUD, the audio and the language code, the tests caught 53 (62 %). 33 bugs went unnoticed, 26 of them real gaps (the rest do not change behaviour).

## What Changes

- 34 new checks close the gaps: spending the exact balance, a wave starting at its exact time, the difficulty time scale, the body damage of a leak, victory only with a clear field, slots that do not exist, a finished game, the first leak time, kills per wave, an unknown enemy type, sideways map centring, the zoom-out limit, split copies and their body damage, overkill in the stats, the HUD health order, the call button after the end, a language change, audio volume limits and mute
- Two weak checks were made exact (the overkill check accepted two values with `or`; the sideways centring was never checked)
- Four sections (`test_map_centering`, `test_heartbeat`, `test_revive`, `test_icon_safe_zone`) now report that they ran to the end, like the others; a script error in them used to pass silently
- A watchdog (`WATCHDOG_SECONDS`) fails the run when a section waits forever, and `tools/run_tests.sh` limits the whole run in time. Before, a test file that did not load (a parse error) left Godot waiting forever: a run was found at 100 % CPU after 6 hours
- `Localization.match_locale` is split from `from_os` so the phone locale mapping can be tested
- New tool `tools/mutation_check.py` with its list `tools/mutants.json`: repeats the mutation run (86 mutants, about 13 minutes)

No game rule, number or look changes.

## Capabilities

### New Capabilities
- `test-quality`

## Impact

- tests/test_runner.gd, game/localization.gd (one function split), tools/run_tests.sh, tools/mutation_check.py, tools/mutants.json
- docs/development.md, design/test-audit.md
