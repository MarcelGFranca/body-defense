## ADDED Requirements

### Requirement: Tower attributes on long press
Holding a build card, or a built tower on the map, for 0.3 seconds SHALL show a panel with the tower's name, role, mobility, cost, range, damage and ability. For towers that deal damage it SHALL list the enemies of the current level that the tower is good against, weak against and useless against. The panel SHALL close when the press ends.

#### Scenario: Holding a build card
- **WHEN** the player holds a card in the build menu for 0.3 seconds
- **THEN** the attribute panel of that tower is shown

#### Scenario: Releasing a held card
- **WHEN** the player releases a card after the panel was shown
- **THEN** the panel closes and the tower is not built

#### Scenario: Tapping a card
- **WHEN** the player taps a card quickly
- **THEN** the tower is built as before and no panel is shown

#### Scenario: Holding a built tower
- **WHEN** the player holds a built tower on the map for 0.3 seconds
- **THEN** the attribute panel is shown, and releasing does not open the sell card

#### Scenario: Support towers
- **WHEN** the panel is shown for a tower that deals no damage
- **THEN** it says the tower supports the others and lists no enemies
