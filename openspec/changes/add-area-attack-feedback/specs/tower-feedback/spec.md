## ADDED Requirements

### Requirement: Area attacks are visible
When a tower with an area attack hurts enemies, it SHALL play its attack animation and SHALL show a ring that spreads from the tower to the edge of its range in 0.6 seconds, in a colour that depends on its damage type.

#### Scenario: Lysozyme dissolves a bacterium
- **WHEN** a bacterium is inside the range of a lysozyme and the lysozyme attacks
- **THEN** the lysozyme plays its attack animation and a ring starts spreading

#### Scenario: No enemies in range
- **WHEN** no enemy is in range
- **THEN** the tower does not attack and shows no ring
