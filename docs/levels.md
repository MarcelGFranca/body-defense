# Levels

All levels use the same rules; they differ in map, towers offered, starting amino acids, waves and boss. Body health is 20 on Medium.

| # | Name | Slots | Towers offered | Start amino | Waves | Boss |
|---|---|---|---|---|---|---|
| 1 | Throat | 6 | macrophage, mucus cell, interferon | 150 | 3 | |
| 2 | Trachea | 7 | + neutrophil, lysozyme | 250 | 4 | |
| 3 | Lungs | 8 | + platelet, hypothalamus | 270 | 4 | Mycobacterium tuberculosis |
| 4 | Esophagus | 8 | + T lymphocyte | 290 | 4 | |
| 5 | Stomach | 8 | + B lymphocyte | 300 | 5 | |
| 6 | Intestines | 9 | all 10 | 320 | 5 | |
| 7 | Bloodstream | 9 | all 10 | 340 | 5 | Neisseria meningitidis |
| 8 | Liver | 10 | all 10 | 360 | 5 | |
| 9 | Spleen | 10 | all 10 | 380 | 6 | |
| 10 | Lymph Nodes | 10 | all 10 | 400 | 5 | HIV (final) |

Some levels disable one enemy trait early (level 1 has no chain). Level 1 is the tutorial: gentle waves, three towers, no bosses.

## Measured win rate (1000 bot games per difficulty, %)

| Level | Easy | Medium | Hard |
|---|---|---|---|
| 1 | 94 | 91 | 72 |
| 2 | 92 | 75 | 47 |
| 3 | 91 | 76 | 59 |
| 4 | 94 | 77 | 46 |
| 5 | 95 | 68 | 55 |
| 6 | 84 | 55 | 32 |
| 7 | 87 | 56 | 27 |
| 8 | 78 | 59 | 39 |
| 9 | 73 | 48 | 23 |
| 10 | 79 | 46 | 16 |

Margin of error is about 10 points per cell. Wave lists per level are in `design/balance.md`.

## Adding a level

1. Add a row to `_levels()` in `tools/generate_data.gd` (path, slots, towers, amino, waves, scale, boss, description).
2. Regenerate data, run `validate_data.gd` and the tests.
3. Run `tools/tune_waves.py` for the target difficulty, then 100+ playtest games per difficulty.
4. Add a music track in `tools/generate_audio.py` and the level name to the menu.
