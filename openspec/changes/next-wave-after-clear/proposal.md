## Why

Waiting for the next wave when the field is already empty wastes the player's time.

## What Changes

- WaveScheduler.shorten_wait brings the next wave forward
- When the field is empty between waves, the next wave starts in at most 5 s (Level.EMPTY_FIELD_WAIT)

## Capabilities

### New Capabilities
- `waves`

## Impact

- scripts/level.gd, scripts/wave_scheduler.gd, docs/game-design.md, tests
