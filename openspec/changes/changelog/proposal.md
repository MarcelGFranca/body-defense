## Why

Players could not see what changed between versions.

## What Changes

- New Changelog (game/changelog.gd) with an entry for every version since 0.1, newest first, translated into the seven languages
- The changelog opens by itself the first time the game starts after an update
- Settings has a WHAT'S NEW button that opens it at any time
- Session remembers the last version seen (progress.cfg, [settings] last_seen_version)
- a fresh install does not show it
- A test fails when the current version has no changelog entry

## Capabilities

### New Capabilities
- `menu`

## Impact

- game/changelog.gd, game/session.gd, game/menu.gd, localization/translations.csv, docs, tests
