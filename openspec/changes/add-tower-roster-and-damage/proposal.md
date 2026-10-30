## Why

Enemies and the economy are specified (`add-enemy-roster-and-economy`), but nothing yet says what the player builds or how damage works. Damage is the center of the game: the body-defense theme gives a natural rock-paper-scissors (chemical hits bacteria, antiviral hits viruses, armor blocks physical blows) and the design wants slowing towers and towers that create other beings, such as antibodies. The first values below come from public reference games (Plants vs. Zombies, Kingdom Rush, Bloons TD 6) and are meant as a starting point for playtesting, not final balance.

## What Changes

- Define the roster of 10 towers (defender cells and organs), each with a damage type, role, cost, base numbers and mobility.
- Define how the Macrophage is fixed while the T and B lymphocytes are mobile. How a lymphocyte moves (on its own inside a zone, or dragged by the player) is deliberately left open.
- Define five damage types (physical, thermal, chemical, antiviral, immunological), the multipliers against viruses and bacteria, and the immunity of bacteria to antiviral damage.
- Define percentage armor (physical only, capped 0 to 100%), and armor-ignoring damage.
- Define slowing and rooting rules: no stacking, the strongest effect wins, bosses get half the effect, and slow-immune enemies are unaffected.
- Define damage over time (thermal) that does not stack.
- Make the Mucus Cell throw mucus at the first enemy in range, leaving a puddle that slows enemies for a few seconds and then disappears.
- Give the Interferon a 25% slow that only affects viruses, and a mist that keeps pulsing across its area.
- Give the three prototype towers an idle animation and an attack animation (8 frames each).
- Mark which three towers belong to the first prototype: Macrophage, Mucus Cell and Interferon.
- Out of scope: tower behavior code, targeting, upgrade trees, maps, waves, and final balance.

## Capabilities

### New Capabilities
- `tower-roster`: the 10 towers, their data, costs and mobility, and the prototype subset.
- `damage-system`: damage types, multipliers, armor, slows, roots and damage over time.

### Modified Capabilities
<!-- None: the enemy roster and economy specs are still pending in add-enemy-roster-and-economy. -->

## Impact

- New Godot resources: `TowerData` and a damage multiplier table, plus 10 files in `data/towers/`.
- Depends on `add-enemy-roster-and-economy` for enemy ids, armor and traits, and for the amino acid costs.
- Art and animations exist for the three prototype towers; the other seven towers still need their own art change.
- No new external dependencies.
