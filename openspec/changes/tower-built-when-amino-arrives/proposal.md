## Why

A new tower appeared the moment it was chosen, while its amino acids were still flying to it.

## What Changes

- Level.build_tower takes a delivered flag
- the HUD builds with delivered false
- Tower.begin_construction hides the tower and stops it until Tower.finish_construction
- The tower pops in when the last orb arrives
- Taps on a tower under construction are ignored
- tower_built now carries the Tower

## Capabilities

### New Capabilities
- `tower-construction`

## Impact

- game/level.gd, game/tower.gd, game/hud.gd, tests/test_runner.gd, docs/game-design.md
