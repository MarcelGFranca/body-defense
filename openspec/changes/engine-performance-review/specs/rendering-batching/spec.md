## ADDED Requirements

### Requirement: Sprites come from one atlas
All enemy and tower animations are read from `assets/sprites/atlas.png`.

#### Scenario: Atlas matches the sheets
- **WHEN** the tests run
- **THEN** every strip in the atlas equals its source sheet pixel for pixel

### Requirement: Health bars are drawn together
Health bars of all hurt enemies are drawn by one overlay above the sprites.

#### Scenario: Overlay
- **WHEN** a level is built
- **THEN** it has exactly one `EnemyBars` and the enemies draw no bar

### Requirement: Circles merge
Filled circles in the level are drawn with `CanvasShapes.disc`, not `draw_circle`.

#### Scenario: Draw calls
- **WHEN** `tools/perf_render` runs level 9 with 26 enemies
- **THEN** the frame uses fewer calls than the 331 of the version before this change
