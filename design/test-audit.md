# Test suite audit

Question: do the tests work properly, one by one? A passing suite only proves that the tests agree with the code. This audit asks whether they would **notice** a bug.

Date: 2026-11-01. Code state: Godot 4.7.2, suite of 767 checks before, 801 after.

## 1. What good game testing looks like (research)

Sources are practitioner writing, not research papers; the claims below are the ones that agree across them. Where a source was thin, it says so.

| Practice | Source | This project |
|---|---|---|
| Deterministic simulation: fixed timestep, seeded randomness, so the same input gives the same result | [Automated game testing that delivers](https://www.ixiegaming.com/blog/automated-game-testing-that-delivers-bots-toolchains-and-ci-cd/), [AllStars IT](https://www.allstarsit.com/blog/automated-testing-in-game-development-from-unit-tests-to-playtests) | Yes. `Level.step(delta)` is the whole simulation; 200 bot games replay byte for byte (`design/performance.md`) |
| Scripted bots for regression, wider exploration for coverage | same | Yes. `autoplay_bot`, `playtest` with 10 strategies, `test_campaign_simulation` |
| Unit tests alone are not enough; bots that play find what unit tests miss | [Keywords Studios on Game Developer](https://www.gamedeveloper.com/article-library/be-smart-about-automation-the-future-is-ai-driven-game-testing-with-keywords-studios) | Both exist |
| A flaky test is ignored by everyone: "if a test fails 10 % of the time, developers ignore it 100 %" | [Ixie Gaming](https://www.ixiegaming.com/ai-game-testing-that-teams-actually-trust-how-to-design-signal-not-flake/) | Suite stable over every repeated run (section 3) |
| Flaky tests go with test smells: sleepy tests (wall-clock waits), lazy tests, assertion roulette | [study of 19,532 JUnit tests](https://www.iris.unisa.it/handle/11386/4727927), [test smells](https://does.qa/blog/i-can-smell-your-tests-from-here) | A few `create_timer` waits remain (section 5) |
| Assertions must be specific: "is defined" proves little | [test quality analysis](https://tessl.io/registry/skills/github/secondsky/claude-skills/test-quality-analysis) | Mostly; some weak ones found and fixed |
| Test behaviour, not implementation | same | Mostly; the tests read public state and signals |
| Headless run, a runner that exits non-zero on failure, frame steps instead of wall-clock sleeps | [Godot testing patterns](https://claudeskills.info/skills/thedivergentai/gd-agentic-skills/godot-testing-patterns/), [GUT and gdUnit4 CI notes](https://sharedcontext.ai/skills/external/jame581/godot-testing) | Yes, exit code 1 on failure; wall-clock waits in 5 places |
| Headless balance runs with win rates as a regression signal | [godot-autosim](https://godotengine.org/asset-library/asset/5002), [Pan's Trial wiki](https://github.com/BlakeEvans28/Pans_Trial_3/wiki/Testing-and-Balance) | Yes, `playtest` and `design/balance.md` |
| Mutation score measures test strength better than coverage: deleting an assertion leaves coverage unchanged but makes the suite useless | [Fuzzing Book](https://www.fuzzingbook.org/beta/MutationAnalysis.html), [arXiv 2102.02978](https://arxiv.org/pdf/2102.02978) | Used here (section 4) |
| The test pyramid: many small tests, fewer slow ones | [Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) | Rules in fast checks (8 s total); UI and campaign are the slow end |

Limits of the research: the Godot sources are skills and community pages, not official documentation (Godot has none for testing); the GUT and gdUnit4 command lines differ between sources and were not needed (this project has its own runner). Mutation testing results gave definitions and caveats but no thresholds, so no target score is claimed from outside.

## 2. How the suite was checked

1. Four runs of the unchanged suite (stability).
2. A read of all 31 sections: checks per section, existence-only assertions, assertions with `or`, labels that promise more than the check does, timers, sections that do not report their end.
3. **Mutation run:** small deliberate bugs put in the game code, one at a time (`<` became `<=`, a rule removed, a number changed, two values swapped). The whole suite runs for each. A mutant is *killed* if a check fails or the run crashes, and *survived* if all checks still pass. Every survivor was read and sorted into "equivalent" (the game behaves the same, no test can catch it) or "gap".
4. The gaps were closed, the survivors rerun, and then the whole list again.

Mutation testing here is a sample: 86 mutants in the rules that decide a game (damage, money, waves, win and loss, slots, difficulty, language, volume), not every line. The score describes that sample.

## 3. Result

| | Before | After |
|---|---|---|
| Checks | 767 | 801 |
| Mutants killed (of 86) | 53 (62 %) | 79 (92 %) |
| Mutants that survived | 33: 26 gaps, 7 equivalent | 7, all equivalent |
| Real gaps | 26 | 0 |
| Sections that report their end | 27 of 31 | 33 of 33 |
| A test file that does not load | hangs forever (found at 100 % CPU after 6 h) | fails in at most 240 s |
| A section that waits forever | hangs forever | fails after 180 s |
| Runs of the suite, same checks, 0 failures | 4 of 4 | 4 of 4 |
| Run time | 7.8 s | 8 s |

### The bugs the tests did not notice (26 gaps, now closed)

| Bug that passed | Why it passed | New check |
|---|---|---|
| Spending the whole balance refused (`<` became `<=`) | No test spent the exact amount | the whole balance can be spent; nothing from an empty balance |
| A wave started one tick late | No test ticked to the exact start time | a wave starts exactly at its start time |
| The difficulty time scale ignored | No test used a scale other than 1 | scale 2 delays the first wave, then starts it at twice its time |
| A leak always costs 1 health | The tests only leaked light enemies | an HIV leak costs its body damage (10) |
| Victory with enemies still alive | No test looked at the state with the field not clear | not won while enemies live; won after the last dies |
| Build on slot 99 or -1 | Slot numbers outside the map were never tried | refused, and the balance does not change |
| Build, sell, advance or call a wave after the game ended | Nothing tested a finished game | all refused; the clock stops |
| Move a tower to a slot that does not exist | Same | refused; the tower stays |
| Enemy of an unknown type accepted by the validator | The validator test only broke health and cost | `hpv: type` is reported |
| First leak time overwritten by the next leak | One leak per test | the first stays; both count |
| Kills counted twice in a wave | The per-wave count was never read | two kills count 2 |
| Stats counted the overkill (damage past the last health) | The only check accepted 14 or 20 with `or` | exact: 5 health left means 5 counted |
| A split copy carries all the body damage instead of its share | Only health and reward of copies were checked | half each |
| Zoom-out limit removed | The limit was never read | `zoom_min` fits the whole map between the bars |
| A narrow map not centred sideways | Only the height was tested | centred, no room to scroll |
| HUD shows `20/13` instead of `13/20` | The test used full health, where both read `20/20` | health 13 shows `13/20` |
| Call button visible after the level ends | Never read in a lost level | hidden |
| Language change not applied to the HUD | Not tested | the wave label changes with the locale |
| Unsupported language accepted; unknown phone locale kept | Not tested | refused; falls back to English; `pt_PT` becomes `pt_BR` |
| Music volume above 1 or below 0; effects not muted; zero volume not silent | Only the normal range was tried | clamped; mute and zero both give -80 dB |

### The 7 survivors that are not gaps

| Mutant | Why no test can catch it |
|---|---|
| `damage-min-zero` | No damage factor is negative, so the floor at 0 never acts (defensive code) |
| `eco-add-zero` | Adding 0 only changes whether a signal fires |
| `enemy-resist-factor` | The data value (0.5) equals the code fallback |
| `enemy-minion-count` | The data value (2) equals the code fallback |
| `level-victory-health` | A lost level already has state `lost`, so the health test is redundant |
| `audio-empty-path` | An empty path ends in the same `false`, only a warning is added |
| `hud-language-reset` | The amino acid text does not depend on the language |

Two of them point at a choice, not a defect: the code fallbacks for `factor` and `count` repeat the number in the data. If the data changes, the fallback will be wrong and no test will say so. Removing the fallback would be a code change and was not made.

## 4. Section by section

Mutants: killed after / total, `(n eq)` is equivalent survivors counted out. "Static" means no mutant was made; the verdict comes from reading the section.

| # | Section | Checks* | Evidence | Verdict |
|---|---|---|---|---|
| 1 | `test_enemy_roster` | 6 | Static | **Good**, a snapshot of the generated data (13 enemies, 5/5/3). One label says "ids are unique" and checks the file count; dictionary keys cannot repeat, so it is true but not by that check |
| 2 | `test_tower_roster` | 10 | Static | **Good**; also checks the HUD damage texts |
| 3 | `test_level_data` | 11 | Static | **Good**; one check per path point and per slot |
| 4 | `test_validator_catches_problems` | 3 | 2/2 | **Fixed**: the unknown-type case was missing |
| 5 | `test_damage_calculator` | 13 | 5/6 (1 eq) | **Good**, exact numbers per damage type, armour, mark |
| 6 | `test_status_effects` | 21 | 8/8 | **Strong**, the best section: stacking, boss halving, expiry, damage over time, immunity |
| 7 | `test_wave_scheduler` | 12 | 5/5 | **Fixed**: exact start time and time scale added |
| 8 | `test_economy` | 7 | 4/5 (1 eq) | **Fixed**: exact balance added |
| 9 | `test_level_simulation` | 66 | 17/18 (1 eq) | **Fixed**: finished game, slots, victory, leak damage added |
| 10 | `test_scrolling` | 13 | 2/2 | **Fixed**: zoom-out limit added |
| 11 | `test_speed_and_pause` | 5 | 2/2 | **Good** |
| 12 | `test_map_centering` | 2→3 | 1/1 | **Fixed**: sideways case and end marker added |
| 13 | `test_heartbeat` | 3 | Static | **Fixed**: end marker added. The checks are ranges of a pure function; fine |
| 14 | `test_revive` | 9 | 2/2 | **Good**; end marker added |
| 15 | `test_hud` | 48 | 4/5 (1 eq) | **Fixed** with `test_presentation_limits`. Keeps four real-time waits |
| 16 | `test_presentation_limits` (new) | 14 | closes 8 survivors | New |
| 17 | `test_audio` | 27 | 4/5 (1 eq) | **Fixed**: volume limits and mute added |
| 18 | `test_difficulty` | 19 | 1/1 | **Good** |
| 19 | `test_stats` | 5 | 4/4 | **Fixed**: the `or` check made exact; first leak and kills per wave added |
| 20 | `test_rule_limits` (new) | 18 | closes 17 survivors | New |
| 21 | `test_performance_helpers` | 13 | 1/1 | **Good** (written in the performance review) |
| 22 | `test_campaign_data` | 15 | Static | **Good**, but a snapshot: any balance change to level data needs the numbers edited here |
| 23 | `test_enemy_traits` | 28 | 6/8 (2 eq) | **Good** after the split check |
| 24 | `test_new_towers` | 38 | 3/3 | **Good**; one check, "selling a Bone Marrow removes its neutrophils", passes when the list is empty **or** every unit is queued for deletion, which is loose |
| 25 | `test_session` | 10 | 5/5 | **Good** |
| 26 | `test_localization` | 7 | 2/2 | **Fixed**: language fallback and phone locale mapping added (needed `match_locale`) |
| 27 | `test_changelog_menu` | 5 | Static | **Good** |
| 28 | `test_changelog` | 6 | 1/1 | **Good** |
| 29 | `test_icon_safe_zone` | 2 | Static | **Good**: scans every pixel of the icon. End marker added |
| 30 | `test_splash` | 6 | Static | **Acceptable**: checks that the nodes and texts exist and that it moves on; one real-time wait of about 1 s |
| 31 | `test_intro` | 9 | Static | **Acceptable**: sound length, sprites exist, skip works. It cannot judge how the story looks |
| 32 | `test_menu_and_results` | 64 | Static | **Acceptable**: finds nodes by name and reads texts. Presence, not layout |
| 33 | `test_campaign_simulation` | 2 | Static | **Strong as a gate** (the bot must win every level) but it only reports one number per level; if it fails, it does not say which wave |

\* Counts are the `check(` lines of the section; loops make the real number of checks larger (801 in all).

## 5. What is still weak

- **Visual sections** (splash, intro, menu layout, art): the tests check that things exist, have the right size and that the flow works. They cannot say it looks right. The designer's check on the phone remains the control (task 1.10 of `engine-performance-review` is still open for the same reason).
- **Snapshots of generated data** (`test_enemy_roster`, `test_level_data`, `test_campaign_data`, and exact numbers such as "copy health 65" in `test_enemy_traits`): any balance change breaks them. That is intended (they force a second look at a change), but it means a balance edit always touches the tests.
- **Real-time waits** in `test_hud` (0.3, 1.0, 1.2, 0.4 s) and `test_splash` (about 1 s): about 4 s of the 8 s run. They did not fail in any run, but they depend on timers instead of frame steps; on a slow machine they are the first to flake.
- **One 2100-line file**: easy to run, harder to read. Splitting it by section is sensible and was left out so it does not mix with the new checks in one commit.
- **The mutants are a sample**: 86 hand-chosen bugs. A tool that generates mutants would remove the sampling; none exists for GDScript.
- **Nothing tests on a phone**: the emulator is a manual step.

## 6. Tools

```
tools/run_tests.sh                                  # the suite, with a time limit (TEST_TIMEOUT=240 s)
python3 -I tools/mutation_check.py                  # 86 mutants, about 13 min; exits 1 if a mutant that is not listed as equivalent survives
python3 -I tools/mutation_check.py --list           # the mutants and their reasons
python3 -I tools/mutation_check.py --only damage-armor,eco-spend-boundary
```

When game code changes and a mutant pattern no longer matches, the tool prints `BAD-PATTERN`: update `tools/mutants.json`.
