## Purpose

Defines how damage is calculated in the tower defense: damage types, multipliers against viruses and bacteria, percentage armor, slows, roots and damage over time.

## ADDED Requirements

### Requirement: Damage types
The game SHALL have five damage types: `physical`, `thermal`, `chemical`, `antiviral` and `immunological`. Every attack that deals damage SHALL have exactly one damage type.

#### Scenario: Typed damage
- **WHEN** a tower or unit deals damage
- **THEN** the damage has one of the five types

### Requirement: Type multipliers
Damage SHALL be multiplied by a factor that depends on the damage type and the type of the target (virus or bacterium), as follows. A factor of 0 means the target is immune.

| Damage type | vs virus | vs bacterium |
|---|---|---|
| physical | 1.0 | 1.0 |
| thermal | 1.0 | 1.0 |
| chemical | 0.5 | 1.5 |
| antiviral | 1.5 | 0 |
| immunological | 1.0 | 1.0 |

Individual enemies MAY override a factor: `clostridioides-difficile` (spore) SHALL take 0.5 times thermal and chemical damage.

#### Scenario: Weak point
- **WHEN** an antiviral attack of 6 damage hits a virus with no armor
- **THEN** the virus takes 9 damage

#### Scenario: Immunity
- **WHEN** an antiviral attack hits a bacterium
- **THEN** the bacterium takes 0 damage and the game shows the immune feedback

#### Scenario: Resistance
- **WHEN** a chemical attack of 6 damage hits a virus
- **THEN** the virus takes 3 damage

#### Scenario: Enemy override
- **WHEN** a thermal attack of 4 damage hits a `clostridioides-difficile`
- **THEN** it takes 2 damage

### Requirement: Percentage armor
An enemy MAY have armor as a percentage from 0 to 100. Armor SHALL reduce only `physical` damage, by that percentage. The final value SHALL be rounded down and SHALL never be negative. `immunological` damage SHALL ignore armor.

Armor values: `hpv` 30%, `mycobacterium-tuberculosis` 40%. Other enemies have 0% unless their trait says otherwise.

#### Scenario: Armor reduces physical damage
- **WHEN** a physical attack of 12 damage hits an `hpv` (30% armor)
- **THEN** it takes 8 damage

#### Scenario: Armor does not affect other types
- **WHEN** a chemical attack hits an armored bacterium
- **THEN** the armor does not reduce the damage

#### Scenario: Immunological damage ignores armor
- **WHEN** an immunological attack of 30 damage hits a `mycobacterium-tuberculosis`
- **THEN** it takes 30 damage

### Requirement: Slows
A slow SHALL reduce an enemy's movement speed by a percentage while the enemy is inside the slowing area (for example a mucus puddle on the ground or an Interferon area), and for 1.5 s after it leaves. Slows SHALL NOT stack: when several apply, only the strongest SHALL count. Enemies with the `boss` role SHALL receive half of the slow percentage. Enemies with the `slow-immune` role SHALL NOT be slowed.

#### Scenario: Mucus slow
- **WHEN** a normal enemy walks onto a mucus puddle
- **THEN** its speed is reduced by 40%, and returns to normal 1.5 s after it leaves the puddle or the puddle disappears

#### Scenario: No stacking
- **WHEN** an enemy is on two mucus puddles at once
- **THEN** its speed is still reduced by only 40%

#### Scenario: Boss
- **WHEN** a `mycobacterium-tuberculosis` walks onto a mucus puddle
- **THEN** its speed is reduced by 20%

#### Scenario: Slow-immune enemy
- **WHEN** a `helicobacter-pylori` walks onto a mucus puddle
- **THEN** its speed does not change

### Requirement: Slows carried by damaging towers
A slow that comes from a tower that also deals damage SHALL only affect targets that its damage type can affect, that is, targets whose factor for that damage type is above 0. The Interferon slows viruses in its area by 25% and SHALL NOT slow bacteria. All slow rules above still apply, including that only the strongest slow counts.

#### Scenario: Interferon slows a virus
- **WHEN** a virus is inside an Interferon area
- **THEN** its speed is reduced by 25%

#### Scenario: Interferon does not slow a bacterium
- **WHEN** a bacterium is inside an Interferon area
- **THEN** its speed does not change

#### Scenario: Strongest slow wins
- **WHEN** a virus is inside an Interferon area and on a mucus puddle at the same time
- **THEN** its speed is reduced by 40%, not 65%

### Requirement: Roots
A root SHALL stop an enemy for its duration. After a root ends, the same enemy SHALL NOT be rooted again until the tower's cooldown for that enemy ends. Enemies with the `boss` role SHALL be rooted for half of the duration. Enemies with the `slow-immune` role SHALL NOT be rooted.

#### Scenario: Platelet root
- **WHEN** a Platelet roots a normal enemy
- **THEN** the enemy stops for 1.2 s and cannot be rooted by that Platelet again for 3 s after that

#### Scenario: Boss
- **WHEN** a Platelet roots a `mycobacterium-tuberculosis`
- **THEN** it stops for 0.6 s

### Requirement: Damage over time
Damage over time SHALL deal its damage in one-second ticks for its duration. It SHALL NOT stack: while an enemy is already affected, a new application only refreshes the duration. Each tick SHALL use the damage type multipliers and armor rules above.

#### Scenario: Fever
- **WHEN** a Hypothalamus affects an enemy
- **THEN** the enemy takes 3 damage per second for 4 s, and a second application during that time only restarts the 4 s

#### Scenario: Spore resists fever
- **WHEN** a Hypothalamus affects a `clostridioides-difficile`
- **THEN** it takes 1 damage per tick, because its thermal factor is 0.5 and the result is rounded down

### Requirement: Damage data separate from code
The multiplier table, armor values and slow, root and damage-over-time numbers SHALL be defined in data files, not in game logic.

#### Scenario: Multiplier tweak
- **WHEN** the chemical factor against bacteria is changed in the data file
- **THEN** the game uses the new factor with no code change
