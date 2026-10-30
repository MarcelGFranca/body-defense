## Decisions

- **The unit has a home and a radius, both on the path.** `home_offset` is where the Bone Marrow put it; the guard radius is measured from there, in map units, around the home point. A unit cannot be pulled away from its post by a far enemy.
- **It walks along the path, not across the map.** To meet an enemy it moves its path offset towards `enemy.progress + 8`, at `unit_speed` (80 map units per second, faster than the enemies), so it ends up just ahead of the enemy, which is where `blocks()` expects it. Bosses are ignored because they push through.
- **Idle movement is a slow drift** of +-7 along the path (sine, a different phase for each unit) so a waiting unit never looks frozen, plus the idle animation of the neutrophil sprite.
- **The level steps the units** (`Level.step`), like towers and enemies, so tests and the fixed-fps simulation stay deterministic.
- **The guard radius is drawn as a faint ring** around the post, like the aura of the area towers.
- **Radius (60) and speed (80) are data** (`unit_radius`, `unit_speed` of the Bone Marrow); the numbers were chosen by eye, not playtested, and the blocking rules, health and damage are unchanged.
- **Size.** The neutrophil sprite is drawn at 0.425 of its size (half of the first version, 0.85) so a group of three does not hide the path; the health bar shrinks with it. Only the picture changes: the blocking reach (14) is unchanged.
- **Seen above the enemy.** Units are drawn with `z_index = 1`, above the enemies: at half size and 8 units ahead the unit was hidden behind the enemy sprite (32 px) and its attack could not be seen. It now stops 12 units ahead (blocking still works up to 14).
- **One animation per hit.** The unit plays `attack` when its hit lands (every second), faces the enemy and goes back to `idle` when the animation ends.
