## 1. Level and data

- [x] 1.1 Create the `LevelData` and `WaveData` resources (path points, slot positions, starting resources, waves with start time, enemy entries and spawn interval), and verify they show up in the editor
- [x] 1.2 Write the level 1 data file with the path and the 6 slots from `design/fase-1-nariz-garganta.html`, the starting resources and the 3 waves from the spec, and verify with a headless test that it has 6 slots, 150 amino acids, body health 20 and 3 waves with starts at 5, 50 and 150 s
- [x] 1.3 Build the level scene (low-resolution `SubViewport` shown at 2× with Nearest filtering, the path, the entrance, the exit and the slots), and verify by running it that the map is shown in portrait and the pixels stay sharp
- [x] 1.4 Make spawned enemies follow the path and deal their damage to the body at the exit, and verify with a headless test that an enemy reaches the exit in the expected time and lowers the body health by its damage

- [x] 1.5 Make the map larger than the screen with a camera that scrolls between the top of the map under the top bar and the bottom of the map above the bottom bar, and verify with tests that the view starts at the entrance, stops at both edges, and converts taps correctly when scrolled

## 2. Wave system

- [x] 2.1 Create the `WaveScheduler` with the level clock and wave states, and verify with a simulated clock that wave 1 starts at 5 s, spawns its enemies 1.2 s apart and wave 2 starts at 50 s
- [x] 2.2 Add the call-next-wave action, and verify with a test that calling at 10 s starts wave 2 immediately, does not start it again at 50 s, and leaves wave 3 at 150 s
- [x] 2.3 Add the victory and defeat conditions, and verify with tests that the last enemy of the last wave ends the level as a victory, and that body health reaching zero ends it as a defeat

## 3. Speed and pause

- [x] 3.1 Add the 1× and 2× speed toggle through `Engine.time_scale`, resetting to 1× at level start, and verify that at 2× wave 2 starts after 25 s of real time and that the speed is back to 1× in the next level
- [x] 3.2 Add pause through `get_tree().paused` with the HUD still working, and verify that the clock, enemies and towers stop while paused and resume from the same state

## 4. HUD

- [x] 4.1 Build the top bar (level name, body health, amino acids, wave progress, pause, speed) inside the safe area with no ATP element, and verify on a window with a cutout margin that nothing is covered and the values update when they change (values and layout verified in screenshots; the safe-area margin only applies on Android and is not verified without a device with a camera cutout) (verified by the designer on 2026-10-31)
- [x] 4.2 Build the slot build menu with costs, unavailable towers for unaffordable ones, and closing by tapping outside, and verify with tests for a successful build, an unaffordable tap (balance unchanged, feedback shown) and a cancel
- [x] 4.3 Add the tower card (name, damage per second with its type, ability, and a sell button below with the refund shown), and verify that the card shows the right texts, that the sell button is below the ability, and that selling a 50 amino acid tower with a 0.6 refund fraction adds 30
- [x] 4.4 Add the next-wave countdown, the enemy preview icons with virus or bacterium marks, and the call button, and verify that the countdown matches the scheduler and that pressing the button starts the wave
- [x] 4.5 Add the enemy info card (name, type, health, role, weaknesses, immunities) and verify that the card of `streptococcus-pyogenes` lists antiviral damage as an immunity
- [x] 4.6 Add the pause overlay and the victory and defeat overlays with restart, and verify that each appears in the right situation and that restart reloads the level
- [x] 4.7 Verify that every tappable HUD control has a tap area of at least 48 dp by 48 dp, with a script that measures them at the target resolution

- [x] 4.8 Add drag-to-scroll (tap versus drag threshold, mouse wheel on desktop, menus close on scroll) and the scroll indicator with enemy marks, and verify with tests that a 100 px drag scrolls 50 map units, a small movement is still a tap, and scrolling closes a menu

## 5. Full run

- [x] 5.1 Play level 1 from start to victory and to defeat in a portrait window, and verify that building, selling, calling a wave, 2× speed and pause all work in the same run (played by the autoplay bot and by the tests, not by a person)
- [x] 5.2 Run `openspec validate add-level-1-prototype` and verify that the change is valid

## 6. Out of this change (later changes)

Upgrades, the other seven towers, levels 2 to 8, sound, Android export and device tuning, HUD art, and final balance are intentionally not part of these tasks.
