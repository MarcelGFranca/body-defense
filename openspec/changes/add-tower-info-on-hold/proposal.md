## Why

The player cannot see what a tower does or which enemies it is good against before paying for it, and a built tower only shows a short ability text. The designer asked that holding a tower shows its attributes and which enemies it is good against.

## What Changes

- Holding a build card (0.3 s) shows a panel with the tower's role, mobility, cost, range, damage, ability, and the enemies of the current level it is good, weak or useless against. Releasing closes the panel and does not build.
- Holding a built tower on the map shows the same panel. Releasing does not open the sell card. A quick tap still opens it.
- Out of scope: the panel on the main menu, and changing damage rules.

## Capabilities

### New Capabilities
- `tower-info`: the long-press attribute panel for build cards and built towers.

## Impact

- `game/hud.gd` (panel, hold timers), `game/level.gd` (`tower_slot_at`), tests.
- Version moves to SemVer: `0.13.0`, code `1300` (see `docs/development.md`).
