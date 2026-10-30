## Decisions

- **The tendrils follow the status, not a timer of their own.** A hold lasts while `enemy.status.is_rooted()`, so bosses (rooted for half the time), a dead enemy or one that left the map are handled without extra rules.
- **A child node `RootTendrils` draws them above everything** (`z_index = 2`): the enemy sprite would otherwise hide the curls. Only towers with the `root_aura` behaviour get it.
- **Fade uses `EnemyStatus.root_remaining()`** so the tendrils end exactly when the enemy is freed.
- **The limit of 3 is data (`root_targets`)**, not a constant. Before this change the platelet rooted every ready enemy in range, so capping it makes it weaker in crowds. The designer asked for the cap; **no playtest was run**, so the effect on win rates is unmeasured and `design/balance.md` is not updated yet.
- **Furthest enemies first.** Free slots go to the enemies that are closest to the exit, like the other single-target towers.
- **No expanding ring for the platelet**: the tendrils already show the hit; the ring stays for area towers.
- **Not changed here:** the hypothalamus (`dot_aura`) has the same gap (sound, no animation). It was not requested, so it is reported to the designer instead.
