# Playtest report: first_wave_10s (100 games, difficulty medium)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 10 | 100 (+-0) | 11.6/20 | 196 | 169 | 31 |
| 2 | Trachea | 10 | 60 (+-30) | 11.7/20 | 172 | 59 | 113 |
| 3 | Lungs | 10 | 70 (+-28) | 11.9/20 | 279 | 89 | 57 |
| 4 | Esophagus | 10 | 100 (+-0) | 9.7/20 | 175 | 119 | 44 |
| 5 | Stomach | 10 | 70 (+-28) | 11.6/20 | 200 | 84 | 38 |
| 6 | Intestines | 10 | 70 (+-28) | 11.2/20 | 276 | 159 | 46 |
| 7 | Bloodstream | 10 | 60 (+-30) | 7.1/20 | 236 | 87 | 51 |
| 8 | Liver | 10 | 60 (+-30) | 10.6/20 | 254 | 135 | 316 |
| 9 | Spleen | 10 | 40 (+-30) | 2.9/20 | 265 | 156 | 584 |
| 10 | Lymph Nodes | 10 | 40 (+-30) | 5.8/20 | 265 | 100 | 241 |

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
| 3 | 7 | 3 | wave 4 (3 games) | 206 | 11 / 20 / 20 |
| 4 | 10 | 0 | wave 0 (0 games) | - | 4 / 9 / 19 |
| 5 | 7 | 3 | wave 4 (2 games) | 166 | 14 / 17 / 20 |
| 6 | 7 | 3 | wave 5 (2 games) | 259 | 12 / 18 / 20 |
| 7 | 6 | 4 | wave 4 (3 games) | 215 | 10 / 12 / 13 |
| 8 | 6 | 4 | wave 4 (2 games) | 191 | 18 / 20 / 20 |
| 9 | 4 | 6 | wave 4 (3 games) | 190 | 6 / 7 / 12 |
| 10 | 4 | 6 | wave 3 (3 games) | 193 | 14 / 20 / 20 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| smart_calls | 10 | 100 | 16.2 |
| balanced_mix | 10 | 100 | 15.8 |
| smart | 10 | 90 | 13.0 |
| damage_only | 10 | 90 | 14.1 |
| few_strong | 10 | 80 | 10.2 |
| worst_slots | 10 | 70 | 8.6 |
| random_a | 10 | 50 | 6.8 |
| random_b | 10 | 40 | 5.7 |
| support_heavy | 10 | 30 | 3.2 |
| cheap | 10 | 20 | 0.5 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| hypothalamus | 61 | 90 | 1361 | 13.14 | 21.5 |
| macrophage | 117 | 50 | 993 | 12.73 | 21.3 |
| lysozyme | 80 | 70 | 1041 | 12.27 | 17.4 |
| interferon | 86 | 70 | 1039 | 11.57 | 25.0 |
| t-lymphocyte | 50 | 90 | 1096 | 10.47 | 26.4 |
| neutrophil | 53 | 45 | 484 | 9.53 | 8.0 |
| bone-marrow | 23 | 90 | 458 | 4.20 | 11.0 |
| b-lymphocyte | 35 | 70 | 239 | 2.83 | 4.1 |
| mucus-cell | 150 | 40 | 0 | 0.00 | 0.0 |
| platelet | 38 | 55 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 42 | 0 | 58 | 0 | 0 |
| 2 | 0 | 0 | 0 | 34 | 30 | 27 | 10 | 0 |
| 3 | 0 | 0 | 20 | 16 | 29 | 28 | 7 | 0 |
| 4 | 0 | 0 | 10 | 19 | 21 | 19 | 6 | 25 |
| 5 | 3 | 0 | 26 | 9 | 18 | 24 | 6 | 13 |
| 6 | 1 | 6 | 13 | 7 | 20 | 27 | 6 | 20 |
| 7 | 3 | 5 | 15 | 16 | 18 | 25 | 5 | 13 |
| 8 | 3 | 1 | 25 | 16 | 19 | 17 | 9 | 10 |
| 9 | 2 | 3 | 30 | 18 | 9 | 17 | 5 | 15 |
| 10 | 1 | 3 | 11 | 23 | 28 | 13 | 3 | 17 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| mycobacterium-tuberculosis | 8 | 5 | 3 | 37.5 |
| hiv | 4 | 3 | 1 | 25.0 |
| staphylococcus-aureus | 687 | 569 | 118 | 17.2 |
| neisseria-meningitidis | 12 | 10 | 2 | 16.7 |
| clostridioides-difficile | 713 | 627 | 86 | 12.1 |
| herpes-simplex | 703 | 626 | 77 | 11.0 |
| e-coli | 501 | 448 | 53 | 10.6 |
| hpv | 774 | 705 | 69 | 8.9 |
| streptococcus-pyogenes | 1024 | 936 | 88 | 8.6 |
| helicobacter-pylori | 449 | 419 | 30 | 6.7 |
| sars-cov-2 | 683 | 648 | 35 | 5.1 |
| influenza | 795 | 755 | 40 | 5.0 |
| rhinovirus | 1712 | 1644 | 68 | 4.0 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| staphylococcus-aureus | 2.58 | 0.49 |
| rhinovirus | 1.73 | 0.16 |
| clostridioides-difficile | 1.70 | 0.45 |
| streptococcus-pyogenes | 1.45 | 0.60 |
| e-coli | 1.39 | 0.10 |
| herpes-simplex | 1.15 | 0.58 |
| sars-cov-2 | 0.94 | 0.06 |
| hpv | 0.91 | 0.58 |
| helicobacter-pylori | 0.85 | 0.03 |
| influenza | 0.64 | 0.28 |
| mycobacterium-tuberculosis | 0.03 | 0.03 |
| neisseria-meningitidis | 0.00 | 0.03 |
| hiv | 0.00 | 0.01 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 0.0 | 32 |
| 1 | 2 | 0.7 | 34 |
| 1 | 3 | 4.4 | 55 |
| 2 | 1 | 1.2 | 32 |
| 2 | 2 | 2.1 | 31 |
| 2 | 3 | 3.3 | 40 |
| 2 | 4 | 1.3 | 49 |
| 3 | 1 | 0.9 | 66 |
| 3 | 2 | 1.0 | 57 |
| 3 | 3 | 2.6 | 73 |
| 3 | 4 | 0.3 | 120 |
| 4 | 1 | 0.2 | 24 |
| 4 | 2 | 0.1 | 33 |
| 4 | 3 | 1.7 | 42 |
| 4 | 4 | 4.9 | 42 |
| 5 | 1 | 0.6 | 23 |
| 5 | 2 | 0.7 | 31 |
| 5 | 3 | 1.9 | 32 |
| 5 | 4 | 1.5 | 33 |
| 5 | 5 | 0.7 | 35 |
| 6 | 1 | 0.6 | 50 |
| 6 | 2 | 1.4 | 64 |
| 6 | 3 | 1.0 | 67 |
| 6 | 4 | 1.6 | 67 |
| 6 | 5 | 0.6 | 66 |
| 7 | 1 | 0.7 | 31 |
| 7 | 2 | 1.9 | 40 |
| 7 | 3 | 2.4 | 38 |
| 7 | 4 | 2.7 | 39 |
| 7 | 5 | 0.2 | 44 |
| 8 | 1 | 0.4 | 49 |
| 8 | 2 | 2.1 | 67 |
| 8 | 3 | 2.2 | 60 |
| 8 | 4 | 0.0 | 54 |
| 8 | 5 | 0.6 | 62 |
| 9 | 1 | 1.9 | 61 |
| 9 | 2 | 3.7 | 73 |
| 9 | 3 | 1.8 | 66 |
| 9 | 4 | 0.4 | 60 |
| 9 | 5 | 1.2 | 85 |
| 9 | 6 | 1.2 | 73 |
| 10 | 1 | 3.7 | 61 |
| 10 | 2 | 2.7 | 56 |
| 10 | 3 | 1.1 | 60 |
| 10 | 4 | 0.0 | 48 |
| 10 | 5 | 0.7 | 69 |
| 10 | 6 | 0.1 | 73 |
