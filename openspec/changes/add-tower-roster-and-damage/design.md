## Context

The Godot project and the enemy data come from `add-enemy-roster-and-economy`, which is still pending. This change adds the tower data and the damage rules; see `proposal.md` for the motivation and `specs/tower-roster/spec.md` and `specs/damage-system/spec.md` for the requirements. The starting numbers come from public reference games and are provisional:

- Plants vs. Zombies: a basic shooter does about 13 damage per second against a 200 health enemy.
- Kingdom Rush: percentage armor reduces only physical damage and is capped 0 to 100%; some attacks ignore armor.
- Bloons TD 6: slows of 40 to 60%, bosses slowed about half as much, freezes of 1.2 to 1.75 s.
- Element TD: roughly double damage on a weak point and half on a resistance. This change uses 1.5 and 0.5.

## Goals / Non-Goals

**Goals:**
- All tower and damage numbers live in data, so playtests can tune them without code edits.
- One function that turns "attack + target" into final damage, so every tower uses the same rules.
- A clear order of rules, so results are predictable and testable.

**Non-Goals:**
- Tower behavior: targeting, firing, summoning and movement code come in later changes.
- How lymphocytes are controlled (own movement inside a zone or dragging).
- Upgrade trees and final balance.
- Tower art and animations.

## Decisions

- **`TowerData` resources, one file per tower in `data/towers/<id>.tres`.** Same approach as the enemy files, so both rosters are validated the same way.
- **A `DamageTable` resource for multipliers, with per-enemy overrides on `EnemyData`.** Alternative: hard-code the table. A resource keeps the numbers in data, and overrides cover cases like the spore.
- **One `DamageCalculator.resolve(attack, target)` function.** Order: (1) type multiplier, (2) armor if physical and not immunological, (3) mark bonus, (4) round down, minimum 0. Alternative: let each tower compute damage. A single function guarantees the same rules everywhere and is easy to test headlessly.
- **Armor only reduces physical damage.** Alternative: armor against all types. Keeping it physical-only makes chemical and antiviral towers useful against armored enemies, which supports the "mix tower types" design.
- **Slows and roots go through one status component on the enemy, not on the tower.** It keeps the strongest slow, applies the boss and slow-immune rules, and tracks root cooldowns per tower. Alternative: each tower changes enemy speed directly. That would make no-stacking rules fragile.
- **Marks and slows use "refresh, don't stack".** One rule for marks, slows and damage over time keeps the effects easy to read for the player.
- **Rounding down, with fractional damage not carried over.** Matches the Kingdom Rush formula. Because tiny damage can round to 0, damage values should stay well above 1 in the data.
- **A slow carried by a damaging tower respects its damage type.** The Interferon checks the damage factor before slowing, so bacteria, which are immune to antiviral damage, are not slowed either. Alternative: slow everything. Respecting the type keeps one rule for "immune" and makes the Interferon a clear virus counter.
- **Mucus is two small objects, a flying `MucusGlob` and a `MucusPuddle` on the ground, both stepped by the level.** The puddle applies the normal slow to anything inside it every frame, so all slow rules (strongest wins, boss half, slow-immune) stay in the enemy status component. Alternative: a slow area attached to the tower. Puddles make placement and timing matter, as the designer asked: the mucus lands where the first enemy is and stays behind while the queue walks through it.
- **Tower sprites are sheets loaded at runtime (`TowerSprites`), like the enemies; the Interferon mist is drawn in code.** A mist drawn from soft circles that expand and fade scales with the tower's range and needs no frames. Towers without sheets fall back to a still image.
- **Seven towers are data-only in the prototype.** They exist so tests can cover the full table, but the prototype build menu lists only three.

## Risks / Trade-offs

- [Starting numbers are borrowed from other games] → All provisional and in data; tune during prototype playtests.
- [Marks, summons and the Platelet root have no reference numbers] → They only matter after the prototype, and are marked as guesses in the spec's own numbers.
- [Rounding down makes weak ticks vanish, for example 1 damage at 0.5] → Keep base values at 3 or more; the validation script warns when a base value would round to 0 against any multiplier.
- [0 as immunity could look like a bug to players] → The game shows immune feedback (the shield animation), so the player understands the attack was blocked.

## Open Questions

- How lymphocytes move: automatically inside a patrol zone, or dragged by the player. It does not change these specs, the data files or the task list; the later behavior change will decide it.
