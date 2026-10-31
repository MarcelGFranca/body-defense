## ADDED Requirements

### Requirement: Burning shows fire
An enemy that is burning shows flames and the hypothalamus sends a red wave.

#### Scenario: Behaviour
- **WHEN** the hypothalamus ignites an enemy
- **THEN** the enemy shows flames and the wave runs for 1.1 s

### Requirement: The hypothalamus keeps attacking
The hypothalamus keeps attacking enemies that already burn, and every fire attack brings the burn back to its full time.

#### Scenario: Enemies already burning
- **WHEN** enemies in range of the hypothalamus are already burning
- **THEN** the tower animates, plays its sound and sends the fever wave once per second, and each enemy's burn goes back to 4 s
