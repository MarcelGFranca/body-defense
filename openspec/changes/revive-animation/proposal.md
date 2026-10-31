## Why

C. difficile came back with more health in the middle of the path and nothing showed that it had died.

## What Changes

- Enemy._revive plays the death animation, holds the enemy still, then plays it backwards with a green glow
- While reviving the enemy cannot be hurt, targeted or moved
- Timed by step() so bots and tests work

## Capabilities

### New Capabilities
- `revive-animation`

## Impact

- game/enemy.gd, game/level.gd, tests/test_runner.gd, docs/game-design.md
