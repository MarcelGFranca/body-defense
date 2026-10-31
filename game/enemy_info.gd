## The text of an enemy card, shared by the level screen in the menu and by the HUD.
class_name EnemyInfo
extends RefCounted

const DAMAGE_TYPES := ["physical", "thermal", "chemical", "antiviral", "immunological"]


## "VIRUS - SWARM" and the health of an enemy of a level whose difficulty scales health by `health_scale`.
static func summary_lines(data: EnemyData, health_scale: float) -> PackedStringArray:
	var lines := PackedStringArray()
	lines.append("%s - %s" % [_t(data.type).to_upper(), _t(data.role).to_upper()])
	lines.append(_t("HP %d") % roundi(data.health * health_scale))
	return lines


## The WEAK, RESISTS and IMMUNE lines of an enemy (the ones that apply).
static func defense_lines(data: EnemyData, table: DamageTable) -> PackedStringArray:
	var weak: Array[String] = []
	var resists: Array[String] = []
	var immune: Array[String] = []
	for damage_type in DAMAGE_TYPES:
		var factor := DamageCalculator.factor_for(damage_type, data, table)
		if factor == 0.0:
			immune.append(_t(damage_type))
		elif factor > 1.0:
			weak.append(_t(damage_type))
		elif factor < 1.0:
			resists.append(_t(damage_type))
	if data.armor_percent > 0.0:
		resists.append(_t("physical %d%%") % int(data.armor_percent))
	var lines := PackedStringArray()
	if not weak.is_empty():
		lines.append(_t("WEAK: %s") % ", ".join(weak).to_upper())
	if not resists.is_empty():
		lines.append(_t("RESISTS: %s") % ", ".join(resists).to_upper())
	if not immune.is_empty():
		lines.append(_t("IMMUNE: %s") % ", ".join(immune).to_upper())
	return lines


static func _t(text: String) -> String:
	return TranslationServer.translate(text)
