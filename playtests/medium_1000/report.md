# Playtest report: medium_1000 (1000 games, difficulty medium)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 100 | 91 (+-6) | 11.1/20 | 187 | 158 | 31 |
| 2 | Trachea | 100 | 75 (+-8) | 12.3/20 | 172 | 95 | 118 |
| 3 | Lungs | 100 | 76 (+-8) | 12.0/20 | 282 | 129 | 58 |
| 4 | Esophagus | 100 | 77 (+-8) | 10.6/20 | 171 | 116 | 35 |
| 5 | Stomach | 100 | 68 (+-9) | 10.9/20 | 202 | 107 | 42 |
| 6 | Intestines | 100 | 55 (+-10) | 8.0/20 | 274 | 149 | 50 |
| 7 | Bloodstream | 100 | 56 (+-10) | 7.4/20 | 233 | 83 | 52 |
| 8 | Liver | 100 | 59 (+-10) | 10.4/20 | 248 | 137 | 300 |
| 9 | Spleen | 100 | 48 (+-10) | 6.9/20 | 283 | 159 | 699 |
| 10 | Lymph Nodes | 100 | 46 (+-10) | 7.1/20 | 285 | 126 | 271 |

## Win rate by level and strategy (%)

| level | balanced_mix | cheap | damage_only | few_strong | random_a | random_b | smart | smart_calls | support_heavy | worst_slots |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 30 | 100 | 100 | 90 | 90 | 100 | 100 | 100 | 100 |
| 2 | 90 | 0 | 100 | 100 | 50 | 70 | 100 | 100 | 40 | 100 |
| 3 | 90 | 0 | 100 | 100 | 70 | 60 | 100 | 100 | 40 | 100 |
| 4 | 100 | 20 | 50 | 100 | 80 | 90 | 100 | 70 | 60 | 100 |
| 5 | 100 | 30 | 100 | 100 | 60 | 60 | 100 | 90 | 30 | 10 |
| 6 | 90 | 0 | 90 | 70 | 30 | 40 | 80 | 70 | 0 | 80 |
| 7 | 100 | 0 | 100 | 70 | 30 | 10 | 80 | 100 | 0 | 70 |
| 8 | 90 | 0 | 100 | 20 | 60 | 40 | 90 | 90 | 0 | 100 |
| 9 | 100 | 0 | 90 | 60 | 50 | 20 | 70 | 50 | 0 | 40 |
| 10 | 90 | 0 | 100 | 40 | 20 | 20 | 90 | 100 | 0 | 0 |

## How the games end, by level

| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |
|---|---|---|---|---|---|
| 1 | 91 | 9 | wave 2 (8 games) | 102 | 12 / 14 / 14 |
| 2 | 75 | 25 | wave 4 (19 games) | 189 | 15 / 19 / 20 |
| 3 | 76 | 24 | wave 4 (24 games) | 199 | 12 / 19 / 20 |
| 4 | 77 | 23 | wave 4 (23 games) | 176 | 8 / 18 / 20 |
| 5 | 68 | 32 | wave 4 (16 games) | 181 | 14 / 18 / 20 |
| 6 | 55 | 45 | wave 5 (30 games) | 250 | 10 / 15 / 20 |
| 7 | 56 | 44 | wave 4 (22 games) | 211 | 10 / 14 / 19 |
| 8 | 59 | 41 | wave 3 (16 games) | 184 | 18 / 20 / 20 |
| 9 | 48 | 52 | wave 4 (18 games) | 188 | 8 / 20 / 20 |
| 10 | 46 | 54 | wave 3 (18 games) | 191 | 12 / 18 / 20 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| balanced_mix | 100 | 95 | 16.4 |
| damage_only | 100 | 93 | 16.4 |
| smart | 100 | 91 | 14.8 |
| smart_calls | 100 | 87 | 13.3 |
| few_strong | 100 | 76 | 9.6 |
| worst_slots | 100 | 70 | 9.0 |
| random_a | 100 | 54 | 7.2 |
| random_b | 100 | 50 | 6.2 |
| support_heavy | 100 | 27 | 3.0 |
| cheap | 100 | 8 | 0.8 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| lysozyme | 761 | 70 | 1271 | 14.60 | 19.8 |
| hypothalamus | 595 | 90 | 1401 | 13.44 | 21.9 |
| macrophage | 1233 | 50 | 996 | 12.61 | 22.8 |
| interferon | 950 | 70 | 1032 | 11.19 | 23.5 |
| t-lymphocyte | 469 | 90 | 1076 | 9.96 | 27.8 |
| neutrophil | 545 | 45 | 579 | 9.79 | 12.3 |
| bone-marrow | 237 | 90 | 443 | 4.07 | 9.5 |
| b-lymphocyte | 344 | 70 | 300 | 3.64 | 3.6 |
| platelet | 404 | 55 | 0 | 0.00 | 0.0 |
| mucus-cell | 1364 | 40 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 43 | 0 | 57 | 0 | 0 |
| 2 | 0 | 0 | 0 | 29 | 33 | 28 | 10 | 0 |
| 3 | 0 | 0 | 22 | 19 | 23 | 27 | 10 | 0 |
| 4 | 0 | 0 | 19 | 29 | 17 | 19 | 6 | 10 |
| 5 | 2 | 0 | 19 | 10 | 15 | 27 | 4 | 22 |
| 6 | 1 | 6 | 16 | 7 | 23 | 24 | 5 | 17 |
| 7 | 2 | 4 | 16 | 19 | 16 | 19 | 6 | 18 |
| 8 | 3 | 2 | 22 | 17 | 19 | 16 | 8 | 13 |
| 9 | 4 | 3 | 22 | 19 | 18 | 19 | 5 | 11 |
| 10 | 2 | 3 | 22 | 20 | 23 | 15 | 5 | 11 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| mycobacterium-tuberculosis | 81 | 61 | 20 | 24.7 |
| neisseria-meningitidis | 122 | 101 | 21 | 17.2 |
| staphylococcus-aureus | 7380 | 6274 | 1106 | 15.0 |
| clostridioides-difficile | 7382 | 6380 | 1002 | 13.6 |
| hiv | 49 | 43 | 6 | 12.2 |
| e-coli | 5020 | 4417 | 603 | 12.0 |
| herpes-simplex | 7221 | 6512 | 709 | 9.8 |
| streptococcus-pyogenes | 10286 | 9494 | 792 | 7.7 |
| helicobacter-pylori | 4585 | 4235 | 350 | 7.6 |
| hpv | 8166 | 7583 | 583 | 7.1 |
| influenza | 7969 | 7589 | 380 | 4.8 |
| rhinovirus | 18196 | 17357 | 839 | 4.6 |
| sars-cov-2 | 7242 | 6935 | 307 | 4.2 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| staphylococcus-aureus | 2.37 | 0.43 |
| clostridioides-difficile | 1.92 | 0.51 |
| rhinovirus | 1.64 | 0.41 |
| herpes-simplex | 1.52 | 0.27 |
| e-coli | 1.46 | 0.14 |
| hpv | 1.10 | 0.31 |
| streptococcus-pyogenes | 1.07 | 0.64 |
| helicobacter-pylori | 0.91 | 0.05 |
| sars-cov-2 | 0.74 | 0.08 |
| influenza | 0.72 | 0.20 |
| neisseria-meningitidis | 0.03 | 0.02 |
| mycobacterium-tuberculosis | 0.01 | 0.02 |
| hiv | 0.01 | 0.00 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 0.8 | 34 |
| 1 | 2 | 1.6 | 34 |
| 1 | 3 | 3.6 | 54 |
| 2 | 1 | 0.9 | 28 |
| 2 | 2 | 1.5 | 29 |
| 2 | 3 | 2.3 | 38 |
| 2 | 4 | 2.5 | 46 |
| 3 | 1 | 0.8 | 66 |
| 3 | 2 | 1.3 | 56 |
| 3 | 3 | 2.5 | 72 |
| 3 | 4 | 0.4 | 116 |
| 4 | 1 | 0.2 | 22 |
| 4 | 2 | 0.7 | 34 |
| 4 | 3 | 2.5 | 41 |
| 4 | 4 | 3.2 | 38 |
| 5 | 1 | 0.3 | 20 |
| 5 | 2 | 0.5 | 29 |
| 5 | 3 | 2.1 | 31 |
| 5 | 4 | 1.7 | 35 |
| 5 | 5 | 1.0 | 36 |
| 6 | 1 | 0.8 | 55 |
| 6 | 2 | 1.7 | 66 |
| 6 | 3 | 1.6 | 69 |
| 6 | 4 | 1.1 | 70 |
| 6 | 5 | 1.7 | 67 |
| 7 | 1 | 0.9 | 30 |
| 7 | 2 | 2.1 | 38 |
| 7 | 3 | 2.7 | 37 |
| 7 | 4 | 2.1 | 38 |
| 7 | 5 | 0.3 | 42 |
| 8 | 1 | 1.4 | 50 |
| 8 | 2 | 2.3 | 67 |
| 8 | 3 | 1.5 | 57 |
| 8 | 4 | 0.1 | 54 |
| 8 | 5 | 0.7 | 62 |
| 9 | 1 | 1.7 | 61 |
| 9 | 2 | 2.5 | 72 |
| 9 | 3 | 1.8 | 65 |
| 9 | 4 | 0.4 | 67 |
| 9 | 5 | 1.5 | 77 |
| 9 | 6 | 0.2 | 69 |
| 10 | 1 | 3.8 | 59 |
| 10 | 2 | 1.6 | 53 |
| 10 | 3 | 1.3 | 56 |
| 10 | 4 | 0.3 | 57 |
| 10 | 5 | 0.8 | 67 |
| 10 | 6 | 0.1 | 86 |
