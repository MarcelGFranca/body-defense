## ADDED Requirements

### Requirement: FPS readout in debug mode
After the secret tap code is entered on the start screen, the game SHALL show the current frames per second in small text at the top right of the start screen and of every level, until the game is closed. Before the code, nothing SHALL be shown.

#### Scenario: Before the code
- **WHEN** the game starts
- **THEN** no FPS readout is visible

#### Scenario: After the code
- **WHEN** the secret code is entered
- **THEN** the FPS readout is visible on the start screen and during a level
