class_name TowerData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var role: String = ""
## Short text shown on the tower card in the HUD.
@export_multiline var ability_description: String = ""
## "physical", "thermal", "chemical", "antiviral", "immunological" or "none".
@export var damage_type: String = "none"
@export var cost: int = 1
@export_enum("fixed", "mobile") var mobility: String = "fixed"
@export var in_prototype: bool = false
## "single_target", "damage_aura", "slow_puddle", "slow_aura", "root_aura", "dot_aura", "summon_marker" or "summon_units".
@export var behavior: String = "none"
@export var range_px: float = 80.0
@export var attack_damage: float = 0.0
@export var attack_interval: float = 1.0
@export var slow_percent: float = 0.0
## For "slow_puddle" towers: size and lifetime of the mucus left on the ground.
@export var puddle_radius: float = 0.0
@export var puddle_seconds: float = 0.0
@export var root_seconds: float = 0.0
@export var root_cooldown: float = 0.0
@export var dot_damage: float = 0.0
@export var dot_seconds: float = 0.0
@export var mark_bonus: float = 0.0
@export var mark_seconds: float = 0.0
@export var summon_interval: float = 0.0
@export var summon_cap: int = 0
@export var unit_health: float = 0.0
## When its alpha is above 0 the tower keeps pulsing a mist of this color across its area.
@export var mist_color: Color = Color(0, 0, 0, 0)
## Sound file played each time the tower attacks.
@export var sound_attack: String = ""
