## Why

Test builds are installed over each other, and the designer cannot tell which build is running. The designer asked that the version be shown, very small, at the bottom of the start screen.

## What Changes

- The menu shows the game version ("V0.16.0") in small dim text under the Settings button.
- The version name lives in one place, `application/config/version` in `project.godot`. The Android preset leaves `version/name` empty and uses it. `version/code` stays in `export_presets.cfg`.

## Capabilities

### New Capabilities
- `menu`: what the start screen shows.

## Impact

- `game/menu.gd`, `project.godot`, `export_presets.cfg`, `docs/development.md`, tests.
