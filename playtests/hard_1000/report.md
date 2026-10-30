# Playtest report: hard_1000 (1000 games, difficulty hard)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 100 | 72 (+-9) | 6.6/16 | 169 | 133 | 33 |
| 2 | Trachea | 100 | 47 (+-10) | 5.0/16 | 155 | 79 | 88 |
| 3 | Lungs | 100 | 59 (+-10) | 5.5/16 | 256 | 112 | 51 |
| 4 | Esophagus | 100 | 46 (+-10) | 5.3/16 | 158 | 94 | 43 |
| 5 | Stomach | 100 | 55 (+-10) | 4.8/16 | 178 | 94 | 38 |
| 6 | Intestines | 100 | 32 (+-9) | 2.6/16 | 232 | 130 | 48 |
| 7 | Bloodstream | 100 | 27 (+-9) | 1.4/16 | 179 | 69 | 47 |
| 8 | Liver | 100 | 39 (+-10) | 5.1/16 | 206 | 122 | 216 |
| 9 | Spleen | 100 | 23 (+-8) | 2.7/16 | 219 | 133 | 451 |
| 10 | Lymph Nodes | 100 | 16 (+-7) | 1.4/16 | 203 | 99 | 151 |

## Win rate by level and strategy (%)

| level | balanced_mix | cheap | damage_only | few_strong | random_a | random_b | smart | smart_calls | support_heavy | worst_slots |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 20 | 100 | 100 | 50 | 70 | 100 | 90 | 80 | 10 |
| 2 | 80 | 0 | 100 | 50 | 20 | 20 | 80 | 90 | 10 | 20 |
| 3 | 70 | 0 | 100 | 80 | 30 | 50 | 70 | 90 | 20 | 80 |
| 4 | 50 | 0 | 20 | 80 | 40 | 40 | 80 | 60 | 10 | 80 |
| 5 | 90 | 30 | 100 | 90 | 60 | 20 | 70 | 70 | 10 | 10 |
| 6 | 80 | 0 | 50 | 60 | 20 | 20 | 40 | 50 | 0 | 0 |
| 7 | 70 | 0 | 70 | 30 | 10 | 0 | 50 | 40 | 0 | 0 |
| 8 | 90 | 0 | 80 | 10 | 20 | 0 | 50 | 60 | 0 | 80 |
| 9 | 50 | 0 | 80 | 0 | 20 | 0 | 40 | 40 | 0 | 0 |
| 10 | 30 | 0 | 80 | 0 | 0 | 0 | 30 | 20 | 0 | 0 |

## How the games end, by level

| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |
|---|---|---|---|---|---|
| 1 | 72 | 28 | wave 3 (15 games) | 186 | 8 / 10 / 10 |
| 2 | 47 | 53 | wave 4 (41 games) | 156 | 7 / 11 / 15 |
| 3 | 59 | 41 | wave 4 (34 games) | 182 | 6 / 9 / 14 |
| 4 | 46 | 54 | wave 4 (54 games) | 165 | 7 / 14 / 16 |
| 5 | 55 | 45 | wave 4 (25 games) | 156 | 5 / 9 / 13 |
| 6 | 32 | 68 | wave 5 (30 games) | 181 | 6 / 8 / 11 |
| 7 | 27 | 73 | wave 3 (45 games) | 142 | 1 / 5 / 8 |
| 8 | 39 | 61 | wave 3 (31 games) | 137 | 12 / 14 / 16 |
| 9 | 23 | 77 | wave 3 (26 games) | 172 | 10 / 12 / 16 |
| 10 | 16 | 84 | wave 3 (25 games) | 144 | 6 / 9 / 13 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| damage_only | 100 | 78 | 8.6 |
| balanced_mix | 100 | 71 | 7.4 |
| smart | 100 | 61 | 6.2 |
| smart_calls | 100 | 61 | 5.8 |
| few_strong | 100 | 50 | 3.8 |
| worst_slots | 100 | 28 | 3.3 |
| random_a | 100 | 27 | 2.5 |
| random_b | 100 | 22 | 1.8 |
| support_heavy | 100 | 13 | 0.8 |
| cheap | 100 | 5 | 0.4 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| lysozyme | 723 | 70 | 1173 | 13.89 | 15.3 |
| hypothalamus | 562 | 90 | 1293 | 12.58 | 16.5 |
| macrophage | 1131 | 50 | 942 | 12.53 | 19.8 |
| interferon | 877 | 70 | 986 | 10.98 | 17.7 |
| t-lymphocyte | 411 | 90 | 1072 | 10.14 | 23.8 |
| neutrophil | 484 | 45 | 521 | 9.04 | 9.9 |
| bone-marrow | 202 | 90 | 361 | 3.57 | 6.8 |
| b-lymphocyte | 295 | 70 | 240 | 2.98 | 2.8 |
| platelet | 339 | 55 | 0 | 0.00 | 0.0 |
| mucus-cell | 1223 | 40 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 42 | 0 | 58 | 0 | 0 |
| 2 | 0 | 0 | 0 | 29 | 34 | 28 | 9 | 0 |
| 3 | 0 | 0 | 22 | 19 | 24 | 27 | 9 | 0 |
| 4 | 0 | 0 | 19 | 29 | 19 | 19 | 5 | 9 |
| 5 | 1 | 0 | 17 | 10 | 15 | 29 | 4 | 23 |
| 6 | 1 | 5 | 16 | 6 | 24 | 25 | 4 | 17 |
| 7 | 2 | 5 | 16 | 18 | 16 | 22 | 6 | 15 |
| 8 | 3 | 2 | 21 | 18 | 19 | 16 | 8 | 13 |
| 9 | 3 | 2 | 23 | 19 | 19 | 18 | 4 | 12 |
| 10 | 1 | 2 | 22 | 22 | 23 | 14 | 5 | 11 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| mycobacterium-tuberculosis | 70 | 45 | 25 | 35.7 |
| neisseria-meningitidis | 59 | 39 | 20 | 33.9 |
| hiv | 19 | 14 | 5 | 26.3 |
| staphylococcus-aureus | 5337 | 4006 | 1331 | 24.9 |
| clostridioides-difficile | 5417 | 4464 | 953 | 17.6 |
| e-coli | 4778 | 3939 | 839 | 17.6 |
| herpes-simplex | 5759 | 4822 | 937 | 16.3 |
| hpv | 5969 | 5338 | 631 | 10.6 |
| helicobacter-pylori | 3494 | 3159 | 335 | 9.6 |
| rhinovirus | 14412 | 13089 | 1323 | 9.2 |
| streptococcus-pyogenes | 8446 | 7672 | 774 | 9.2 |
| influenza | 6927 | 6417 | 510 | 7.4 |
| sars-cov-2 | 5759 | 5360 | 399 | 6.9 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| staphylococcus-aureus | 1.80 | 0.68 |
| rhinovirus | 1.70 | 0.79 |
| clostridioides-difficile | 1.36 | 0.38 |
| e-coli | 1.32 | 0.17 |
| herpes-simplex | 1.29 | 0.44 |
| hpv | 0.85 | 0.32 |
| streptococcus-pyogenes | 0.84 | 0.69 |
| influenza | 0.83 | 0.06 |
| sars-cov-2 | 0.62 | 0.09 |
| helicobacter-pylori | 0.53 | 0.06 |
| mycobacterium-tuberculosis | 0.02 | 0.03 |
| neisseria-meningitidis | 0.01 | 0.04 |
| hiv | 0.01 | 0.00 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 1.1 | 33 |
| 1 | 2 | 1.9 | 36 |
| 1 | 3 | 3.7 | 51 |
| 2 | 1 | 1.0 | 30 |
| 2 | 2 | 2.1 | 31 |
| 2 | 3 | 4.7 | 40 |
| 2 | 4 | 2.5 | 43 |
| 3 | 1 | 1.4 | 66 |
| 3 | 2 | 1.5 | 59 |
| 3 | 3 | 3.3 | 70 |
| 3 | 4 | 0.4 | 115 |
| 4 | 1 | 0.3 | 23 |
| 4 | 2 | 1.2 | 35 |
| 4 | 3 | 3.6 | 41 |
| 4 | 4 | 2.9 | 36 |
| 5 | 1 | 0.5 | 21 |
| 5 | 2 | 0.8 | 30 |
| 5 | 3 | 3.0 | 31 |
| 5 | 4 | 1.6 | 34 |
| 5 | 5 | 1.3 | 35 |
| 6 | 1 | 1.2 | 58 |
| 6 | 2 | 2.5 | 67 |
| 6 | 3 | 1.7 | 69 |
| 6 | 4 | 0.8 | 64 |
| 6 | 5 | 1.5 | 66 |
| 7 | 1 | 1.2 | 31 |
| 7 | 2 | 3.5 | 39 |
| 7 | 3 | 2.8 | 35 |
| 7 | 4 | 1.7 | 37 |
| 7 | 5 | 0.2 | 44 |
| 8 | 1 | 2.0 | 53 |
| 8 | 2 | 3.0 | 67 |
| 8 | 3 | 1.5 | 55 |
| 8 | 4 | 0.1 | 54 |
| 8 | 5 | 0.6 | 62 |
| 9 | 1 | 2.9 | 63 |
| 9 | 2 | 2.5 | 70 |
| 9 | 3 | 1.7 | 59 |
| 9 | 4 | 0.4 | 60 |
| 9 | 5 | 1.0 | 67 |
| 9 | 6 | 0.0 | 57 |
| 10 | 1 | 5.7 | 62 |
| 10 | 2 | 1.3 | 51 |
| 10 | 3 | 1.2 | 56 |
| 10 | 4 | 0.5 | 54 |
| 10 | 5 | 0.4 | 57 |
| 10 | 6 | 0.1 | 78 |
