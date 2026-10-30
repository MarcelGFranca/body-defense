## Why

On a phone the level list did not scroll when the finger started on a card: the card buttons swallowed the touch (reproduced on the emulator with an adb swipe).

## What Changes

- Menu scrolls the level list by hand: a drag past 16 px scrolls it and cancels the tap on the card under the finger
- A plain tap still opens the level

## Capabilities

### New Capabilities
- `menu`

## Impact

- scripts/menu.gd, tests
