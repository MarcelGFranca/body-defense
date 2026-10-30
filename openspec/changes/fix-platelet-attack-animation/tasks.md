## 1. Animation

- [x] 1.1 Play the attack animation when the platelet roots an enemy, and verify with a test that it does
- [x] 1.2 Draw tendrils that hold each rooted enemy while it is rooted and disappear after, and verify with a test that a hold exists while rooted and is gone afterwards
- [x] 1.3 Add `root_targets` (3) to the tower data, make the platelet hold at most 3 enemies, and verify with a test that five enemies in range give three holds
- [x] 1.4 Make the hold last 3 s, send the tendril to the furthest enemy and play the sound only when sending, and verify with tests (tendril still there at 2.5 s, gone after 3.5 s, no sound while holding, the furthest enemy is held)
- [x] 1.5 Run all tests (477 checks, 0 failures) and validate the data

## 2. Check

- [x] 2.1 Verify with `tools/platelet_screenshots` that three tendrils hold three enemies, fade and disappear
- [ ] 2.2 Playtest the effect of the cap of 3 and of the 3 s hold on win rates (not run; the designer asked for both directly)
