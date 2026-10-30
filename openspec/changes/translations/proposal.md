## Why

The game was English only.

## What Changes

- Seven languages: English, Português (Brasil), Français, Español, Italiano, 中文, 日本語
- Language button on the start screen
- the choice is saved, and the first run follows the phone language
- All player-facing text goes through tr() with localization/translations.csv (158 texts), including data names, abilities, level descriptions and the tutorial
- System font fallback for Chinese and Japanese
- Test that every text has a translation in every language

## Capabilities

### New Capabilities
- `localization`

## Impact

- scripts/localization.gd, scripts/session.gd, scripts/menu.gd, scripts/hud.gd, scripts/tutorial_pages.gd, localization/, project.godot, AGENTS.md, docs, tests
