class_name LevelData
extends Resource

@export var id: String = ""
## Name shown at the top of the HUD.
@export var display_name: String = ""
## Background music loop (a WAV file).
@export var music: String = ""
## Size of the whole map in map units. It can be larger than the screen: the player scrolls it.
@export var map_size: Vector2 = Vector2(360, 640)
## Corners of the enemy path, in map units.
@export var path_points: PackedVector2Array = PackedVector2Array()
@export var slots: PackedVector2Array = PackedVector2Array()
@export var starting_amino_acids: int = 0
@export var body_health: int = 1
## Ids of the towers the player can build in this level.
@export var tower_ids: Array = []
@export var waves: Array[WaveData] = []
