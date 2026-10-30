class_name LevelData
extends Resource

@export var id: String = ""
## Position in the campaign, from 1 to 10.
@export var number: int = 1
## Name shown at the top of the HUD.
@export var display_name: String = ""
## The part of the body where the level takes place, shown in the level menu.
@export var body_part: String = ""
@export_multiline var description: String = ""
## Enemy that closes the level when it has one (levels 3, 7 and 10), or an empty string.
@export var boss_id: String = ""
## Enemy traits that are turned off in this level, for example ["chain"].
@export var disabled_traits: Array = []
## Colors of the map: background, tissue blobs, and the three layers of the path.
@export var background_color: Color = Color("3a1f2b")
@export var tissue_color: Color = Color("4d2a3a")
@export var path_edge_color: Color = Color("7a1d2e")
@export var path_fill_color: Color = Color("c4364f")
@export var path_dash_color: Color = Color("e8667d")
## Shape of the tissue drawn on the background: "blobs", "rings" or "stripes".
@export var decor: String = "blobs"
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
