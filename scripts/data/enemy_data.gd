class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_enum("virus", "bacterium") var type: String = "virus"
@export var role: String = ""
@export var trait_id: String = ""
@export_multiline var trait_description: String = ""
## Numbers that the trait needs, for example {"enemy": "rhinovirus", "count": 2} for `release_minions`.
@export var trait_params: Dictionary = {}
@export var health: float = 1.0
## Movement speed in map units per second.
@export var speed: float = 1.0
@export var body_damage: int = 1
@export var amino_acid_reward: int = 1
## Percentage of physical damage that is blocked, from 0 to 100.
@export var armor_percent: float = 0.0
## Replaces the damage table factor for a damage type, for example {"thermal": 0.5}.
@export var damage_factor_overrides: Dictionary = {}
## Folder with the sprite and animations, or an empty string to use the placeholder.
@export var sprite_dir: String = ""
## Sound files: when the enemy is hurt, when it attacks the body, and when it dies.
@export var sound_hit: String = ""
@export var sound_attack: String = ""
@export var sound_death: String = ""
