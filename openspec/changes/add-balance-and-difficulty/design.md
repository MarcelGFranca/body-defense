## Decisions

- **The tests run the real game, without a screen, at high speed.** An Android emulator plays at real time (minutes per game) and gives the same results, because the simulation has no randomness. The bots get human-like noise (late builds, odd choices) so repeated games differ.
- **Ten strategies**, from a careful player to a careless one (random towers, only cheap towers, only support towers, worst slots first, half the slots). A level is balanced when the careful ones win most of the time and the careless ones lose often.
- **Targets (Medium, all strategies):** about 90% of wins in level 1, falling to about 45% in level 10; a boss that gets through in 10% to 25% of the fights; the damage of each tower per amino acid spent within a band of about 1.5x (area towers a little higher, support towers lower).
- **Waves grow.** The first wave is 40% of the full size and they reach 100% in the last one. The spawn interval never goes below 0.6 s. Without this the first wave flooded the field before the player could afford three towers.
- **Wave size per level is found by a tuner** that plays every level with several multipliers and picks the one closest to the target. Starting amino acids were raised so that a smaller wave does not also mean less money.
- **Difficulty is a data file** (`data/difficulties/*.tres`), applied by `Level` to the starting amino acids, body health, enemy health and speed, rewards and wave times. Copies made by a split are not scaled twice.
- **Easy, Medium, Hard** were calibrated with 1000 games each: all strategies win 87%, 65% and 42%; the careful strategies win 100%, 93% and 70%.
