## 1. Roaming and guard radius

- [x] 1.1 Add `unit_radius` and `unit_speed` to the tower data (Bone Marrow: 60 and 80) and validate the data
- [x] 1.2 Draw the neutrophil sprite, make the unit drift around its post, and verify with a test that it moves while waiting
- [x] 1.3 Make the unit walk to an enemy inside its radius and back to its post, and verify with tests that it goes, blocks, ignores bosses and returns
- [x] 1.4 Run all tests and verify with `tools/neutrophil_screenshots` that the unit meets the enemy

- [x] 1.6 Draw the neutrophil at half its size (scale 0.425) and shrink its health bar
- [x] 1.5 Add `unit_regen` (2 per second) to the Bone Marrow data and make the unit recover health up to its maximum, and verify with a test

## 2. Attack animation of the neutrophils

- [x] 2.1 Play the attack animation of the neutrophil sprite each time the unit hits, facing the enemy, and verify with a test that it plays
- [x] 2.2 Draw the unit above the enemies and stand it 12 units ahead of the enemy (was 8) so it is seen while it fights, and verify with `tools/neutrophil_screenshots`

## 3. Attack animation of the enemies against the neutrophils

- [ ] 3.1 To do

## 4. Respawn after a cooldown

- [x] 4.1 Set `summon_interval` to 15 s (cap stays 3), and verify with tests that three neutrophils appear in 50 s, that a dead one is not replaced before 15 s and that it is replaced after
