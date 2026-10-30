# Playtest report: baseline_1000 (1000 games, difficulty medium)

## By level

| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |
|---|---|---|---|---|---|---|---|
| 1 | Throat | 100 | 93 (+-5) | 12.9/20 | 188 | 174 | 27 |
| 2 | Trachea | 100 | 66 (+-9) | 11.5/20 | 103 | 52 | 244 |
| 3 | Lungs | 100 | 56 (+-10) | 6.7/20 | 230 | 91 | 60 |
| 4 | Esophagus | 100 | 44 (+-10) | 7.0/20 | 89 | 42 | 226 |
| 5 | Stomach | 100 | 4 (+-4) | 0.4/20 | 53 | 43 | 230 |
| 6 | Intestines | 100 | 30 (+-9) | 2.5/20 | 200 | 74 | 49 |
| 7 | Bloodstream | 100 | 16 (+-7) | 1.2/20 | 125 | 50 | 91 |
| 8 | Liver | 100 | 37 (+-9) | 5.7/20 | 206 | 129 | 458 |
| 9 | Spleen | 100 | 28 (+-9) | 4.2/20 | 220 | 128 | 694 |
| 10 | Lymph Nodes | 100 | 28 (+-9) | 3.4/20 | 220 | 120 | 235 |

## Win rate by level and strategy (%)

| level | balanced_mix | cheap | damage_only | few_strong | random_a | random_b | smart | smart_calls | support_heavy | worst_slots |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100 | 30 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 2 | 90 | 0 | 90 | 90 | 40 | 50 | 90 | 100 | 10 | 100 |
| 3 | 70 | 0 | 100 | 80 | 20 | 30 | 80 | 90 | 0 | 90 |
| 4 | 80 | 0 | 10 | 10 | 50 | 30 | 100 | 60 | 20 | 80 |
| 5 | 0 | 0 | 0 | 0 | 0 | 10 | 30 | 0 | 0 | 0 |
| 6 | 60 | 0 | 30 | 40 | 10 | 10 | 70 | 60 | 0 | 20 |
| 7 | 60 | 0 | 20 | 10 | 0 | 0 | 40 | 30 | 0 | 0 |
| 8 | 100 | 0 | 90 | 0 | 20 | 20 | 40 | 40 | 0 | 60 |
| 9 | 70 | 0 | 80 | 0 | 30 | 10 | 50 | 30 | 0 | 10 |
| 10 | 80 | 0 | 90 | 0 | 0 | 10 | 50 | 50 | 0 | 0 |

## How the games end, by level

| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |
|---|---|---|---|---|---|
| 1 | 93 | 7 | wave 2 (7 games) | 102 | 12 / 14 / 16 |
| 2 | 66 | 34 | wave 4 (19 games) | 83 | 16 / 20 / 20 |
| 3 | 56 | 44 | wave 2 (22 games) | 137 | 8 / 12 / 16 |
| 4 | 44 | 56 | wave 3 (55 games) | 68 | 13 / 20 / 20 |
| 5 | 4 | 96 | wave 2 (75 games) | 38 | 4 / 14 / 18 |
| 6 | 30 | 70 | wave 3 (48 games) | 128 | 4 / 8 / 10 |
| 7 | 16 | 84 | wave 3 (32 games) | 89 | 3 / 6 / 14 |
| 8 | 37 | 63 | wave 2 (19 games) | 152 | 10 / 20 / 20 |
| 9 | 28 | 72 | wave 2 (23 games) | 174 | 10 / 18 / 20 |
| 10 | 28 | 72 | wave 2 (39 games) | 92 | 7 / 12 / 20 |

## By strategy

| strategy | games | win % | avg health left |
|---|---|---|---|
| balanced_mix | 100 | 71 | 11.2 |
| smart | 100 | 65 | 8.8 |
| damage_only | 100 | 61 | 9.6 |
| smart_calls | 100 | 56 | 7.3 |
| worst_slots | 100 | 46 | 6.1 |
| few_strong | 100 | 33 | 4.3 |
| random_a | 100 | 27 | 3.1 |
| random_b | 100 | 27 | 3.1 |
| support_heavy | 100 | 13 | 1.7 |
| cheap | 100 | 3 | 0.2 |

## Towers: damage that took health away, per amino acid spent

| tower | built | cost | damage / game | damage per amino | kills / game |
|---|---|---|---|---|---|
| lysozyme | 741 | 60 | 2729 | 35.72 | 48.6 |
| hypothalamus | 558 | 70 | 1910 | 23.13 | 29.2 |
| interferon | 894 | 60 | 1783 | 21.83 | 47.4 |
| macrophage | 1171 | 50 | 964 | 12.05 | 21.2 |
| neutrophil | 517 | 45 | 506 | 8.77 | 10.1 |
| t-lymphocyte | 412 | 90 | 794 | 7.73 | 20.9 |
| b-lymphocyte | 283 | 80 | 130 | 1.45 | 1.7 |
| bone-marrow | 212 | 100 | 103 | 0.93 | 1.9 |
| mucus-cell | 1143 | 40 | 0 | 0.00 | 0.0 |
| platelet | 390 | 55 | 0 | 0.00 | 0.0 |

## Share of the damage by tower, per level (%)

| level | b-lymphocyte | bone-marrow | hypothalamus | interferon | lysozyme | macrophage | neutrophil | t-lymphocyte |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 47 | 0 | 53 | 0 | 0 |
| 2 | 0 | 0 | 0 | 39 | 40 | 16 | 5 | 0 |
| 3 | 0 | 0 | 19 | 24 | 33 | 18 | 6 | 0 |
| 4 | 0 | 0 | 20 | 40 | 27 | 7 | 2 | 3 |
| 5 | 0 | 0 | 25 | 11 | 52 | 6 | 1 | 4 |
| 6 | 0 | 1 | 15 | 6 | 40 | 23 | 4 | 11 |
| 7 | 0 | 0 | 19 | 31 | 25 | 13 | 4 | 7 |
| 8 | 1 | 1 | 22 | 18 | 30 | 13 | 7 | 8 |
| 9 | 1 | 1 | 20 | 21 | 27 | 17 | 4 | 8 |
| 10 | 1 | 1 | 20 | 22 | 34 | 12 | 4 | 7 |

## Enemies: how many got out

| enemy | spawned | killed | leaked | leak % |
|---|---|---|---|---|
| hiv | 35 | 18 | 17 | 48.6 |
| mycobacterium-tuberculosis | 59 | 35 | 24 | 40.7 |
| clostridioides-difficile | 6818 | 4903 | 1915 | 28.1 |
| neisseria-meningitidis | 40 | 31 | 9 | 22.5 |
| staphylococcus-aureus | 8219 | 6934 | 1285 | 15.6 |
| e-coli | 10532 | 9164 | 1368 | 13.0 |
| helicobacter-pylori | 6862 | 6042 | 820 | 11.9 |
| herpes-simplex | 9930 | 8752 | 1178 | 11.9 |
| influenza | 12186 | 11085 | 1101 | 9.0 |
| sars-cov-2 | 8575 | 8154 | 421 | 4.9 |
| rhinovirus | 24925 | 24022 | 903 | 3.6 |
| streptococcus-pyogenes | 12370 | 11990 | 380 | 3.1 |
| hpv | 10251 | 10063 | 188 | 1.8 |

## Enemies that leak in lost games vs won games (leaks per game)

| enemy | in lost games | in won games |
|---|---|---|
| clostridioides-difficile | 2.53 | 1.00 |
| e-coli | 2.14 | 0.21 |
| staphylococcus-aureus | 1.93 | 0.32 |
| influenza | 1.70 | 0.21 |
| herpes-simplex | 1.62 | 0.52 |
| helicobacter-pylori | 1.35 | 0.03 |
| rhinovirus | 1.30 | 0.31 |
| sars-cov-2 | 0.67 | 0.05 |
| hpv | 0.31 | 0.00 |
| streptococcus-pyogenes | 0.20 | 0.65 |
| hiv | 0.01 | 0.02 |
| neisseria-meningitidis | 0.01 | 0.01 |
| mycobacterium-tuberculosis | 0.01 | 0.05 |

## Waves: where the games are lost (leaks per wave) and how long a wave lasts

| level | wave | leaks / game | avg duration (s) |
|---|---|---|---|
| 1 | 1 | 0.6 | 33 |
| 1 | 2 | 1.0 | 32 |
| 1 | 3 | 3.0 | 54 |
| 2 | 1 | 2.5 | 39 |
| 2 | 2 | 4.2 | 31 |
| 2 | 3 | 1.6 | 34 |
| 2 | 4 | 0.2 | 35 |
| 3 | 1 | 4.5 | 73 |
| 3 | 2 | 1.2 | 48 |
| 3 | 3 | 1.0 | 66 |
| 3 | 4 | 0.2 | 127 |
| 4 | 1 | 10.0 | 39 |
| 4 | 2 | 2.3 | 38 |
| 4 | 3 | 0.1 | 31 |
| 4 | 4 | 0.1 | 37 |
| 5 | 1 | 8.0 | 35 |
| 5 | 2 | 0.9 | 45 |
| 5 | 3 | 1.3 | 40 |
| 5 | 4 | 0.0 | 38 |
| 5 | 5 | 0.3 | 50 |
| 6 | 1 | 5.2 | 72 |
| 6 | 2 | 4.0 | 74 |
| 6 | 3 | 0.2 | 52 |
| 6 | 4 | 0.6 | 69 |
| 6 | 5 | 0.5 | 65 |
| 7 | 1 | 8.0 | 38 |
| 7 | 2 | 1.3 | 34 |
| 7 | 3 | 2.3 | 43 |
| 7 | 4 | 0.0 | 35 |
| 7 | 5 | 0.1 | 52 |
| 8 | 1 | 4.5 | 77 |
| 8 | 2 | 1.7 | 72 |
| 8 | 3 | 2.6 | 62 |
| 8 | 4 | 0.0 | 50 |
| 8 | 5 | 1.0 | 67 |
| 9 | 1 | 5.7 | 72 |
| 9 | 2 | 0.8 | 73 |
| 9 | 3 | 3.4 | 70 |
| 9 | 4 | 0.0 | 58 |
| 9 | 5 | 1.0 | 79 |
| 9 | 6 | 0.0 | 52 |
| 10 | 1 | 7.2 | 59 |
| 10 | 2 | 0.4 | 40 |
| 10 | 3 | 1.3 | 65 |
| 10 | 4 | 0.0 | 40 |
| 10 | 5 | 1.0 | 70 |
| 10 | 6 | 0.2 | 98 |
