## 1. Art

- [x] 1.1 Add the `charge` animation and a recoil attack to the T lymphocyte in `tools/tower_art.py`, make the generator write any `charge` sheet, regenerate, and verify that only the T lymphocyte files changed

## 2. Behaviour

- [x] 2.1 Add `beam_width` to the tower data (14 for the T lymphocyte) and validate the data
- [x] 2.2 Draw the thick beam and the explosion (`TowerBeam`) and keep the thin line for the other towers, and verify with a test that the T lymphocyte fires a beam
- [x] 2.3 Play the charge animation stretched to the interval, and verify with a test of the speed scale
- [x] 2.4 Run all tests (474 checks, 0 failures)

## 3. Check

- [x] 3.1 Verify with `tools/tlymphocyte_screenshots` the cycle: beam, explosion, charge, second shot at 2 s
- [x] 3.2 Verify on the emulator
