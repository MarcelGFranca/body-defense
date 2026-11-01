## Decisions

**Measure first.** Baseline before any change: `tools/perf_bench` (simulation), `tools/perf_render` (draw calls and render time on a real GPU or under xvfb), `tools/perf_load`, 200 playtest games, `tools/perf_shot` screenshots. After each step the tests, the playtest replay and the screenshots were compared with the original code.

**What batches in Godot 4.7 (Compatibility renderer), measured:** `draw_rect`, `draw_line`, `draw_multiline`, `draw_primitive` and textured rectangles of one texture merge when drawn one after the other (10 commands = 1 call, even across items). `draw_circle`, `draw_arc`, `draw_polyline` and polygons cost 1 call each. Alternating a texture and a rectangle breaks the batch.

**Atlas.** All 105 animation strips (enemies and towers) fit one 2048 x 510 texture. The packer is a build step like the sprite generators; a test fails when the atlas and the sheets differ. The lookup uses the sprite folder name, which fixes chain segments. Video memory rises by about 3 MB because the whole atlas is resident instead of the sheets used so far.

**Discs yes, rings no.** Circles became textured rectangles. Rings as many `draw_multiline` segments cut draw calls further (level 3: 131 to 41) but raised CPU time on a real GPU (1.0 to 1.4 ms) because each segment is a primitive; the native `draw_arc` won and was kept. Armour plates (48 segments per shell) in 2 batches beat 16 separate arcs (2.92 vs 3.13 ms).

**Health bars.** Rectangles batch only when nothing else is drawn between them, and a bar drawn by each enemy sat between two sprites. One overlay item draws all bars above the sprites; a bar is no longer hidden by the enemy drawn after its owner.

**Simulation.** Same order and same arithmetic (`distance_squared_to` against `radius * radius`), so results are identical. Dictionaries of dictionaries in `EnemyStatus` became two flat dictionaries.

**Size review, not applied.**
- Music is already mono 22 kHz and QOA (5:1), 15.1 MB of the APK. Vorbis would save about 20 % (about 3 MB) but needs an encoder that is not on the machine (the libsndfile wheel crashes on long files); not worth a new dependency.
- The Godot library is 25.9 MB (54 %) and the ICU data 2.8 MB (needed for Japanese and Chinese line breaking). Only a custom export template or the release template (about 4 MB smaller and faster, needs a release keystore) changes them.
- Sprites are 0.33 MB in the APK; there is nothing to gain there.

**Not done.** Burn flames still cost 6 polygon calls per burning enemy (`draw_colored_polygon` does not batch; a triangle-by-triangle version costs more script time). Strict GDScript warnings could not be listed: `--check-only` does not see the autoloads.
