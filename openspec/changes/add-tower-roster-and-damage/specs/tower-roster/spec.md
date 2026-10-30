## Purpose

Defines the roster of 10 defender towers of the tower defense (cells and organs of the immune system), with their damage type, role, cost, base numbers and mobility, so that levels, art and balance share one list.

## ADDED Requirements

### Requirement: Roster of 10 towers
The game SHALL have exactly 10 towers, each with a unique identifier, a display name, a role, a damage type (or none), a cost in amino acids and a mobility (`fixed` or `mobile`). All numbers in the table below are provisional starting values.

| Id | Role | Damage type | Base numbers | Cost | Mobility |
|---|---|---|---|---|---|
| `macrophage` | single-target | physical | 12 damage per second, short range | 50 | fixed |
| `neutrophil` | rapid fire | physical | 10 damage per second (4 damage every 0.4 s) | 45 | fixed |
| `mucus-cell` | slow | none | every 3 s throws mucus at the first enemy in range; the mucus stays on the ground for 6 s and slows enemies on it by 40% | 40 | fixed |
| `platelet` | root | none | roots an enemy for 1.2 s, then 3 s cooldown for that enemy | 55 | fixed |
| `hypothalamus` | damage over time | thermal | 3 damage per second for 4 s in an area | 70 | fixed |
| `lysozyme` | area | chemical | 6 base damage per second in an area | 60 | fixed |
| `interferon` | area | antiviral | 6 base damage per second in an area, and slows the viruses in it by 25% | 60 | fixed |
| `t-lymphocyte` | single-target | immunological | 30 damage every 2.0 s (15 per second), ignores armor | 90 | mobile |
| `b-lymphocyte` | summoner | antiviral | releases antibodies that stick to an enemy, deal 4 damage and mark it | 80 | mobile |
| `bone-marrow` | summoner | physical | creates a neutrophil unit every 10 s, up to 3 alive | 100 | fixed |

#### Scenario: Roster count
- **WHEN** the game loads all towers
- **THEN** there are exactly 10 towers with unique identifiers

#### Scenario: Costs are in amino acids
- **WHEN** a tower is built
- **THEN** its cost is charged in amino acids as defined by the economy

### Requirement: Tower animations and effects
Each prototype tower (`macrophage`, `mucus-cell` and `interferon`) SHALL have an idle animation that loops and an attack animation that plays once, each with 8 frames. The attack animation SHALL play every time the tower acts: on each hit of the Macrophage, on each pulse of the Interferon, and each time the Mucus Cell throws mucus. The Interferon SHALL also keep pulsing a mist across its whole area while it is built. Towers that do not have art yet SHALL be shown as a still image.

#### Scenario: Attack animation
- **WHEN** a Macrophage hits an enemy
- **THEN** its attack animation plays once and it goes back to idling

#### Scenario: Interferon mist
- **WHEN** an Interferon is built
- **THEN** a mist keeps pulsing across its area, with or without enemies in range

#### Scenario: Tower without art
- **WHEN** a tower has no animation files
- **THEN** it is shown as a still image and the game still works

### Requirement: Mucus on the ground
The Mucus Cell SHALL throw a glob of mucus at the first enemy in its range, that is, the one furthest along the path, each time its throw interval ends. The glob SHALL fly to the enemy and leave a puddle where it lands. The puddle SHALL stay on the ground for its lifetime, SHALL slow every enemy standing on it, and SHALL then disappear. The Mucus Cell SHALL NOT slow anything by itself, only through its puddles.

#### Scenario: First enemy of the queue
- **WHEN** a Mucus Cell has two enemies in range
- **THEN** it throws the mucus at the one that is further along the path

#### Scenario: Puddle on the ground
- **WHEN** the glob lands
- **THEN** a puddle stays on the ground for 6 s and slows the enemies standing on it by 40%

#### Scenario: Enemies that arrive later
- **WHEN** an enemy walks onto a puddle that is still on the ground
- **THEN** it is slowed, even if it was not the target of the throw

#### Scenario: Puddle disappears
- **WHEN** the puddle has been on the ground for 6 s
- **THEN** it disappears and no longer slows anyone

#### Scenario: Nothing in range
- **WHEN** no enemy is in range of the Mucus Cell
- **THEN** it throws nothing

### Requirement: Fixed and mobile towers
The Macrophage and every other tower marked `fixed` SHALL stay where the player places them. The `t-lymphocyte` and `b-lymphocyte` SHALL be `mobile`: they can leave their original position to reach enemies. The rule that controls their movement is not defined by this spec.

#### Scenario: Fixed tower
- **WHEN** a Macrophage is placed on a slot
- **THEN** it stays on that slot until the player sells it

#### Scenario: Mobile tower
- **WHEN** enemies are in the world and a lymphocyte is built
- **THEN** the lymphocyte is able to change position while the level is running

### Requirement: Summoned units
The `b-lymphocyte` and the `bone-marrow` SHALL create units instead of only attacking. Antibodies SHALL stick to one enemy, deal 4 damage and mark it, so that it takes 25% more damage from all sources for 5 s. Marks SHALL NOT stack. A Bone Marrow neutrophil SHALL have 25 health, SHALL block one enemy at a time and SHALL disappear when its health reaches zero. Summoned units SHALL NOT cost amino acids on their own.

#### Scenario: Marked enemy
- **WHEN** an antibody sticks to an enemy
- **THEN** that enemy takes 25% more damage for 5 s, and a second antibody only refreshes the 5 s

#### Scenario: Summon cap
- **WHEN** a Bone Marrow already has 3 neutrophils alive
- **THEN** it does not create a fourth until one is gone

### Requirement: Enemies that disable towers
When an enemy disables towers (the `hiv` trait), the disabled time SHALL be 3 s for a normal tower and 6 s for a lymphocyte.

#### Scenario: Disabling a lymphocyte
- **WHEN** an `hiv` enemy disables a `t-lymphocyte`
- **THEN** that lymphocyte cannot act for 6 s

### Requirement: Prototype subset
The first prototype SHALL offer only the `macrophage`, `mucus-cell` and `interferon` towers. The other seven towers SHALL exist as data but SHALL NOT be buildable in the prototype.

#### Scenario: Prototype build menu
- **WHEN** the prototype build menu is shown
- **THEN** it lists only the macrophage, mucus cell and interferon

### Requirement: Tower ability description
Every tower SHALL have a short ability description in its data, which the HUD shows when the player taps the tower.

#### Scenario: Description present
- **WHEN** the tower data is validated
- **THEN** every tower has a non-empty ability description

### Requirement: Tower data separate from code
Each tower SHALL be defined in its own data file, so that a tower's numbers can be changed without editing game logic.

#### Scenario: Cost tweak
- **WHEN** the cost of a tower is changed in its data file
- **THEN** the game charges the new cost with no code change
