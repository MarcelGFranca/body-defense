## Why

The campaign worked, but it had never been measured. 1000 recorded games showed a broken curve (level 5 almost impossible, level 10 easier than level 6), most games lost in the first wave, area towers doing three times the damage of the others, and bosses that either always or never got through. There was also no way to make the game easier or harder.

## What Changes

- Record what happens in a game (damage and kills by tower, leaks by enemy, how each wave went) and play many games with bots that build in ten different ways. Tools: `tools/playtest.tscn`, `tools/analyze_playtests.py`, `tools/tune_waves.py`.
- Balance the numbers with that data: tower damage and cost, enemy health and speed, boss strength, wave sizes (waves now grow from 40% to 100%), start times (the first wave of levels 2 to 10 comes 15 s later) and starting amino acids.
- Add a Settings page to the level menu with three difficulties: Easy, Medium and Hard. Each one is a set of multipliers (starting amino acids, body health, enemy health, enemy speed, amino acids dropped, time between waves). The choice is saved on the device.
- Move "reset progress" into Settings, with a second tap to confirm.

## Impact

- New spec: `difficulty`.
- Level 1 keeps its waves; the towers it uses changed a little (Macrophage 12 to 14 damage, Interferon 6 to 5).
- Recorded games live in `playtests/`.
