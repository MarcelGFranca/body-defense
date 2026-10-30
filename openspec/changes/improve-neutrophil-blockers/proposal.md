## Why

The neutrophils that a Bone Marrow summons are a plain circle standing still on the path: they only stop an enemy that walks into them, they do not look alive, they do not attack with an animation, enemies do not react to them and they never come back once they die. The designer asked for four improvements, done one at a time.

## What Changes

1. **Roaming and guard radius.** Neutrophils use the neutrophil sprite, keep moving around their post, have a guard radius, and walk along the path to meet an enemy that comes inside it.
2. **Attack animation** for the neutrophils (next task).
3. **Attack animation for enemies** against the neutrophils (next task).
4. **Respawn:** the Bone Marrow creates a neutrophil every 15 s (was 8 s), up to 3 at the same time, so a neutrophil that dies is replaced 15 s later. The numbers are the designer's; they have not been playtested, and with 15 s the Bone Marrow fills up more slowly than before.
5. **Regeneration:** a neutrophil recovers 2 health per second (`unit_regen`), up to its full health. Requested by the designer after the roaming task; the number was chosen by eye and has not been playtested (an enemy deals 4 per second per point of body damage while it fights the unit, so the regeneration only offsets half of one weak enemy).

Only the first one is done so far; the others are ticked in `tasks.md` as they are finished.

## Capabilities

### New Capabilities
- `blockers`: how the Bone Marrow neutrophils move, fight and come back.

## Impact

- `scripts/blocker_unit.gd`, `scripts/level.gd` (the level steps the units), `scripts/tower.gd`, new tower data fields `unit_radius` and `unit_speed` (generated data), tests.
- New screenshot tool `tools/neutrophil_screenshots`.
