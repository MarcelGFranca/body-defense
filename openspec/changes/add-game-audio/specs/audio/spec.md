## Purpose

Defines the sound of the tower defense: effects for enemies and towers, a blocked-attack sound, background music for each level, and the limits that keep many sounds at once from becoming noise.

## ADDED Requirements

### Requirement: Enemy sounds
Every enemy SHALL have three sounds defined in its data: a hit sound, an attack sound and a death sound. The hit sound SHALL play each time the enemy takes damage and survives; a blow that kills the enemy plays the death sound instead. The attack sound SHALL play when the enemy attacks the body at the end of the path. The death sound SHALL play when the enemy dies. Each enemy SHALL have its own set, so that enemies can be told apart by ear, and bosses SHALL sound deeper and last longer than regular enemies.

#### Scenario: Enemy is hit
- **WHEN** an attack deals damage to an enemy
- **THEN** the hit sound of that enemy plays

#### Scenario: Enemy attacks the body
- **WHEN** an enemy reaches the end of the path and attacks the body
- **THEN** the attack sound of that enemy plays

#### Scenario: Enemy dies
- **WHEN** an enemy is defeated
- **THEN** the death sound of that enemy plays, and its hit sound does not

#### Scenario: Every enemy has sounds
- **WHEN** the enemy data is validated
- **THEN** each of the 13 enemies has a hit, an attack and a death sound, and every sound file exists

### Requirement: Blocked attacks
When an attack does no damage because the enemy is immune to its damage type, a short blocked sound SHALL play instead of the enemy's hit sound.

#### Scenario: Immune enemy
- **WHEN** an antiviral attack hits a bacterium
- **THEN** the blocked sound plays and the bacterium's hit sound does not

### Requirement: Tower sounds
Every tower SHALL have an attack sound defined in its data. The sound SHALL play each time the tower attacks: on each hit of a single-target tower, on each pulse of an area tower, and on each throw of the Mucus Cell. Each tower SHALL have its own sound.

#### Scenario: Tower attacks
- **WHEN** a Macrophage hits an enemy
- **THEN** the attack sound of the Macrophage plays

#### Scenario: Mucus is thrown
- **WHEN** a Mucus Cell throws mucus
- **THEN** the attack sound of the Mucus Cell plays

#### Scenario: Every tower has a sound
- **WHEN** the tower data is validated
- **THEN** each of the 10 towers has an attack sound, and every sound file exists

### Requirement: Level music
Every level SHALL have a simple background music defined in its data. The music SHALL start when the level starts, SHALL loop without a gap, SHALL fade out when the level is won or lost, and SHALL keep playing while the game is paused.

#### Scenario: Music starts with the level
- **WHEN** level 1 starts
- **THEN** its music starts playing

#### Scenario: Music loops
- **WHEN** the music reaches its end
- **THEN** it starts again from the beginning without a gap

#### Scenario: Music fades out at the end
- **WHEN** the level is won or lost
- **THEN** the music fades out

#### Scenario: Music while paused
- **WHEN** the game is paused
- **THEN** the music keeps playing

### Requirement: Limits on simultaneous sounds
The game SHALL play at most 8 sound effects at the same time. The same sound SHALL NOT be restarted again within 60 ms of its last start. Sounds that are over the limit SHALL be skipped.

#### Scenario: Many hits at once
- **WHEN** fifty hits with the same sound are requested in the same frame
- **THEN** the sound starts only once

#### Scenario: Voice limit
- **WHEN** more than 8 different sounds are requested at the same time
- **THEN** only 8 are playing and the rest are skipped

### Requirement: Volumes and sound data separate from code
The volume of effects and of music SHALL be defined in data, and the sound and music files of enemies, towers and levels SHALL be referenced from their data files, so that they can be changed without editing game logic. The music SHALL be quieter than the effects by default.

#### Scenario: Volume tweak
- **WHEN** the music volume is changed in the audio data
- **THEN** the music plays at the new volume with no code change
