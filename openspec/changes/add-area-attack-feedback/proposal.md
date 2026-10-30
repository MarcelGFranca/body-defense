## Why

The lysozyme looks like it never attacks: its attack animation is a thin 1 px ring and nothing shows on the map. The designer asked that its attack be visible.

## What Changes

- The lysozyme attack animation gets thicker, longer rings and more particles.
- Every area attack (`damage_aura`) sends a coloured ring from the tower to the edge of its range in 0.6 s, coloured by damage type.
- The platelet and the neutrophil attack animations are separate tasks.

## Capabilities

### New Capabilities
- `tower-feedback`: visible feedback when a tower attacks.

## Impact

- `tools/tower_art.py` and the regenerated lysozyme sheets, `scripts/tower.gd`, tests.
