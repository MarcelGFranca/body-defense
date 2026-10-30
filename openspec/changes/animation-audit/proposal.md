## Why

Review of every tower and enemy animation.

## What Changes

- Audit result: all 10 towers have idle and attack (T lymphocyte also charge) and every behaviour now plays attack
- all 13 enemies have walk, attack, death and three hit animations
- Gap found: thermal, chemical and immunological hits reused the physical hit animation with no visible difference, so they now flash their colour on the sprite (orange, green, lilac)
- Known: the immune_antiviral animation named in code does not exist in the art and is skipped without effect

## Capabilities

### New Capabilities
- `animations`

## Impact

- scripts/enemy.gd, docs/game-design.md, tests
