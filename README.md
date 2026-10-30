# Body Defense

A portrait Android tower defense built with Godot 4.7. The human body defends itself against viruses and bacteria: enemies walk along veins, defenders are immune cells, and the currency is amino acids.

The campaign has 10 levels through the body, with a boss in levels 3, 7 and 10. The game opens on a level menu: level 1 is open, and winning a level opens the next one.

| # | Level | Boss |
|---|---|---|
| 1 | Throat | |
| 2 | Trachea | |
| 3 | Lungs | Mycobacterium tuberculosis |
| 4 | Esophagus | |
| 5 | Stomach | |
| 6 | Intestines | |
| 7 | Bloodstream | Neisseria meningitidis |
| 8 | Liver | |
| 9 | Spleen | |
| 10 | Lymph Nodes | HIV |

13 enemies (each with its own trait), 10 towers (unlocked little by little), timed waves, a 2x speed button and a HUD made for thumbs.

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

# let a bot play a level (default 1); add --call-waves to call waves early
godot --headless --path . --fixed-fps 60 -- --autoplay --level 5

# play every level with no towers and with the bot, to see how hard they are (add -- --level N for one)
godot --headless --path . --fixed-fps 60 res://tools/balance_probe.tscn
```

## Data and art

All numbers live in data files, not in code.

```
godot --headless --path . --script res://tools/generate_data.gd   # rewrites data/ from the tables in that script
python3 -I tools/generate_enemy_sprites.py                        # enemy sprites and animations
python3 -I tools/generate_tower_sprites.py                        # tower icons, idle and attack animations
python3 -I tools/generate_placeholder_art.py                      # UI icons and placeholder enemy images
python3 -I tools/generate_audio.py                            # sound effects and the ten music tracks (add --check to measure them)
python3 -I tools/generate_icon_options.py                     # the game icon and the options it was chosen from
```

Run `godot --headless --path . --import` after adding or changing assets or scripts.

## Planning

Specs and tasks live in `openspec/`. The current changes are `add-enemy-roster-and-economy`, `add-tower-roster-and-damage`, `add-level-1-prototype`, `add-game-audio` and `add-levels-2-to-10`.

## Credits

The UI font is Press Start 2P (SIL Open Font License, see `assets/fonts/OFL.txt`).
