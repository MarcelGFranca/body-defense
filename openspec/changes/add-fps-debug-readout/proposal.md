## Why

The designer tests builds on a phone and needs to see how smoothly the game runs. The debug aids should only be visible after the secret tap code on the start screen.

## What Changes

- A small FPS readout ("FPS 60") at the top right of the screen, on the start screen and during a level.
- It shows only after the secret tap code (the same one that opens every level) and stays until the game is closed. `Session.debug_mode` is the switch.

## Capabilities

### New Capabilities
- `debug`: debug aids that the secret code turns on.

## Impact

- New `scripts/fps_counter.gd`, `scripts/session.gd`, `scripts/menu.gd`, `scripts/hud.gd`, tests, `docs/game-design.md`.
