## Why

On a tall phone the game is centred with black bars above and below, equal in size, but the HUD top bar added the camera cutout height on top of that, so the space above the title was much bigger than the space below the bottom bar.

## What Changes

- Hud._safe_top counts only the part of the camera cutout that reaches into the game area, after subtracting the black bar (the window is scaled to fit 720 x 1280 and centred)

## Capabilities

### New Capabilities
- `hud`

## Impact

- game/hud.gd, docs/development.md
