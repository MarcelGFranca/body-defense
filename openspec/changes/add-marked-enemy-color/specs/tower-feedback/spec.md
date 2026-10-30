## ADDED Requirements

### Requirement: Marked enemies show the mark
An enemy marked by a B lymphocyte SHALL be dyed with the color defined in the tower data for as long as the mark lasts, and the dye SHALL fade out as the mark ends. The sprite details SHALL stay readable, and unmarked enemies SHALL keep their own colors.

#### Scenario: Enemy is marked
- **WHEN** a B lymphocyte marks an enemy
- **THEN** the enemy is dyed with the lymphocyte color

#### Scenario: Mark ends
- **WHEN** the mark of 5 seconds runs out
- **THEN** the dye fades and the enemy shows its own colors again

#### Scenario: Mark is renewed
- **WHEN** a marked enemy is marked again
- **THEN** it stays dyed and the duration restarts
