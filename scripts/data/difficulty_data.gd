class_name DifficultyData
extends Resource

@export var id: String = "medium"
@export var display_name: String = "Medium"
@export_multiline var description: String = ""
## Multiplies the amino acids a level starts with.
@export var start_amino: float = 1.0
## Multiplies the health of the body.
@export var body_health: float = 1.0
## Multiplies the health of every enemy.
@export var enemy_health: float = 1.0
## Multiplies the speed of every enemy.
@export var enemy_speed: float = 1.0
## Multiplies the amino acids that enemies drop.
@export var reward: float = 1.0
## Multiplies the start times and spawn intervals of the waves: below 1 the waves come sooner.
@export var wave_time: float = 1.0
