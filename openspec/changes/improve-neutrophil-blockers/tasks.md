## 1. Roaming and guard radius

- [x] 1.1 Add `unit_radius` and `unit_speed` to the tower data (Bone Marrow: 60 and 80) and validate the data
- [x] 1.2 Draw the neutrophil sprite, make the unit drift around its post, and verify with a test that it moves while waiting
- [x] 1.3 Make the unit walk to an enemy inside its radius and back to its post, and verify with tests that it goes, blocks, ignores bosses and returns
- [x] 1.4 Run all tests and verify with `tools/neutrophil_screenshots` that the unit meets the enemy

- [x] 1.6 Draw the neutrophil at half its size (scale 0.425) and shrink its health bar
- [x] 1.5 Add `unit_regen` (2 per second) to the Bone Marrow data and make the unit recover health up to its maximum, and verify with a test

- [x] 1.7 Make each neutrophil hold one enemy only: it reserves the first enemy that reaches it, every other enemy walks past without being stopped or hurt, a neutrophil does not go to meet an enemy that another one holds, and it frees itself when the enemy dies; verify with a test with two enemies side by side

## 2. Attack animation of the neutrophils

- [x] 2.1 Play the attack animation of the neutrophil sprite each time the unit hits, facing the enemy, and verify with a test that it plays
- [x] 2.2 Draw the unit above the enemies and stand it 12 units ahead of the enemy (was 8) so it is seen while it fights, and verify with `tools/neutrophil_screenshots`

## 3. Attack animation of the enemies against the neutrophils

- [x] 3.1 Make an enemy held by a neutrophil play its attack animation, facing it, until it is free, and verify with a test and with `tools/neutrophil_screenshots`

## 4. Respawn after a cooldown

- [x] 4.1 Set `summon_interval` to 15 s (cap stays 3), and verify with tests that three neutrophils appear in 50 s, that a dead one is not replaced before the next tick and that it is replaced at the tick
- [x] 4.2 The Bone Marrow clock was reset to the full 15 s every time it was at its cap, so a replacement waited a full 15 s after a death. The clock now runs without stopping (a tick every 15 s creates a neutrophil if there is room). This was not the cause of the bug the designer reported (see 4.3)
- [x] 4.3 Fix the real cause of "after a neutrophil dies the Bone Marrow stops creating": the list of neutrophils was filtered with a lambda whose parameter was typed `BlockerUnit`, and a neutrophil that died has been freed, which GDScript refuses (`Cannot convert argument 1 from Object to Object`); the error aborted `_step_summon_units` at every frame, so nothing was ever created again. The headless simulations never showed it because they never ran a frame between a death and the next step, so freed neutrophils were never really freed. The list is now untyped. The same pattern was removed from the platelet (`_holds`, `RootTendrils`). A regression test now waits two frames after a death, as the game does
