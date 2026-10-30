## Purpose

Defines the three difficulty settings, what each one changes and how the player chooses it.

## ADDED Requirements

### Requirement: Three difficulties
The game SHALL offer three difficulties named Easy, Medium and Hard. Each SHALL be defined in data by six multipliers: starting amino acids, body health, enemy health, enemy speed, amino acids dropped by enemies, and wave time (start times and spawn intervals). Medium SHALL have all multipliers at 1.

#### Scenario: Easy is kinder
- **WHEN** the difficulty data is validated
- **THEN** Easy has more starting amino acids, body health and drops, weaker and slower enemies, and more time between waves than Medium

#### Scenario: Hard is harder
- **WHEN** the difficulty data is validated
- **THEN** Hard has less starting amino acids, body health and drops, stronger and faster enemies, and less time between waves than Medium

### Requirement: The setting reaches the game
A level SHALL start with its amino acids and body health multiplied by the difficulty, every enemy SHALL get its health, speed and reward multiplied, and the wave times SHALL be multiplied. Copies created when an enemy splits SHALL NOT be multiplied again.

#### Scenario: Easy level
- **WHEN** level 1 starts on Easy
- **THEN** the body has 30 health and a rhinovirus has 17 health

### Requirement: Settings page
The level menu SHALL have a Settings page where the player chooses the difficulty and can reset progress. The chosen difficulty SHALL be highlighted, SHALL be explained in one sentence, and SHALL be saved on the device. Resetting progress SHALL need a second tap and SHALL keep the difficulty.

#### Scenario: Choosing
- **WHEN** the player taps Hard in Settings and closes the game
- **THEN** the next game starts on Hard

### Requirement: Balance can be measured
The game SHALL record, for every game, the damage and kills of each tower, the enemies that got out, and how each wave went, so that recorded games can be analyzed.

#### Scenario: A kill by a tower
- **WHEN** a macrophage kills a rhinovirus
- **THEN** the game stats count one kill by the macrophage and one rhinovirus killed
