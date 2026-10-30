# Playtest report: easy_1000 (1000 games, difficulty easy)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 100 | 94 (+-5) | 25.4/30 | 231 | 209 | 40 |
| 2 | Trachea | 100 | 92 (+-5) | 25.3/30 | 206 | 147 | 217 |
| 3 | Lungs | 100 | 91 (+-6) | 25.8/30 | 323 | 183 | 108 |
| 4 | Esophagus | 100 | 94 (+-5) | 26.7/30 | 202 | 165 | 66 |
| 5 | Stomach | 100 | 95 (+-4) | 26.8/30 | 240 | 117 | 67 |
| 6 | Intestines | 100 | 84 (+-7) | 22.9/30 | 336 | 229 | 137 |
| 7 | Bloodstream | 100 | 87 (+-7) | 23.3/30 | 305 | 137 | 122 |
| 8 | Liver | 100 | 78 (+-8) | 22.4/30 | 330 | 177 | 572 |
| 9 | Spleen | 100 | 73 (+-9) | 20.8/30 | 388 | 221 | 1215 |
| 10 | Lymph Nodes | 100 | 79 (+-8) | 20.8/30 | 417 | 160 | 593 |

## Win rate by level and strategy (%)

| level | balanced_mix | cheap | damage_only | few_strong | random_a | random_b | smart | smart_calls | support_heavy | worst_slots |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 40 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 2 | 100 | 20 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 3 | 100 | 10 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 4 | 100 | 40 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 5 | 100 | 50 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 6 | 100 | 0 | 100 | 100 | 90 | 90 | 100 | 100 | 60 | 100 |
| 7 | 100 | 0 | 100 | 100 | 100 | 100 | 100 | 100 | 70 | 100 |
| 8 | 100 | 0 | 100 | 90 | 90 | 100 | 100 | 100 | 0 | 100 |
| 9 | 100 | 0 | 100 | 90 | 90 | 60 | 100 | 90 | 10 | 90 |
| 10 | 100 | 0 | 100 | 100 | 100 | 90 | 100 | 100 | 10 | 90 |

## How the games end, by level

| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |
|---|---|---|---|---|---|
| 1 | 94 | 6 | wave 3 (6 games) | 254 | 24 / 28 / 30 |
| 2 | 92 | 8 | wave 4 (8 games) | 175 | 30 / 30 / 30 |
| 3 | 91 | 9 | wave 4 (9 games) | 247 | 30 / 30 / 30 |
| 4 | 94 | 6 | wave 4 (6 games) | 221 | 29 / 30 / 30 |
| 5 | 95 | 5 | wave 5 (5 games) | 230 | 30 / 30 / 30 |
| 6 | 84 | 16 | wave 5 (11 games) | 330 | 30 / 30 / 30 |
| 7 | 87 | 13 | wave 4 (11 games) | 271 | 26 / 30 / 30 |
| 8 | 78 | 22 | wave 5 (12 games) | 295 | 30 / 30 / 30 |
| 9 | 73 | 27 | wave 4 (13 games) | 230 | 30 / 30 / 30 |
| 10 | 79 | 21 | wave 3 (9 games) | 235 | 28 / 30 / 30 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| smart | 100 | 100 | 29.3 |
| damage_only | 100 | 100 | 29.9 |
| balanced_mix | 100 | 100 | 29.8 |
| smart_calls | 100 | 99 | 28.8 |
| worst_slots | 100 | 98 | 28.6 |
| few_strong | 100 | 98 | 26.4 |
| random_a | 100 | 97 | 25.7 |
| random_b | 100 | 94 | 24.8 |
| support_heavy | 100 | 65 | 13.8 |
| cheap | 100 | 16 | 3.3 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| lysozyme | 826 | 70 | 1082 | 11.95 | 20.4 |
| macrophage | 1373 | 50 | 987 | 11.60 | 28.6 |
| hypothalamus | 654 | 90 | 1163 | 10.55 | 22.6 |
| neutrophil | 662 | 45 | 606 | 9.88 | 15.2 |
| t-lymphocyte | 530 | 90 | 975 | 8.87 | 30.1 |
| interferon | 1086 | 70 | 814 | 8.19 | 26.3 |
| bone-marrow | 297 | 90 | 607 | 4.89 | 16.2 |
| b-lymphocyte | 457 | 70 | 383 | 4.27 | 6.8 |
| platelet | 551 | 55 | 0 | 0.00 | 0.0 |
| mucus-cell | 1552 | 40 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 34 | 0 | 66 | 0 | 0 |
| 2 | 0 | 0 | 0 | 26 | 28 | 33 | 13 | 0 |
| 3 | 0 | 0 | 20 | 18 | 19 | 29 | 14 | 0 |
| 4 | 0 | 0 | 18 | 25 | 13 | 20 | 5 | 18 |
| 5 | 3 | 0 | 16 | 9 | 10 | 20 | 4 | 37 |
| 6 | 1 | 7 | 16 | 7 | 20 | 24 | 8 | 17 |
| 7 | 5 | 5 | 14 | 21 | 13 | 17 | 11 | 15 |
| 8 | 5 | 3 | 19 | 15 | 19 | 17 | 10 | 12 |
| 9 | 6 | 4 | 17 | 17 | 18 | 22 | 6 | 11 |
| 10 | 4 | 5 | 21 | 15 | 22 | 15 | 7 | 11 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| neisseria-meningitidis | 169 | 148 | 21 | 12.4 |
| mycobacterium-tuberculosis | 93 | 83 | 10 | 10.8 |
| staphylococcus-aureus | 9275 | 8539 | 736 | 7.9 |
| e-coli | 5244 | 4902 | 342 | 6.5 |
| clostridioides-difficile | 9169 | 8574 | 595 | 6.5 |
| hiv | 79 | 74 | 5 | 6.3 |
| streptococcus-pyogenes | 11875 | 11378 | 497 | 4.2 |
| helicobacter-pylori | 5595 | 5406 | 189 | 3.4 |
| herpes-simplex | 8348 | 8067 | 281 | 3.4 |
| influenza | 8598 | 8311 | 287 | 3.3 |
| hpv | 10120 | 9883 | 237 | 2.3 |
| sars-cov-2 | 8469 | 8272 | 197 | 2.3 |
| rhinovirus | 21454 | 21057 | 397 | 1.9 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| staphylococcus-aureus | 3.91 | 0.25 |
| clostridioides-difficile | 2.98 | 0.23 |
| rhinovirus | 2.35 | 0.10 |
| e-coli | 2.17 | 0.06 |
| influenza | 2.08 | 0.01 |
| herpes-simplex | 1.58 | 0.08 |
| sars-cov-2 | 1.35 | 0.02 |
| hpv | 1.24 | 0.08 |
| streptococcus-pyogenes | 1.20 | 0.39 |
| helicobacter-pylori | 1.17 | 0.04 |
| neisseria-meningitidis | 0.02 | 0.02 |
| mycobacterium-tuberculosis | 0.02 | 0.01 |
| hiv | 0.00 | 0.01 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 0.5 | 31 |
| 1 | 2 | 0.9 | 33 |
| 1 | 3 | 1.8 | 56 |
| 2 | 1 | 0.5 | 22 |
| 2 | 2 | 0.9 | 27 |
| 2 | 3 | 1.2 | 37 |
| 2 | 4 | 1.7 | 50 |
| 3 | 1 | 0.3 | 58 |
| 3 | 2 | 0.7 | 47 |
| 3 | 3 | 1.3 | 65 |
| 3 | 4 | 0.3 | 109 |
| 4 | 1 | 0.1 | 17 |
| 4 | 2 | 0.3 | 29 |
| 4 | 3 | 1.1 | 38 |
| 4 | 4 | 1.1 | 37 |
| 5 | 1 | 0.1 | 13 |
| 5 | 2 | 0.2 | 18 |
| 5 | 3 | 0.6 | 29 |
| 5 | 4 | 0.7 | 33 |
| 5 | 5 | 0.3 | 31 |
| 6 | 1 | 0.3 | 42 |
| 6 | 2 | 0.7 | 56 |
| 6 | 3 | 0.9 | 62 |
| 6 | 4 | 0.9 | 69 |
| 6 | 5 | 1.6 | 68 |
| 7 | 1 | 0.4 | 25 |
| 7 | 2 | 0.5 | 30 |
| 7 | 3 | 1.3 | 36 |
| 7 | 4 | 1.4 | 37 |
| 7 | 5 | 0.2 | 42 |
| 8 | 1 | 0.7 | 48 |
| 8 | 2 | 1.2 | 65 |
| 8 | 3 | 1.4 | 61 |
| 8 | 4 | 0.7 | 61 |
| 8 | 5 | 0.5 | 66 |
| 9 | 1 | 1.1 | 57 |
| 9 | 2 | 1.6 | 68 |
| 9 | 3 | 1.4 | 66 |
| 9 | 4 | 0.5 | 71 |
| 9 | 5 | 0.5 | 78 |
| 9 | 6 | 0.4 | 86 |
| 10 | 1 | 1.9 | 54 |
| 10 | 2 | 1.4 | 55 |
| 10 | 3 | 0.7 | 57 |
| 10 | 4 | 0.6 | 64 |
| 10 | 5 | 0.6 | 69 |
| 10 | 6 | 0.1 | 99 |
