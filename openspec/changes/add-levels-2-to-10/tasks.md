## 1. Data and maps

- [x] 1.1 Extend `LevelData`, `EnemyData` and `TowerData` with the new fields (number, body part, description, boss, disabled traits, colors, decor; trait params; unit damage, mark targets)
- [x] 1.2 Write the ten levels in `tools/generate_data.gd` with path builders and automatic slots, and check with a map preview that every path and slot set looks right
- [x] 1.3 Draw each map in the colors of its organ, and verify with screenshots
- [x] 1.4 Extend the data validator with the level and campaign rules, and verify that it catches a boss in the wrong level and a slot on the path

## 2. Rules

- [x] 2.1 Implement the nine enemy traits (and keep level 1 with the chain off), with tests for each
- [x] 2.2 Implement the B Lymphocyte marks, the Bone Marrow neutrophils and moving a lymphocyte, with tests
- [x] 2.3 Balance every level with the probe (empty field loses, bot wins), and add a test that plays all ten

## 3. Art and sound

- [x] 3.1 Draw and animate the ten missing enemies and the strep segment
- [x] 3.2 Draw and animate the seven missing towers
- [x] 3.3 Write ten music tracks of 50 s, one for each level

## 4. Flow

- [x] 4.1 Add the `Session` autoload with saved progress
- [x] 4.2 Add the level menu, and the level page
- [x] 4.3 Add next level, retry and menu buttons, the move button and the two-column build menu
