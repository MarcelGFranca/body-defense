## 1. Base Godot project

- [x] 1.1 Create `project.godot` at the root with portrait orientation (720×1280) and Nearest texture filtering, and verify that `godot --headless --quit` opens the project without errors
- [x] 1.2 Create the `data/enemies/` and `scripts/` structure and verify that the folders exist in the repository

## 2. Enemy data definition

- [x] 2.1 Create the `EnemyData` script (`Resource`) with id, display name, type, role, `trait_id`, trait description, health, speed, damage to the body and `amino_acid_reward`, and verify that the resource shows up in the editor when creating a new `Resource` (checked through the global class cache and the tests, without opening the editor)
- [x] 2.2 Write the single roster table (13 enemies with provisional starting values, as in the spec) and verify that it has 5 regular viruses, 5 regular bacteria and 3 bosses

## 3. File generation

- [x] 3.1 Create the batch script that generates `data/enemies/<id>.tres` from the table and verify that 13 files are generated with the identifiers from the spec
- [x] 3.2 Create two placeholder images (virus and bacterium) and link each enemy to the image of its type, verifying in the editor that all of them show an image

## 4. Economy core

- [x] 4.1 Create the `Economy` autoload with an `amino_acids` balance, `add(amount)` and `try_spend(amount)`, and verify with a headless test that a spend larger than the balance returns false and leaves the balance unchanged
- [x] 4.2 Load the starting amino acid amount and the refund fraction from a data resource, and verify that changing the value in the file changes the starting balance without code edits

## 5. Earning

- [x] 5.1 Add amino acids on enemy death using the enemy's `amino_acid_reward`, and verify with a headless test that defeating an enemy with a reward of 5 raises the balance by 5
- [x] 5.2 Verify that an enemy reaching the end of the path adds no amino acids

## 6. Spending

- [x] 6.1 Charge amino acids when a tower is built, refusing the build when the balance is too low, and verify both the success case and the refusal case with a test
- [x] 6.2 Refund the configured fraction when a tower is sold, and verify that selling a 100 amino acid tower with a 0.6 fraction adds 60

## 7. Presentation

- [x] 7.1 Create the pixel-art amino acid orb sprite (same style and palette family as the Rhinovirus) and verify it shows correctly in the editor with Nearest filtering
- [x] 7.2 Add the HUD amino acid counter and the orb fly-to-counter animation, and verify by running a level that the counter updates when an enemy dies

## 8. Validation

- [x] 8.1 Create the validation script (`godot --headless --script`) that checks the 5/5/3 count, unique identifiers, positive attributes and the boss strength rule (at least 5 times the average regular health and reward), and verify that it passes with all 13 files
- [x] 8.2 Temporarily remove the health attribute from one file and verify that validation fails naming the enemy and the attribute, then restore the file (done in a test on a modified copy of the data, not by editing the file)
- [x] 8.3 Run `openspec validate add-enemy-roster-and-economy` and verify that the change is valid

## 9. Deferred (not part of this change)

ATP is specified in `specs/economy/spec.md` but intentionally has no implementation tasks here. A future change will enable it.

- [x] 9.1 Verify that no ATP counter, value or field appears anywhere in the UI, saves or level data
