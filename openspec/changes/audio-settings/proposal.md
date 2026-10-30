## Why

There was no way to lower the volume or mute the game.

## What Changes

- Settings page gets a sound section: mute switch, music volume bar and effects volume bar
- GameAudio scales the data volumes by the player settings and mutes the master bus
- Settings are saved in progress.cfg with the difficulty

## Capabilities

### New Capabilities
- `menu`

## Impact

- scripts/game_audio.gd, scripts/session.gd, scripts/menu.gd, scripts/volume_bar.gd, docs/architecture.md, tests
