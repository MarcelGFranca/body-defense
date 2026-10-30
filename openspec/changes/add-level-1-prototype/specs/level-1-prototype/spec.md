## Purpose

Defines the first playable level (nose and throat): its map, tower slots, available enemies and towers, starting resources and wave list, so the full gameplay loop can be tested on a phone.

## ADDED Requirements

### Requirement: Level name
Level 1 SHALL be named "Garganta" (throat). The name SHALL be defined in the level data.

#### Scenario: Name in the HUD
- **WHEN** level 1 is playing
- **THEN** the top bar shows "GARGANTA"

### Requirement: Portrait map with one path
Level 1 SHALL be played in portrait orientation. It SHALL have one entrance at the top, one path that winds down the screen in a zigzag, and one exit at the bottom that leads to the lungs. Enemies SHALL always follow the path from the entrance to the exit.

#### Scenario: Enemy follows the path
- **WHEN** an enemy spawns
- **THEN** it appears at the entrance and moves along the path toward the exit

#### Scenario: Enemy reaches the exit
- **WHEN** an enemy reaches the exit
- **THEN** it is removed and the body loses the damage defined for that enemy

### Requirement: Map larger than the screen
The level 1 map SHALL be larger than the visible area, so only part of it is on screen at a time and the path runs past the edges of the screen. The map is 360 by 820 map units, while about 360 by 484 map units are visible between the HUD bars. The view SHALL start at the entrance of the path.

#### Scenario: Only part of the map is visible
- **WHEN** level 1 starts
- **THEN** the view shows the entrance, and the end of the path is outside the screen until the player scrolls

#### Scenario: Path inside the map
- **WHEN** level 1 loads
- **THEN** every point of the path and every slot is inside the map

### Requirement: Six tower slots
Level 1 SHALL have exactly 6 tower slots, all outside the path. A slot SHALL hold at most one tower.

#### Scenario: Slot count
- **WHEN** level 1 loads
- **THEN** there are 6 empty slots

#### Scenario: Occupied slot
- **WHEN** a slot already has a tower
- **THEN** no other tower can be built on it until the first one is sold

### Requirement: Available enemies and towers
Level 1 SHALL use only the enemies `rhinovirus`, `influenza` and `streptococcus-pyogenes` (with its chain trait turned off), and SHALL offer only the towers `macrophage`, `mucus-cell` and `interferon`.

#### Scenario: Enemies in the level
- **WHEN** every wave of level 1 has been spawned
- **THEN** only the three allowed enemy types have appeared

#### Scenario: Towers in the level
- **WHEN** the build menu is shown in level 1
- **THEN** it lists only the macrophage, the mucus cell and the interferon

### Requirement: Starting resources
Level 1 SHALL start with 150 amino acids and a body health of 20. These values SHALL be defined in the level's data.

#### Scenario: Level start
- **WHEN** level 1 starts
- **THEN** the amino acid balance is 150 and the body health is 20

### Requirement: Level 1 waves
Level 1 SHALL have 3 waves. All numbers are provisional.

| Wave | Starts at | Enemies | Spawn interval |
|---|---|---|---|
| 1 | 5 s | `rhinovirus` x8 | 1.2 s |
| 2 | 50 s | `rhinovirus` x10, `influenza` x4 | 1.0 s |
| 3 | 150 s | `influenza` x6, `streptococcus-pyogenes` x4 | 0.9 s |

#### Scenario: Wave contents
- **WHEN** wave 2 runs
- **THEN** 10 Rhinoviruses and 4 Influenza spawn, one at a time, 1.0 s apart

### Requirement: Level data separate from code
The map layout, slot positions, starting resources and waves SHALL be defined in data files, so they can be tuned without editing game logic.

#### Scenario: Wave time tweak
- **WHEN** the start time of wave 2 is changed in the level data
- **THEN** the game starts wave 2 at the new time with no code change
