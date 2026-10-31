## Why

The start screen was a plain list of levels. The designer wants a living start page: the tower and an enemy facing each other, hopping, with four buttons below.

## What Changes

- The start page shows the title, the macrophage (left) and the rhinovirus (right, facing left) in a band covering about half the screen, hopping and playing their sprite animations slowly, with VS between them at the same distance from both
- The title is static text with a separate white copy that carries a light band, a star and the chime every 10 seconds (first after 1.5 s)
- Four buttons: NEW GAME (opens the list of levels, with BACK), CONTINUE (starts the next level to play, disabled until a level is won), HOW TO PLAY and SETTINGS
- Add NEW GAME and CONTINUE to the translations
- title_shine.gdshader

## Capabilities

### New Capabilities
- `start-page`

## Impact

- game/menu.gd, assets/shaders/title_shine.gdshader, localization/translations.csv, tests/test_runner.gd, docs
