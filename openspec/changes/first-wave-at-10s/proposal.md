## Why

The first wave came at 5 s on level 1 and at 20 s on the others.

## What Changes

- The first wave of every level starts at 10 s (FIRST_WAVE_START in tools/generate_data.gd)
- The later waves keep their times
- Regenerate data/levels

## Capabilities

### New Capabilities
- `wave-schedule`

## Impact

- tools/generate_data.gd, data/levels, docs/game-design.md, playtests/README.md, playtests/first_wave_10s
