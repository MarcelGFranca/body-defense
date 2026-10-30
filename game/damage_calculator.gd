class_name DamageCalculator
extends RefCounted

const PHYSICAL := "physical"
const IMMUNOLOGICAL := "immunological"


## Factor applied to `damage_type` against `target`: a per-enemy override wins over the table.
static func factor_for(damage_type: String, target: EnemyData, table: DamageTable) -> float:
	if target.damage_factor_overrides.has(damage_type):
		return float(target.damage_factor_overrides[damage_type])
	return table.factor(damage_type, target.type)


## Rule order: type multiplier (and resistance), armor (physical only), mark bonus, round down, minimum 0.
static func resolve(amount: float, damage_type: String, target: EnemyData, table: DamageTable, mark_bonus: float = 0.0, resistance: float = 1.0) -> int:
	var value := amount * factor_for(damage_type, target, table) * resistance
	if damage_type == PHYSICAL:
		value *= 1.0 - clampf(target.armor_percent, 0.0, 100.0) / 100.0
	value *= 1.0 + mark_bonus
	return maxi(0, floori(value + 0.0001))
