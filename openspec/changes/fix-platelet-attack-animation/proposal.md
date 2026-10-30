## Why

The platelet has an attack animation, but it never plays: the root aura roots enemies and plays the sound without telling the tower to animate. The designer reported that the platelet has no attack animation, and asked that it hold the enemy with tendrils for as long as the enemy is paralysed, after which the tendrils disappear.

## What Changes

- When the platelet roots an enemy it plays its attack animation, facing that enemy.
- One tendril grows from the platelet to each rooted enemy in 0.25 s, waves while it holds the enemy and curls around it, then fades out in the last 0.25 s of the hold and disappears.
- The hold lasts 3 s (`root` in the tower data, was 1.2 s), bosses half. The tendril and the paralysis last exactly the same time. The same enemy cannot be held again for 3 s (`root_cooldown`, unchanged), so when a tendril lets go the platelet reaches for the furthest enemy that can be held.
- The platelet's sound plays once per send, never while it only holds.
- The platelet holds up to 3 enemies at the same time (`root_targets` in the tower data), the ones furthest along the path first.
- The platelet reacts once per release, not once per rooted enemy.

## Capabilities

### Modified Capabilities
- `tower-feedback`: root attacks are visible too.

## Impact

- New `scripts/root_tendrils.gd`, new field `TowerData.root_targets` (generated data, `tools/generate_data.gd`); `scripts/tower.gd` (holds), `scripts/enemy_status.gd` (`root_remaining`), tests. No sprite or data change.
