## Why

A B lymphocyte marks up to 4 enemies so they take 35% more damage for 5 s, but nothing on screen tells the player which enemies are marked. The designer asked that an enemy hit by the B lymphocyte take on the lymphocyte's color to show it has the status.

## What Changes

- A marked enemy is dyed lilac, the color of the B lymphocyte, for as long as the mark lasts; the dye eases out in the last 0.6 s.
- The color is part of the B lymphocyte's data (`mark_color`), so other marking towers could use their own.
- The dye keeps the shading and details of the sprite (a shader mixes the color with the sprite instead of multiplying it).
- Damage, mark bonus, duration and number of targets are unchanged.

## Capabilities

### Modified Capabilities
- `tower-feedback`: marked enemies are visible.

## Impact

- New `assets/shaders/mark_tint.gdshader`, `game/enemy.gd`, `game/enemy_status.gd` (`mark_amount`, `mark_color`), `TowerData.mark_color` (generated data), tests.
- New screenshot tool `tools/blymphocyte_screenshots`.
