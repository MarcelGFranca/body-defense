## Purpose

Defines the campaign: ten levels through the human body, which enemies and towers each one offers, where the bosses are, and how the player moves from one level to the next.

## ADDED Requirements

### Requirement: Ten levels in order
The game SHALL have exactly 10 levels, numbered 1 to 10, named Throat, Trachea, Lungs, Esophagus, Stomach, Intestines, Bloodstream, Liver, Spleen and Lymph Nodes. Each SHALL have its own map, colors, music, tower slots, waves, body part and description.

#### Scenario: Level data
- **WHEN** the level data is validated
- **THEN** there are 10 levels, each with at least 6 slots that do not cover the path, at least 3 waves, its own music file and a unique name

### Requirement: Bosses
Levels 3, 7 and 10 SHALL end with a boss in their last wave: Mycobacterium tuberculosis, Neisseria meningitidis and HIV. No other level SHALL have a boss.

#### Scenario: Boss levels
- **WHEN** the level data is validated
- **THEN** exactly levels 3, 7 and 10 name a boss, and each boss is in the last wave of its level

### Requirement: Towers are unlocked little by little
Level 1 SHALL offer Macrophage, Mucus Cell and Interferon. Every later level SHALL offer at least the towers of the level before, and level 10 SHALL offer all ten.

#### Scenario: Towers never go away
- **WHEN** the level data is validated
- **THEN** no level lacks a tower that the previous level had

### Requirement: Enemy traits
Each enemy trait of the roster SHALL work in play: SARS-CoV-2 releases two small rhinoviruses when it dies; Herpes simplex is immune during part of every cycle; HPV takes less physical damage; Streptococcus pyogenes walks as three separate segments (except where a level turns the trait off); Staphylococcus aureus resists the damage type that hurt it most once it is 40% along the path; Clostridioides difficile comes back once with a quarter of its health; HIV disables towers near it every 3 seconds; Mycobacterium tuberculosis has heavy armor; Neisseria meningitidis splits into two copies at half health.

#### Scenario: Revival
- **WHEN** a C. difficile dies for the first time
- **THEN** it stays on the path with a quarter of its health and pays nothing; its second death pays the reward

#### Scenario: Split
- **WHEN** a Neisseria meningitidis loses half of its health
- **THEN** it is replaced by two smaller copies that share what is left, and the copies do not split again

### Requirement: Summoned and mobile towers
A B Lymphocyte SHALL mark up to three enemies in range, the furthest along first. A Bone Marrow SHALL keep up to three neutrophils on the path; each one stops one enemy that is not a boss and trades blows with it. Lymphocytes SHALL be movable to another empty slot, and rest for a moment after moving.

#### Scenario: Moving a lymphocyte
- **WHEN** the player moves a T Lymphocyte to an empty slot
- **THEN** the tower stands on the new slot and does not attack for 1.5 seconds

### Requirement: Level menu and progress
The game SHALL open on a menu that lists the 10 levels. Level 1 SHALL be open and each later level SHALL open when the one before is won. The best body health of each won level SHALL be saved on the device. After a win the player SHALL be offered the next level, a restart and the menu; after a defeat, a retry and the menu.

#### Scenario: Unlocking
- **WHEN** the player wins level 1
- **THEN** level 2 opens and the result is still there after the game is closed and opened again
