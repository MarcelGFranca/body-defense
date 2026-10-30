## Why

The amino acid counter rose the moment an enemy died, before the orb animation reached the top bar.

## What Changes

- Hud.shown_amino_acids subtracts amino acids still in flight from the balance
- Each orb carries a share of the reward and adds it to the bar when it arrives

## Capabilities

### New Capabilities
- `hud`

## Impact

- scripts/hud.gd, docs/game-design.md, tests
