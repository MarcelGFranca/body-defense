## Purpose

Defines how waves start on a level clock, how the player can call a wave early, and when a level is won or lost.

## ADDED Requirements

### Requirement: Waves start on a level clock
Each wave SHALL have a start time in seconds on the level clock. The clock SHALL start at 0 when the level starts. A wave SHALL start when the clock reaches its start time, and its enemies SHALL spawn one at a time at the wave's spawn interval.

#### Scenario: Scheduled start
- **WHEN** the level clock reaches 5 s and wave 1 starts at 5 s
- **THEN** wave 1 begins spawning its first enemy at the entrance

#### Scenario: Spawn interval
- **WHEN** a wave has a spawn interval of 1.2 s
- **THEN** its enemies spawn 1.2 s apart

### Requirement: Call the next wave
The game SHALL provide a button that starts the next wave that has not started yet, immediately. Calling a wave early SHALL NOT change the start times of the other waves. The button SHALL be available only while at least one wave has not started.

#### Scenario: Calling early
- **WHEN** the player presses the button at 10 s and wave 2 is scheduled for 50 s
- **THEN** wave 2 starts at 10 s, does not start again at 50 s, and wave 3 still starts at 150 s

#### Scenario: No waves left
- **WHEN** every wave has already started
- **THEN** the button is hidden or disabled

### Requirement: Clock follows speed and pause
The level clock, spawning, enemy movement, tower actions and status effects SHALL all run at the same speed. At 2× speed they run twice as fast, and while the game is paused all of them stop.

#### Scenario: Double speed
- **WHEN** the speed is 2× and wave 2 is scheduled for 50 s of level time
- **THEN** wave 2 starts after 25 s of real time

#### Scenario: Pause
- **WHEN** the game is paused
- **THEN** the clock, enemies and towers do not advance until the game is resumed

### Requirement: Victory
The level SHALL be won when every wave has started, no enemy is left in the level, and the body's health is above zero.

#### Scenario: Last enemy defeated
- **WHEN** the last enemy of the last wave is defeated or leaves the level, and body health is above zero
- **THEN** the victory screen is shown

### Requirement: Defeat
The level SHALL be lost when the body's health reaches zero.

#### Scenario: Body health reaches zero
- **WHEN** an enemy reaches the exit and the body's health drops to zero or below
- **THEN** the defeat screen is shown and the level stops
