## Why

Long tower names (in Portuguese, Spanish, French...) broke out of the build cards.

## What Changes

- The name on a build card shrinks (18 down to 10 px) until it fits the card, and is clipped as a last resort
- A test checks every tower name in every language

## Capabilities

### New Capabilities
- `build-card-names`

## Impact

- game/hud.gd, tests/test_runner.gd
