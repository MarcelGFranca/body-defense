## Why

A review of the code against Godot's performance practices, with numbers from the game itself: the level drew up to 331 calls per frame, enemies were searched by building a new array with a closure for every tower every frame, every new enemy kind loaded 6 to 8 PNG files in the middle of play, and the HUD rebuilt three texts every frame. The APK is 48.5 MB; the size review found little to take out (see design.md).

## What Changes

- One sprite atlas (`assets/sprites/atlas.png`, made by `tools/pack_sprites.py`) replaces 105 sheet loads at run time
- Enemy health bars are drawn by one overlay (`EnemyBars`) instead of by each enemy
- Circles are drawn as tinted rectangles of one disc texture (`CanvasShapes.disc`) so the renderer can merge them; armour plates are drawn in two batches
- Target queries (`Level.enemies_in_range`, `Level.first_enemy_in_range`) build no closure and compare squared distances
- Slow bookkeeping, tower source keys, enemy traits and damage-over-time ticks no longer allocate every frame
- The HUD rebuilds a text only when its number changes
- Chain segments of Streptococcus use their own art (a bug: they showed the generic placeholder)
- New tools: `perf_bench`, `perf_render`, `perf_load`, `perf_shot`, `compare_shots.py`, `pack_sprites.py`, `generate_disc.py`

No rules, numbers or look change: 200 bot games replay byte for byte, screenshots differ by 0.00 % of pixels on levels 3 and 10.

## Capabilities

### New Capabilities
- `rendering-batching`
- `simulation-cost`
- `perf-tooling`

## Impact

- game/level.gd, enemy.gd, enemy_status.gd, tower.gd, mucus_puddle.gd, map_view.gd, hud.gd, blocker_unit.gd, mucus_glob.gd, tower_beam.gd, enemy_sprites.gd, tower_sprites.gd
- new game/enemy_bars.gd, canvas_shapes.gd, sprite_atlas.gd; assets/sprites/, assets/ui/disc.png
- tools/, tests/test_runner.gd, docs/
