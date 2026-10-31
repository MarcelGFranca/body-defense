# Playtest report: before_first_wave_10s (100 games, difficulty medium)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 10 | 100 (+-0) | 11.5/20 | 196 | 167 | 31 |
| 2 | Trachea | 10 | 60 (+-30) | 11.7/20 | 172 | 64 | 113 |
| 3 | Lungs | 10 | 70 (+-28) | 11.5/20 | 279 | 97 | 62 |
| 4 | Esophagus | 10 | 100 (+-0) | 9.7/20 | 175 | 122 | 44 |
| 5 | Stomach | 10 | 70 (+-28) | 11.9/20 | 200 | 100 | 39 |
| 6 | Intestines | 10 | 70 (+-28) | 11.2/20 | 276 | 162 | 46 |
| 7 | Bloodstream | 10 | 60 (+-30) | 7.1/20 | 236 | 90 | 53 |
| 8 | Liver | 10 | 60 (+-30) | 10.6/20 | 254 | 139 | 315 |
| 9 | Spleen | 10 | 40 (+-30) | 3.2/20 | 275 | 164 | 611 |
| 10 | Lymph Nodes | 10 | 40 (+-30) | 5.9/20 | 274 | 137 | 257 |

## Win rate by level and strategy (%)

| level | balanced_mix | cheap | damage_only | few_strong | random_a | random_b | smart | smart_calls | support_heavy | worst_slots |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 2 | 100 | 0 | 100 | 100 | 0 | 0 | 100 | 100 | 0 | 100 |
| 3 | 100 | 0 | 100 | 100 | 100 | 0 | 100 | 100 | 0 | 100 |
| 4 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 5 | 100 | 0 | 100 | 100 | 0 | 100 | 100 | 100 | 100 | 0 |
| 6 | 100 | 0 | 100 | 100 | 0 | 100 | 100 | 100 | 0 | 100 |
| 7 | 100 | 0 | 100 | 100 | 100 | 0 | 100 | 100 | 0 | 0 |
| 8 | 100 | 0 | 100 | 0 | 100 | 0 | 100 | 100 | 0 | 100 |
| 9 | 100 | 0 | 0 | 100 | 0 | 0 | 0 | 100 | 0 | 100 |
| 10 | 100 | 0 | 100 | 0 | 0 | 0 | 100 | 100 | 0 | 0 |

## How the games end, by level

| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |
|---|---|---|---|---|---|
| 1 | 10 | 0 | wave 0 (0 games) | - | 12 / 14 / 14 |
| 2 | 6 | 4 | wave 4 (3 games) | 189 | 19 / 20 / 20 |
| 3 | 7 | 3 | wave 4 (3 games) | 205 | 11 / 20 / 20 |
| 4 | 10 | 0 | wave 0 (0 games) | - | 4 / 9 / 19 |
| 5 | 7 | 3 | wave 4 (2 games) | 166 | 14 / 17 / 20 |
| 6 | 7 | 3 | wave 5 (2 games) | 259 | 12 / 18 / 20 |
| 7 | 6 | 4 | wave 4 (3 games) | 215 | 10 / 12 / 13 |
| 8 | 6 | 4 | wave 4 (2 games) | 194 | 18 / 20 / 20 |
| 9 | 4 | 6 | wave 4 (3 games) | 201 | 6 / 10 / 12 |
| 10 | 4 | 6 | wave 3 (3 games) | 193 | 15 / 20 / 20 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| smart_calls | 10 | 100 | 16.2 |
| balanced_mix | 10 | 100 | 15.8 |
| smart | 10 | 90 | 12.9 |
| damage_only | 10 | 90 | 14.2 |
| few_strong | 10 | 80 | 10.2 |
| worst_slots | 10 | 70 | 8.9 |
| random_a | 10 | 50 | 6.8 |
| random_b | 10 | 40 | 5.7 |
| support_heavy | 10 | 30 | 3.2 |
| cheap | 10 | 20 | 0.4 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| hypothalamus | 61 | 90 | 1368 | 13.21 | 21.5 |
| macrophage | 118 | 50 | 1002 | 12.74 | 21.7 |
| lysozyme | 80 | 70 | 1050 | 12.37 | 17.4 |
| interferon | 86 | 70 | 1044 | 11.62 | 24.9 |
| t-lymphocyte | 50 | 90 | 1166 | 11.14 | 27.9 |
| neutrophil | 52 | 45 | 487 | 9.78 | 8.2 |
| bone-marrow | 23 | 90 | 491 | 4.51 | 11.7 |
| b-lymphocyte | 35 | 70 | 259 | 3.06 | 4.0 |
| platelet | 37 | 55 | 0 | 0.00 | 0.0 |
| mucus-cell | 151 | 40 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 42 | 0 | 58 | 0 | 0 |
| 2 | 0 | 0 | 0 | 34 | 30 | 27 | 10 | 0 |
| 3 | 0 | 0 | 19 | 16 | 29 | 28 | 7 | 0 |
| 4 | 0 | 0 | 10 | 19 | 21 | 19 | 6 | 25 |
| 5 | 3 | 0 | 27 | 9 | 17 | 24 | 6 | 13 |
| 6 | 1 | 7 | 13 | 7 | 20 | 27 | 6 | 20 |
| 7 | 3 | 5 | 15 | 17 | 18 | 25 | 4 | 13 |
| 8 | 3 | 1 | 25 | 16 | 19 | 16 | 9 | 10 |
| 9 | 3 | 4 | 29 | 17 | 9 | 17 | 5 | 17 |
| 10 | 1 | 2 | 11 | 23 | 29 | 13 | 3 | 17 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| hiv | 5 | 3 | 2 | 40.0 |
| mycobacterium-tuberculosis | 8 | 5 | 3 | 37.5 |
| neisseria-meningitidis | 12 | 10 | 2 | 16.7 |
| staphylococcus-aureus | 706 | 591 | 115 | 16.3 |
| clostridioides-difficile | 729 | 641 | 88 | 12.1 |
| herpes-simplex | 703 | 628 | 75 | 10.7 |
| e-coli | 499 | 449 | 50 | 10.0 |
| hpv | 779 | 713 | 66 | 8.5 |
| streptococcus-pyogenes | 1046 | 958 | 88 | 8.4 |
| helicobacter-pylori | 461 | 433 | 28 | 6.1 |
| influenza | 795 | 753 | 42 | 5.3 |
| sars-cov-2 | 701 | 666 | 35 | 5.0 |
| rhinovirus | 1743 | 1663 | 80 | 4.6 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| staphylococcus-aureus | 2.52 | 0.48 |
| rhinovirus | 1.94 | 0.24 |
| clostridioides-difficile | 1.76 | 0.45 |
| streptococcus-pyogenes | 1.45 | 0.60 |
| e-coli | 1.30 | 0.10 |
| herpes-simplex | 1.18 | 0.54 |
| sars-cov-2 | 0.94 | 0.06 |
| hpv | 0.82 | 0.58 |
| helicobacter-pylori | 0.82 | 0.01 |
| influenza | 0.70 | 0.28 |
| mycobacterium-tuberculosis | 0.03 | 0.03 |
| hiv | 0.03 | 0.01 |
| neisseria-meningitidis | 0.00 | 0.03 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 0.1 | 34 |
| 1 | 2 | 0.7 | 34 |
| 1 | 3 | 4.4 | 55 |
| 2 | 1 | 1.2 | 32 |
| 2 | 2 | 2.1 | 31 |
| 2 | 3 | 3.3 | 40 |
| 2 | 4 | 1.3 | 49 |
| 3 | 1 | 1.3 | 66 |
| 3 | 2 | 0.9 | 59 |
| 3 | 3 | 3.0 | 72 |
| 3 | 4 | 0.3 | 120 |
| 4 | 1 | 0.2 | 24 |
| 4 | 2 | 0.1 | 33 |
| 4 | 3 | 1.7 | 42 |
| 4 | 4 | 4.9 | 42 |
| 5 | 1 | 0.3 | 23 |
| 5 | 2 | 0.7 | 31 |
| 5 | 3 | 1.9 | 32 |
| 5 | 4 | 1.5 | 33 |
| 5 | 5 | 0.7 | 35 |
| 6 | 1 | 0.6 | 50 |
| 6 | 2 | 1.4 | 64 |
| 6 | 3 | 1.0 | 67 |
| 6 | 4 | 1.6 | 67 |
| 6 | 5 | 0.6 | 66 |
| 7 | 1 | 0.8 | 31 |
| 7 | 2 | 1.8 | 40 |
| 7 | 3 | 2.1 | 38 |
| 7 | 4 | 2.9 | 39 |
| 7 | 5 | 0.2 | 44 |
| 8 | 1 | 0.3 | 49 |
| 8 | 2 | 2.3 | 66 |
| 8 | 3 | 2.3 | 60 |
| 8 | 4 | 0.0 | 54 |
| 8 | 5 | 0.6 | 62 |
| 9 | 1 | 1.5 | 61 |
| 9 | 2 | 3.6 | 74 |
| 9 | 3 | 1.8 | 71 |
| 9 | 4 | 0.6 | 62 |
| 9 | 5 | 1.2 | 74 |
| 9 | 6 | 1.2 | 74 |
| 10 | 1 | 3.7 | 59 |
| 10 | 2 | 2.5 | 56 |
| 10 | 3 | 1.1 | 60 |
| 10 | 4 | 0.0 | 48 |
| 10 | 5 | 0.9 | 70 |
| 10 | 6 | 0.2 | 94 |
