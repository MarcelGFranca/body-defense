## Checks the enemy, tower and level data against the specs. Returns lists of messages.
class_name DataValidator
extends RefCounted

const DAMAGE_TYPES := ["physical", "thermal", "chemical", "antiviral", "immunological"]
const PROTOTYPE_TOWERS := ["macrophage", "mucus-cell", "interferon"]
const BOSS_STRENGTH := 5.0


## `enemies` maps id -> EnemyData. Returns error messages that name the enemy and the problem.
static func validate_enemies(enemies: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if enemies.size() != 13:
		errors.append("roster: expected 13 enemies, found %d" % enemies.size())
	var viruses := 0
	var bacteria := 0
	var bosses := 0
	var regular_health := 0.0
	var regular_reward := 0.0
	for id in enemies:
		var e: EnemyData = enemies[id]
		if e.id != id or e.id == "":
			errors.append("%s: id is missing or does not match its key" % id)
		if e.type != "virus" and e.type != "bacterium":
			errors.append("%s: type must be virus or bacterium" % id)
		if e.role == "":
			errors.append("%s: role is missing" % id)
		if e.trait_id == "":
			errors.append("%s: trait_id is missing" % id)
		if e.health <= 0.0:
			errors.append("%s: health must be greater than zero" % id)
		if e.speed <= 0.0:
			errors.append("%s: speed must be greater than zero" % id)
		if e.body_damage <= 0:
			errors.append("%s: body_damage must be greater than zero" % id)
		if e.amino_acid_reward <= 0:
			errors.append("%s: amino_acid_reward must be greater than zero" % id)
		for field in ["sound_hit", "sound_attack", "sound_death"]:
			errors.append_array(_check_sound(id, field, e.get(field)))
		if e.role == "boss":
			bosses += 1
		else:
			regular_health += e.health
			regular_reward += e.amino_acid_reward
			if e.type == "virus":
				viruses += 1
			else:
				bacteria += 1
	if viruses != 5 or bacteria != 5 or bosses != 3:
		errors.append("roster: expected 5 regular viruses, 5 regular bacteria and 3 bosses, found %d, %d and %d" % [viruses, bacteria, bosses])
	var regular := viruses + bacteria
	if regular > 0:
		for id in enemies:
			var e: EnemyData = enemies[id]
			if e.role != "boss":
				continue
			if e.health < BOSS_STRENGTH * regular_health / regular:
				errors.append("%s: boss health must be at least %dx the regular average" % [id, int(BOSS_STRENGTH)])
			if e.amino_acid_reward < BOSS_STRENGTH * regular_reward / regular:
				errors.append("%s: boss amino_acid_reward must be at least %dx the regular average" % [id, int(BOSS_STRENGTH)])
	return errors


static func validate_towers(towers: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if towers.size() != 10:
		errors.append("towers: expected 10 towers, found %d" % towers.size())
	var prototype: Array = []
	for id in towers:
		var t: TowerData = towers[id]
		if t.id != id or t.id == "":
			errors.append("%s: id is missing or does not match its key" % id)
		if t.cost <= 0:
			errors.append("%s: cost must be greater than zero" % id)
		if t.ability_description == "":
			errors.append("%s: ability_description is missing" % id)
		errors.append_array(_check_sound(id, "sound_attack", t.sound_attack))
		if t.mobility != "fixed" and t.mobility != "mobile":
			errors.append("%s: mobility must be fixed or mobile" % id)
		if t.damage_type != "none" and not DAMAGE_TYPES.has(t.damage_type):
			errors.append("%s: unknown damage type %s" % [id, t.damage_type])
		if t.in_prototype:
			prototype.append(id)
	prototype.sort()
	var expected := PROTOTYPE_TOWERS.duplicate()
	expected.sort()
	if prototype != expected:
		errors.append("towers: the prototype towers must be %s, found %s" % [expected, prototype])
	return errors


## Warnings for damage values that would round down to 0 against some target.
static func damage_warnings(towers: Dictionary, enemies: Dictionary, table: DamageTable) -> Array[String]:
	var warnings: Array[String] = []
	for tower_id in towers:
		var t: TowerData = towers[tower_id]
		var base := t.attack_damage if t.attack_damage > 0.0 else t.dot_damage
		if base <= 0.0 or t.damage_type == "none":
			continue
		for enemy_id in enemies:
			var e: EnemyData = enemies[enemy_id]
			if DamageCalculator.factor_for(t.damage_type, e, table) <= 0.0:
				continue
			if DamageCalculator.resolve(base, t.damage_type, e, table) <= 0:
				warnings.append("%s: %s damage rounds to 0 against %s" % [tower_id, t.damage_type, enemy_id])
	return warnings


static func validate_level(level: LevelData, towers: Dictionary, enemies: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if level.path_points.size() < 2:
		errors.append("%s: the path needs at least two points" % level.id)
	errors.append_array(_check_sound(level.id, "music", level.music))
	if level.starting_amino_acids <= 0 or level.body_health <= 0:
		errors.append("%s: starting amino acids and body health must be positive" % level.id)
	for id in level.tower_ids:
		if not towers.has(id):
			errors.append("%s: unknown tower %s" % [level.id, id])
	var last_start := -1.0
	for wave in level.waves:
		if wave.start_time <= last_start:
			errors.append("%s: wave start times must increase" % level.id)
		last_start = wave.start_time
		for entry in wave.entries:
			if not enemies.has(entry["enemy"]):
				errors.append("%s: unknown enemy %s" % [level.id, entry["enemy"]])
	return errors


## Errors for a sound path that is empty or points to a file that does not exist.
static func _check_sound(owner_id: String, field: String, path: String) -> Array[String]:
	var errors: Array[String] = []
	if path == "":
		errors.append("%s: %s is missing" % [owner_id, field])
	elif not ResourceLoader.exists(path):
		errors.append("%s: %s does not exist (%s)" % [owner_id, field, path])
	return errors


static func validate_all() -> Dictionary:
	var enemies := DataLoader.load_all("res://data/enemies")
	var towers := DataLoader.load_all("res://data/towers")
	var table: DamageTable = load("res://data/damage_table.tres")
	var level: LevelData = load("res://data/levels/level_1.tres")
	var errors := validate_enemies(enemies)
	errors.append_array(validate_towers(towers))
	errors.append_array(validate_level(level, towers, enemies))
	return {"errors": errors, "warnings": damage_warnings(towers, enemies, table)}
