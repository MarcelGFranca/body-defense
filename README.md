# Body Defense

A portrait Android tower defense built with Godot 4.7. The human body defends itself against viruses and bacteria: enemies walk along veins, defenders are immune cells, and the currency is amino acids.

The current build is a prototype of level 1 (nose and throat): 3 enemies, 3 towers, 3 timed waves, a 2x speed button and a HUD made for thumbs.

## Run

```
godot --path .
```

The window opens at 360 x 640 for development. The project size is 720 x 1280.

## Check

```
# automated tests (data, damage rules, waves, economy, level, HUD)
godot --headless --path . --fixed-fps 60 res://tests/test_runner.tscn

# data validation (enemies, towers, level)
godot --headless --path . --script res://tools/validate_data.gd

# let a bot play the level; add --call-waves to call waves early
godot --headless --path . --fixed-fps 60 -- --autoplay

# try several build plans to see how hard the level is
godot --headless --path . --fixed-fps 60 res://tools/balance_probe.tscn
```

## Data and art

All numbers live in data files, not in code.

```
godot --headless --path . --script res://tools/generate_data.gd   # rewrites data/ from the tables in that script
python3 -I tools/generate_enemy_sprites.py                        # enemy sprites and animations
python3 -I tools/generate_tower_sprites.py                        # tower icons, idle and attack animations
python3 -I tools/generate_placeholder_art.py                      # UI icons and placeholder enemy images
python3 -I tools/generate_audio.py                            # sound effects and music (add --check to measure them)
```

Run `godot --headless --path . --import` after adding or changing assets or scripts.

## Planning

Specs and tasks live in `openspec/`. The three current changes are `add-enemy-roster-and-economy`, `add-tower-roster-and-damage` and `add-level-1-prototype`.

## Credits

The UI font is Press Start 2P (SIL Open Font License, see `assets/fonts/OFL.txt`).
