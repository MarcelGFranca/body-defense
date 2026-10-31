# Architecture

## Flow

```
splash.tscn (game/splash.gd) -- 5 s Apolo Software logo with a glint and a chime, then the menu
menu.tscn (game/menu.gd)  -- pick level --> Session.current_level
main.tscn (game/main.gd)  -- builds Level + Hud for that level and the chosen difficulty
```
- `Menu`: level list with locks, level detail page, Tutorial (`HOW TO PLAY`, text in `TutorialPages`), Changelog (`Changelog`, opened on the first start after an update, with only the newest version and from Settings, `WHAT'S NEW`), Settings page (difficulty, sound: mute, music and effects volume with `VolumeBar`, reset progress), and the game version (from `application/config/version`) in small text at the bottom.
- `Main`: reads user args (`--level N`, `--difficulty id`, `--autoplay`, `--call-waves`), creates `Level` and `Hud`, and records a victory in `Session`.

## Autoloads

| Autoload | File | Job |
|---|---|---|
| `Economy` | `game/economy.gd` | Amino acid balance, spending, rewards |
| `GameAudio` | `game/game_audio.gd` | Music and sound effects, at most 8 voices at once |
| `Session` | `game/session.gd` | Current level, unlocked levels, best health, difficulty, saving to `user://progress.cfg` |

## Runtime classes (`game/`)

| File | Job |
|---|---|
| `level.gd` (`Level`) | One level: map, enemies, towers, waves, win/lose, difficulty, stats |
| `map_view.gd` | Draws background, path, entrance, exit and empty slots |
| `wave_scheduler.gd` | Starts waves and spawns enemies on time; scales times by difficulty; early call |
| `enemy.gd` | Movement along the path, health, traits, rewards, damage taken |
| `enemy_status.gd` | Slow, root, damage over time, mark (and its dye, see `assets/shaders/mark_tint.gdshader`), resistances on one enemy |
| `enemy_sprites.gd`, `tower_sprites.gd` | Load sprites and animations |
| `tower_beam.gd` | The thick beam and the explosion of a charging tower (T lymphocyte) |
| `root_tendrils.gd` | Tendrils drawn by a platelet on the enemies it holds |
| `tower.gd` | All tower behaviours (single target, aura, slow puddle, root, DOT, marker, summoner) |
| `blocker_unit.gd` | Neutrophils summoned by Bone Marrow: roam around a post, go to meet enemies in a guard radius, block one enemy |
| `fps_counter.gd` | FPS readout shown in debug mode (the secret code), see `Session.debug_mode` |
| `mucus_glob.gd`, `mucus_puddle.gd` | Mucus Cell projectile and slowing puddle |
| `damage_calculator.gd` | Damage after armor, resistances, marks and the damage table |
| `hud.gd` (`Hud`) | Bars, build and sell menus, long-press tower info panel (`HOLD_SECONDS`), wave info, enemy card, pause, results |
| `game_stats.gd` | Per-game record: damage and kills by tower, leaks, waves |
| `data_loader.gd`, `data_validator.gd` | Load `.tres` data and check it |
| `autoplay_bot.gd` | Simple bot used by `--autoplay` |

## Data classes (`game/data/`)

`EnemyData`, `TowerData`, `LevelData`, `WaveData`, `DifficultyData`, `DamageTable`, `EconomyConfig`, `AudioConfig`. Instances are `.tres` files in `data/`, produced by `tools/generate_data.gd`.

## Data pipeline

```
tools/generate_data.gd (tables: ENEMIES, TOWERS, DIFFICULTIES, FACTORS, _levels())
        |  godot --script
        v
data/{enemies,towers,levels,difficulties}/*.tres, damage_table.tres, economy.tres, audio.tres
        |  loaded by DataLoader / Session
        v
Level, Enemy, Tower, WaveScheduler
```

Level maps are built from path builders (`_sine`, `_spiral`) and slots are chosen automatically (`_pick_slots`) at 40 to 78 px from the path.

## Difficulty

`DifficultyData` has six multipliers: start amino acids, body health, enemy health, enemy speed, reward, time between waves. `Level` applies the first two, `Enemy.setup` the next three, `WaveScheduler` the last. Spawns made by traits (split copies) use `"final": true` and are not scaled again.

## Statistics and damage attribution

`take_damage(amount, damage_type, source)` carries the tower id so `GameStats` can credit damage and kills. Damage over time keeps its source. This is what the playtests read.

## Determinism

The simulation has no random numbers, so a headless run at `--fixed-fps 60` gives the same result for the same inputs. Bots add their own seeded noise.

## Save file

`user://progress.cfg`: `[progress]` best health per level (a level is unlocked when the one before has a best), `[settings]` difficulty, language, last_seen_version, music_volume, sfx_volume, muted. Reset keeps the difficulty.

## Languages

`Localization` (`game/localization.gd`) lists the seven languages (English, Português, Français, Español, Italiano, 中文, 日本語) and applies one to the `TranslationServer`. The texts are in `localization/translations.csv`: the key is the English text, one column per language, and Godot imports the file into `translations.<code>.translation` (listed in `project.godot`). Code shows text with `tr("...")` (data texts as `tr(data.display_name)`), formatted strings keep their `%d` / `%s` in the key. A missing translation shows the English text. The language is chosen on the start screen (button at the top left), saved in `progress.cfg` (`[settings] language`) and defaults to the phone language on the first run. The pixel font has no Chinese or Japanese characters, so `Localization.prepare_font` gives it the system font as fallback. Scientific names of microbes stay untranslated on purpose.
