## Decisions

- **One data file per level** (`data/levels/level_N.tres`), all written by `tools/generate_data.gd`. Maps are made from a few path builders (zigzag, sine, spiral). The tower slots of levels 2 to 10 are picked by a script that covers as much of the path as possible without covering the path itself; level 1 keeps its hand-placed slots.
- **Balance by wave scale.** Each level has a `scale` (enemy counts) and a `squeeze` (waves start sooner and spawn faster). `tools/balance_probe.tscn` plays every level with no towers and with a bot, and the tests require the bot to win every level and an empty field to lose.
- **Trait numbers live in data** (`EnemyData.trait_params`), the behavior lives in `Enemy` and `Level`. A level can switch a trait off (`disabled_traits`).
- **Copies and segments are enemies too.** Minions, split copies and chain segments are normal `Enemy` nodes with their own health, reward and damage, so waves finish only when every one of them is gone.
- **Bosses are not blocked** by Bone Marrow neutrophils.
- **Progress** is a small `ConfigFile` (`user://progress.cfg`): best body health per won level.
- **Menu first.** The main scene is the level menu; `main.tscn` plays the level chosen in `Session`.
