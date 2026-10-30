## Why

On a Samsung S24 FE the launcher mask cut into the icon text: the adaptive foreground had pixels 165 px from the centre while Android only guarantees 144 px (a 288 px circle of the 432 px layer).

## What Changes

- tools/generate_icon.py draws the original icon design (macrophage, bolt, virus, BODY DEFENSE) inside 142 px of the centre (icon 15% bigger after review)
- Same picture, bigger, for the legacy 512 px icon
- design/icon-options/safe_zone_preview.png shows it under circle and rounded-square masks
- docs/development.md lists the screen, panel and icon sizes
- Test that the foreground stays inside the safe zone

## Capabilities

### New Capabilities
- `icon`

## Impact

- tools/generate_icon.py, assets/icon, docs/development.md, tests
