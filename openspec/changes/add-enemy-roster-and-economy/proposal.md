## Why

The game is a portrait Android tower defense themed around "the human body defending against viruses and bacteria". Enemies drive the waves, the balance and the art, and the currency they drop drives what the player can build. Before towers, maps or waves exist, we need a closed roster of 13 enemies (10 regular enemies and 3 bosses) based on real, common pathogens, and the economy that rewards defeating them. The two are coupled by one field, `amino_acid_reward`, so they are specified and built together.

The currency follows the biology: when a pathogen dies, the body breaks its proteins down into amino acids and reuses them to build new proteins (antibodies, enzymes, cell parts), which is what towers are. A second, energy-based currency (ATP) is planned for special abilities and is written into the spec now so later design does not contradict it.

## What Changes

- Define the roster of 13 enemies: 10 regular enemies (5 viruses and 5 common bacteria) and 3 bosses (HIV, tuberculosis and meningitis), each with a name, type, gameplay role and a unique trait. Bosses are much stronger than regular enemies.
- Define the attributes every enemy must have (health, speed, damage to the body, amino acid reward) as data, without final balance values.
- Generate the enemy data files in the Godot project, one per enemy, for later use by waves and art.
- Create the base Godot project (portrait, 16-bit pixelated rendering), only as much as needed to hold those files.
- Define **amino acids** (`amino_acids`) as the primary currency: dropped by defeated enemies, collected automatically, spent to build and upgrade towers, partially refunded when a tower is sold.
- Specify **ATP** (`atp`) as a secondary currency for special abilities. It is **deferred**: specified here, but not implemented, not shown in the UI and not part of the prototype.
- Out of scope: towers (defender cells), vein and artery maps, waves, final sprites, final balance, tower prices, the ATP abilities themselves, and any real-money purchases.

## Capabilities

### New Capabilities
- `enemy-roster`: the 13 enemies (5 regular viruses, 5 regular bacteria, 3 bosses), their mandatory attributes and the special trait of each one.
- `economy`: the amino acid currency (earning, collecting, spending, refunding) and the deferred ATP currency.

### Modified Capabilities
<!-- None: the project has no specs yet. -->

## Impact

- New Godot 4.7 project at the repository root (`project.godot`, portrait orientation).
- New data files in `data/enemies/` (one per enemy) and the enemy resource definition.
- New economy logic: a balance holder, amino acid drops and a HUD counter, plus a pixel-art amino acid orb sprite in the same style as the Rhinovirus.
- No new external dependencies. Enemy sprites stay as placeholders until a dedicated art change.
