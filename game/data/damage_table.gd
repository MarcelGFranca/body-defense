class_name DamageTable
extends Resource

## damage type -> {"virus": factor, "bacterium": factor}. A factor of 0 means immune.
@export var factors: Dictionary = {}


func factor(damage_type: String, target_type: String) -> float:
	var row: Dictionary = factors.get(damage_type, {})
	return float(row.get(target_type, 1.0))
