## ADDED Requirements

### Requirement: The T lymphocyte charges and fires a thick beam
After each shot the T lymphocyte SHALL play a charging animation that lasts until it can fire again and then stays fully charged. Its shot SHALL be drawn as a beam much thicker than the thin line of other towers, ending in an explosion at the target. The shot SHALL keep its damage, interval and range.

#### Scenario: Firing
- **WHEN** an enemy is in range and the T lymphocyte is ready
- **THEN** it plays its attack animation, a thick beam is drawn to the enemy and an explosion appears on the enemy

#### Scenario: Charging
- **WHEN** the attack animation ends
- **THEN** the charge animation plays at a speed that ends when the interval ends

#### Scenario: Other towers
- **WHEN** a tower without a beam width attacks
- **THEN** it keeps drawing the thin line
