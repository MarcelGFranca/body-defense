## 1. Tower data

- [x] 1.1 Create the `TowerData` script (`Resource`) with id, display name, role, damage type, cost, mobility, base numbers and an `in_prototype` flag, and verify that the resource shows up in the editor when creating a new `Resource`
- [x] 1.2 Write the single tower table (10 towers with the provisional values from the spec) and verify that it has 10 rows with unique ids
- [x] 1.3 Create the batch script that generates `data/towers/<id>.tres` from the table, and verify that 10 files are generated with the identifiers from the spec

- [x] 1.4 Create the idle and attack animations of the Macrophage, Mucus Cell and Interferon (8 frames each) and play the attack animation when each tower acts, and verify with tests that each tower has both animations and plays the attack animation when it hits, pulses or slows
- [x] 1.5 Make the Interferon pulse a mist across its area, and verify in a window that the mist keeps pulsing and the viruses in it react

## 2. Damage rules

- [x] 2.1 Create the `DamageTable` resource with the multiplier table and the per-enemy overrides, and verify with a headless test that chemical damage against a bacterium has a factor of 1.5 and antiviral damage against a bacterium has a factor of 0
- [x] 2.2 Add the `armor_percent` field to `EnemyData`, set `hpv` to 30 and `mycobacterium-tuberculosis` to 40, and verify with a test that a 12 damage physical attack on `hpv` deals 8
- [x] 2.3 Create `DamageCalculator.resolve(attack, target)` with the rule order from the design, and verify with tests for weak point (6 to 9), resistance (6 to 3), immunity (0), armor, immunological ignoring armor, and the spore override (4 to 2)

## 3. Status effects

- [x] 3.1 Create the enemy status component with slows (strongest wins, 1.5 s linger, boss at half, `slow-immune` unaffected), and verify with tests for 40% on a normal enemy, 20% on `mycobacterium-tuberculosis`, no stacking, and no effect on `helicobacter-pylori`
- [x] 3.2 Add roots with a per-tower cooldown per enemy, half duration for `boss`, and verify with tests that a Platelet roots a normal enemy for 1.2 s, a `mycobacterium-tuberculosis` for 0.6 s, and cannot root again within 3 s
- [x] 3.3 Add damage over time with one-second ticks that refresh and do not stack, and verify with tests that fever deals 3 per tick for 4 s, restarts on reapplication, and deals 1 per tick to a spore

- [x] 3.4 Make the Interferon slow viruses by 25% but not bacteria, and verify with tests that a virus is slowed 25%, a bacterium is not, and that with a Mucus Cell the strongest slow (40%) counts

- [x] 3.5 Make the Mucus Cell throw a glob at the first enemy in range that leaves a 6 s puddle slowing enemies by 40%, and verify with tests that the target is the first of the queue, that an enemy arriving later is slowed, that nothing is thrown with no enemy in range, and that the puddle disappears after 6 s

## 4. Validation

- [x] 4.1 Create the validation script (`godot --headless --script`) that checks 10 unique towers, positive costs, the three prototype towers flagged, and warns when a base value would round to 0 against any multiplier, and verify that it passes with all 10 files
- [x] 4.2 Temporarily remove the cost from one tower file and verify that validation fails naming the tower and the field, then restore the file (done in a test on a modified copy of the data, not by editing the file)
- [x] 4.3 Run `openspec validate add-tower-roster-and-damage` and verify that the change is valid

## 5. Out of this change (later changes)

Tower behavior of the other seven towers (summoning, lymphocyte movement), upgrade trees, art and animations of the other seven towers, and levels are intentionally not part of these tasks.
