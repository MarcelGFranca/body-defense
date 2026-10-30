## Purpose

Defines the currencies of the tower defense: amino acids, earned from defeated enemies and spent on towers, and ATP, a secondary energy currency reserved for a later release.

## ADDED Requirements

### Requirement: Amino acids are the primary currency
The game SHALL use amino acids (`amino_acids`) as its primary currency. The balance SHALL be a whole number, SHALL start at the value defined by the current level, and SHALL never be negative.

#### Scenario: Level start
- **WHEN** a level starts
- **THEN** the amino acid balance equals the starting amount defined for that level

#### Scenario: Balance never goes negative
- **WHEN** any action would reduce the balance below zero
- **THEN** the action is refused and the balance stays unchanged

### Requirement: Defeated enemies drop amino acids
When an enemy is defeated by the player's defenses, the game SHALL release amino acids equal to that enemy's `amino_acid_reward`. The amino acids SHALL be collected automatically and added to the balance without any player input.

#### Scenario: Enemy defeated
- **WHEN** an enemy with an `amino_acid_reward` of 5 is defeated
- **THEN** 5 amino acids are added to the balance and the counter on screen shows the new total

#### Scenario: Enemy reaches the end of the path
- **WHEN** an enemy reaches the end of the path instead of being defeated
- **THEN** no amino acids are added to the balance

#### Scenario: Enemy splits or revives
- **WHEN** an enemy whose trait creates new enemies (for example by splitting or reviving) is defeated
- **THEN** only the `amino_acid_reward` of each enemy that is actually defeated is added, with no extra bonus for the trait itself

### Requirement: Towers cost amino acids
Building a tower or upgrading it SHALL cost amino acids. The game SHALL only allow the action when the balance covers the full cost.

#### Scenario: Enough amino acids
- **WHEN** the player builds a tower whose cost is less than or equal to the balance
- **THEN** the tower is built and the cost is deducted from the balance

#### Scenario: Not enough amino acids
- **WHEN** the player tries to build a tower whose cost is greater than the balance
- **THEN** no tower is built, the balance is unchanged and the player gets feedback that the amino acids are insufficient

### Requirement: Selling a tower refunds part of its cost
Selling a tower SHALL return a fixed fraction of the amino acids spent on it, including its upgrades. The fraction SHALL be defined in data, not in code, and SHALL be less than the full cost.

#### Scenario: Sell a tower
- **WHEN** the player sells a tower that cost 100 amino acids in total and the refund fraction is 0.6
- **THEN** 60 amino acids are added to the balance and the tower is removed

### Requirement: ATP is a deferred secondary currency
The game SHALL reserve ATP (`atp`) as a secondary currency representing cell energy. When ATP is enabled in a future release, it SHALL be earned over time and at the end of each wave (not from defeating enemies), SHALL be spent on special abilities (for example boosting a defender for a short time), and SHALL have a maximum amount. Until it is enabled, ATP SHALL NOT appear in the UI, saves or level data, and SHALL NOT affect gameplay.

#### Scenario: ATP not yet enabled
- **WHEN** the game runs without the ATP feature enabled
- **THEN** no ATP counter is shown, no ATP is earned or spent, and amino acids behave exactly as specified above

#### Scenario: ATP not earned from kills
- **WHEN** the ATP feature is enabled and an enemy is defeated
- **THEN** only amino acids are earned from that kill, never ATP

#### Scenario: ATP maximum
- **WHEN** the ATP feature is enabled and the ATP balance reaches its maximum
- **THEN** further ATP income is discarded until some ATP is spent
