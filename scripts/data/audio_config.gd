class_name AudioConfig
extends Resource

## Volume of sound effects and of music, in decibels. Music is quieter by default.
@export var sfx_volume_db: float = -6.0
@export var music_volume_db: float = -14.0
## Played instead of an enemy's hit sound when an attack does nothing because the enemy is immune.
@export var blocked_sound: String = ""
## Played when the secret tap code in the menu opens every level.
@export var unlock_sound: String = ""
## Tunes played once when a level is won or lost.
@export var victory_music: String = ""
@export var defeat_music: String = ""
