## ADDED Requirements

### Requirement: Neutrophils roam and go to meet enemies
A neutrophil summoned by a Bone Marrow SHALL be drawn with the neutrophil sprite and SHALL keep moving slightly around its post while it waits. When an enemy that is not a boss comes inside the guard radius of the post, the neutrophil SHALL walk along the path to just ahead of that enemy and hold it back. When there is no enemy inside the radius, it SHALL return to its post.

#### Scenario: Waiting
- **WHEN** no enemy is near the post
- **THEN** the neutrophil drifts around the post and plays its idle animation

#### Scenario: An enemy comes close
- **WHEN** an enemy enters the guard radius
- **THEN** the neutrophil walks to the enemy and blocks it

#### Scenario: Boss
- **WHEN** a boss is inside the guard radius
- **THEN** the neutrophil does not go to meet it

#### Scenario: The enemy is gone
- **WHEN** the enemy dies or leaves the radius
- **THEN** the neutrophil walks back to its post

### Requirement: Neutrophils regenerate
A neutrophil SHALL recover health over time, at the rate set in the Bone Marrow data, and SHALL never exceed its full health.

#### Scenario: A hurt neutrophil rests
- **WHEN** a neutrophil has lost health
- **THEN** its health rises every second until it is full

### Requirement: Neutrophils come back every 15 seconds
A Bone Marrow SHALL create one neutrophil at once when it is built and one more every 15 seconds while it has fewer than three. A neutrophil that dies SHALL be replaced 15 seconds after the Bone Marrow had its full count.

#### Scenario: A neutrophil dies
- **WHEN** a neutrophil dies and the Bone Marrow has fewer than three
- **THEN** a new one appears after 15 seconds, and never more than three exist

### Requirement: Neutrophils show their attack
A neutrophil SHALL play its attack animation, facing the enemy, each time it hits the enemy it is holding, and SHALL be drawn above the enemies so the attack can be seen.

#### Scenario: A neutrophil hits
- **WHEN** a neutrophil hits the enemy it holds
- **THEN** its attack animation plays and it goes back to idle afterwards
