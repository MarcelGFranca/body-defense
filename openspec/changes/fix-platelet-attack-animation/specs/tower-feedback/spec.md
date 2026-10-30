## ADDED Requirements

### Requirement: Root attacks are visible
When a platelet roots an enemy it SHALL play its attack animation, facing the enemy, once per release. The platelet SHALL hold at most 3 enemies at the same time, preferring the ones furthest along the path. It SHALL hold each rooted enemy with its own tendril, which grows from the platelet to the enemy, stays for as long as the enemy is paralysed, then fades out and disappears when the enemy is free.

#### Scenario: Platelet roots an enemy
- **WHEN** an enemy is in range of a platelet that is ready
- **THEN** the enemy is rooted, the platelet plays its attack animation and tendrils grow to the enemy

#### Scenario: Enemy is freed
- **WHEN** the root time of the enemy ends, or the enemy dies
- **THEN** the tendrils to that enemy are gone

#### Scenario: Platelet is recharging
- **WHEN** the only enemy in range cannot be rooted yet
- **THEN** the platelet stays in its idle animation and shows no tendrils

#### Scenario: More than three enemies
- **WHEN** five enemies are in range of a platelet that is ready
- **THEN** exactly three are rooted, each with one tendril
