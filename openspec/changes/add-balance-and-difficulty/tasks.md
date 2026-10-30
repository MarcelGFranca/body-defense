## 1. Measure

- [x] 1.1 Record per-game stats (damage and kills by tower, leaks by enemy, wave results) and verify with tests
- [x] 1.2 Write the playtest runner with ten bot strategies and human-like noise, and the analyzer; run 1000 games on the original numbers (`playtests/baseline_1000`)

## 2. Balance

- [x] 2.1 Rebalance tower damage and costs, enemy and boss numbers, wave growth, first wave time and starting amino acids, using the analysis
- [x] 2.2 Tune the wave size of every level with `tools/tune_waves.py` and check with 1000 games per difficulty

## 3. Difficulty

- [x] 3.1 Add the difficulty data (Easy, Medium, Hard) and apply it in the level, the enemies and the wave scheduler, with tests
- [x] 3.2 Add the Settings page, save the choice, and move the reset there, with tests
