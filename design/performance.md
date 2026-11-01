# Performance review (change `engine-performance-review`)

Measured on 2026-10-31, Godot 4.7.2, Compatibility renderer. "Before" is commit `cd037fa`. Rendering numbers come from an Intel UHD 620 through Mesa (a weak GPU, so differences that show here are real; a phone driver may weigh draw calls more). Nothing here was measured on a phone.

| What | Before | After | Change |
|---|---|---|---|
| Simulation, every slot full (`perf_bench`, all 10 levels) | 187.1 us/step | 148.7 and 154.1 us/step | -19 % |
| 200 bot games (`playtest`) | 148.5 s and 151.7 s | 124.4 s | -17 % |
| Result of those 200 games | | identical, byte for byte | no change |
| Load every enemy and tower sprite (`perf_load`) | 23.1 ms | 8.8 ms | -62 % |
| Frame, level 3 (3 enemies, 8 towers) | 2.05 ms, 147 draw calls | 1.90 ms, 121 calls | -7 % |
| Frame, level 9 (26 enemies, 10 towers) | 4.51 ms, 371 calls | 3.62 ms, 221 calls | -20 % |
| Frame, level 10 (16 enemies, 11 towers) | 3.73 ms, 159 calls | 3.19 ms, 151 calls | -14 % |
| Render GPU time, level 9 | 1.51 ms | 1.11 ms | -26 % |
| Video memory | 23 to 24 MB | 27 MB | +3 MB (atlas resident) |
| APK | 48 484 635 bytes | 48 637 115 bytes | +0.15 MB |
| Tests | 754 checks | 767 checks, 0 failures | +13 |

Screenshots of levels 3, 9 and 10 against the original code (`compare_shots.py`, differences above 24/255): level 3 0.000 %, level 10 0.000 %, level 9 0.181 % (the health bars, now above the neighbouring enemy). Two runs of the original code differ by 0.000 %.

## Experiments that decided the design (level 9, real GPU, wall time per frame)

| Variant | Wall | Objects | Kept |
|---|---|---|---|
| Original (circles and arcs) | 3.81 ms | 810 | |
| Rings as `draw_multiline`, discs as texture | 3.25 ms | 7 853 | no, CPU rose |
| Rings as `draw_arc`, discs as texture | 3.08 ms | 1 608 | yes |
| Rings as `draw_arc`, circles as `draw_circle` | 3.49 ms | 1 608 | no |
| Armour plates as 16 arcs | 3.13 ms | 810 | no |
| Armour plates in 2 batches | 2.92 ms | 1 608 | yes |

Draw commands that merge (10 commands, one call): rect, line, multiline, primitive, rectangles of one texture. One call each: circle, arc, polyline, polygon.

## Where the cost still is

- Map: about 4 % of the frame, 6 calls.
- Burning enemies: 6 polygon calls each (flames).
- HUD: 25 calls (Controls).
- The Godot library is 54 % of the APK and cannot be reduced without a custom template; music is 31 %, already QOA at 22 kHz mono.

## Not done

- Vorbis music (about -3 MB): no working encoder here.
- Release export (about -4 MB and faster than debug): needs a release keystore.
- Baking the map decoration into a texture: would remove its slow sway.
- Strict GDScript warnings: `--check-only` cannot resolve the autoloads, so they need the editor.

## Found on the way

Chain segments of Streptococcus pyogenes never showed their own art (`streptococcus-pyogenes-segment/`): the loader looked for `<enemy id>_animations.json` in the segment folder and fell back to the placeholder. They now use it.
