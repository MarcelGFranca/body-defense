## Why

Phones should run the game cooler, and the minimum Android version was unknown.

## What Changes

- Checked the minimum Android: 7.0 (API 24), arm64 only, GLES 3
- Cap the frame rate at 60
- Towers redraw only while something animates
- HUD scroll bar redraws at 10 Hz
- Document requirements and performance rules in docs/development.md

## Capabilities

### New Capabilities
- `performance`

## Impact

- project.godot, scripts/tower.gd, scripts/hud.gd, docs/development.md
