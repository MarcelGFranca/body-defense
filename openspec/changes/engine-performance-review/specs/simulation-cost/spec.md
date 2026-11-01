## ADDED Requirements

### Requirement: Same game, cheaper
The simulation allocates nothing per frame for target queries, slow renewal, trait checks and calm status steps, and changes no result.

#### Scenario: Replay
- **WHEN** 200 playtest games are replayed with the same seeds as before the change
- **THEN** `games.jsonl` and `summary.csv` are identical

### Requirement: HUD writes on change
A HUD label is rewritten only when its number changes or the language changes.

#### Scenario: Static values
- **WHEN** nothing changes for a frame
- **THEN** no label text is formatted
