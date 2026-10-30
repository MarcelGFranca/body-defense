## Purpose

Defines the fixed roster of 13 enemies of the tower defense (10 regular viruses and bacteria plus 3 bosses), the attributes every enemy has and the special trait of each one, so that waves, art and balance all use the same list.

## ADDED Requirements

### Requirement: Roster of 13 enemies
The game SHALL have exactly 13 enemies: 10 regular enemies (5 viruses and 5 bacteria) and 3 bosses. Each enemy SHALL have a unique identifier, a display name and a type (virus or bacterium). A boss also has a type: it is a virus or a bacterium like the others.

Regular viruses: `rhinovirus`, `influenza`, `sars-cov-2`, `herpes-simplex`, `hpv`.

Regular bacteria: `e-coli`, `streptococcus-pyogenes`, `staphylococcus-aureus`, `helicobacter-pylori`, `clostridioides-difficile`.

Bosses: `hiv` (virus), `mycobacterium-tuberculosis` (bacterium), `neisseria-meningitidis` (bacterium).

#### Scenario: Roster count
- **WHEN** the game loads all enemies
- **THEN** there are 13 enemies: 5 regular viruses, 5 regular bacteria and 3 bosses

#### Scenario: Unique identifiers
- **WHEN** the game loads all enemies
- **THEN** no identifier is repeated

### Requirement: Mandatory attributes
Every enemy SHALL define health, movement speed, the damage dealt to the body when it reaches the end of the path, and the amino acid reward given when it is defeated (`amino_acid_reward`), all as positive numbers.

#### Scenario: Complete enemy
- **WHEN** an enemy from the roster is loaded
- **THEN** health, speed, damage to the body and amino acid reward are defined and greater than zero

#### Scenario: Incomplete enemy is rejected
- **WHEN** an enemy file does not define a mandatory attribute
- **THEN** roster validation fails and names the enemy and the missing attribute

### Requirement: Gameplay role and trait
Every enemy SHALL have a gameplay role (for example swarm, fast, resistant, boss) and a special trait that sets it apart from the others, as given in the roster table.

| Enemy | Role | Trait |
|---|---|---|
| `rhinovirus` | swarm | appears in large groups, very low health |
| `influenza` | fast | high speed, low health |
| `sars-cov-2` | contagious | releases smaller viruses when defeated |
| `herpes-simplex` | stealthy | goes dormant and is immune to attacks for a few moments |
| `hpv` | resistant | shell that reduces damage taken |
| `e-coli` | basic | default enemy with medium health and speed |
| `streptococcus-pyogenes` | chained | moves as a chain of segments that die separately |
| `staphylococcus-aureus` | resistant | gains resistance to one damage type along the path |
| `helicobacter-pylori` | slow-immune | unaffected by slowing effects |
| `clostridioides-difficile` | spore | comes back once after being defeated, with low health |
| `hiv` | boss | very high health, disables nearby towers in an aura, and affects lymphocytes longer |
| `mycobacterium-tuberculosis` | boss | very high health, very low speed, heavy armor |
| `neisseria-meningitidis` | boss | high health, splits into two smaller copies when half of its health is gone |

#### Scenario: Role and trait present
- **WHEN** an enemy from the roster is loaded
- **THEN** it has a role and a trait matching the table

### Requirement: Bosses are stronger than regular enemies
Exactly three enemies SHALL have the `boss` role. A boss SHALL have at least 5 times the average health of the regular enemies, and an `amino_acid_reward` of at least 5 times the average reward of the regular enemies.

#### Scenario: Boss count
- **WHEN** the game loads all enemies
- **THEN** exactly 3 enemies have the `boss` role

#### Scenario: Boss strength
- **WHEN** roster validation compares each boss with the regular enemies
- **THEN** every boss has at least 5 times their average health and at least 5 times their average amino acid reward

### Requirement: Enemy data separate from code
Each enemy SHALL be defined in its own data file, so that an enemy's attributes can be changed without editing game logic.

#### Scenario: Attribute tweak
- **WHEN** the health value of an enemy is changed in its data file
- **THEN** the game uses the new value with no code change

### Requirement: Placeholder art
Until final art exists, every enemy SHALL have a placeholder image that tells viruses and bacteria apart.

#### Scenario: Enemy without final art
- **WHEN** an enemy is displayed and has no final art
- **THEN** the game shows the placeholder image matching its type
