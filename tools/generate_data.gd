## Generates every data file from the tables below.
## Usage: godot --headless --path . --script res://tools/generate_data.gd
extends SceneTree

const ENEMY_DIR := "res://data/enemies"
const TOWER_DIR := "res://data/towers"
const LEVEL_DIR := "res://data/levels"

# All numbers are provisional starting values, tuned during playtests.
const ENEMIES := [
	# Regular viruses
	{"id": "rhinovirus", "name": "Rhinovirus", "type": "virus", "role": "swarm", "trait_id": "large_groups",
		"trait": "Appears in large groups, very low health.", "health": 20, "speed": 45, "damage": 1, "reward": 2, "sprite": true},
	{"id": "influenza", "name": "Influenza", "type": "virus", "role": "fast", "trait_id": "high_speed",
		"trait": "High speed, low health.", "health": 30, "speed": 79, "damage": 1, "reward": 3, "sprite": true},
	{"id": "sars-cov-2", "name": "SARS-CoV-2", "type": "virus", "role": "contagious", "trait_id": "release_minions",
		"trait": "Releases smaller viruses when defeated.", "health": 60, "speed": 45, "damage": 2, "reward": 5},
	{"id": "herpes-simplex", "name": "Herpes Simplex", "type": "virus", "role": "stealthy", "trait_id": "dormant",
		"trait": "Goes dormant and is immune to attacks for a few moments.", "health": 50, "speed": 50, "damage": 1, "reward": 4},
	{"id": "hpv", "name": "HPV", "type": "virus", "role": "resistant", "trait_id": "shell",
		"trait": "Shell that reduces damage taken.", "health": 70, "speed": 40, "damage": 2, "reward": 5, "armor": 30},
	# Regular bacteria
	{"id": "e-coli", "name": "E. coli", "type": "bacterium", "role": "basic", "trait_id": "basic",
		"trait": "Default enemy with medium health and speed.", "health": 40, "speed": 55, "damage": 1, "reward": 3},
	{"id": "streptococcus-pyogenes", "name": "Streptococcus pyogenes", "type": "bacterium", "role": "chained", "trait_id": "chain",
		"trait": "Moves as a chain of segments that die separately (turned off in the prototype).",
		"health": 80, "speed": 40, "damage": 2, "reward": 6, "sprite": true},
	{"id": "staphylococcus-aureus", "name": "Staphylococcus aureus", "type": "bacterium", "role": "resistant", "trait_id": "gain_resistance",
		"trait": "Gains resistance to one damage type along the path.", "health": 75, "speed": 45, "damage": 2, "reward": 6},
	{"id": "helicobacter-pylori", "name": "Helicobacter pylori", "type": "bacterium", "role": "slow-immune", "trait_id": "slow_immune",
		"trait": "Unaffected by slowing effects.", "health": 60, "speed": 45, "damage": 2, "reward": 5},
	{"id": "clostridioides-difficile", "name": "Clostridioides difficile", "type": "bacterium", "role": "spore", "trait_id": "revive",
		"trait": "Comes back once after being defeated, with low health.", "health": 55, "speed": 45, "damage": 2, "reward": 5,
		"overrides": {"thermal": 0.5, "chemical": 0.5}},
	# Bosses
	{"id": "hiv", "name": "HIV", "type": "virus", "role": "boss", "trait_id": "tower_disable_aura",
		"trait": "Very high health, disables nearby towers in an aura, and affects lymphocytes longer.",
		"health": 350, "speed": 30, "damage": 10, "reward": 25},
	{"id": "mycobacterium-tuberculosis", "name": "Mycobacterium tuberculosis", "type": "bacterium", "role": "boss", "trait_id": "heavy_armor",
		"trait": "Very high health, very low speed, heavy armor.", "health": 450, "speed": 22, "damage": 10, "reward": 30, "armor": 40},
	{"id": "neisseria-meningitidis", "name": "Neisseria meningitidis", "type": "bacterium", "role": "boss", "trait_id": "split_at_half",
		"trait": "High health, splits into two smaller copies when half of its health is gone.",
		"health": 300, "speed": 35, "damage": 10, "reward": 25},
]

const TOWERS := [
	{"id": "macrophage", "ability": "Engulfs the first enemy in its range with a strong hit.", "name": "Macrophage", "role": "single-target", "damage_type": "physical", "cost": 50, "mobility": "fixed",
		"proto": true, "behavior": "single_target", "range": 95, "damage": 12, "interval": 1.0},
	{"id": "neutrophil", "ability": "Attacks very fast with weak hits.", "name": "Neutrophil", "role": "rapid fire", "damage_type": "physical", "cost": 45, "mobility": "fixed",
		"behavior": "single_target", "range": 80, "damage": 4, "interval": 0.4},
	{"id": "mucus-cell", "ability": "Throws mucus at the first enemy. The puddle slows enemies by 40% for 6 s.", "name": "Mucus Cell", "role": "slow", "damage_type": "none", "cost": 40, "mobility": "fixed",
		"proto": true, "behavior": "slow_puddle", "range": 90, "interval": 3.0, "slow": 40, "puddle_radius": 24, "puddle_seconds": 6.0},
	{"id": "platelet", "ability": "Roots an enemy for 1.2 s. Bosses are rooted for half the time.", "name": "Platelet", "role": "root", "damage_type": "none", "cost": 55, "mobility": "fixed",
		"behavior": "root_aura", "range": 80, "root": 1.2, "root_cooldown": 3.0},
	{"id": "hypothalamus", "ability": "Fever: burns enemies for 3 damage per second during 4 s.", "name": "Hypothalamus", "role": "damage over time", "damage_type": "thermal", "cost": 70, "mobility": "fixed",
		"behavior": "dot_aura", "range": 85, "dot": 3, "dot_seconds": 4},
	{"id": "lysozyme", "ability": "Dissolves bacteria. Strong against bacteria, weak against viruses.", "name": "Lysozyme", "role": "area", "damage_type": "chemical", "cost": 60, "mobility": "fixed",
		"behavior": "damage_aura", "range": 85, "damage": 6, "interval": 1.0},
	{"id": "interferon", "ability": "Antiviral pulse that also slows viruses by 25%. Bacteria are immune.", "name": "Interferon", "role": "area", "damage_type": "antiviral", "cost": 60, "mobility": "fixed",
		"proto": true, "behavior": "damage_aura", "range": 85, "damage": 6, "interval": 1.0, "slow": 25,
		"mist": Color(0.7, 0.95, 1.0)},
	{"id": "t-lymphocyte", "ability": "Hits one enemy at a time and ignores armor. It moves.", "name": "T Lymphocyte", "role": "single-target", "damage_type": "immunological", "cost": 90, "mobility": "mobile",
		"behavior": "single_target", "range": 100, "damage": 30, "interval": 2.0},
	{"id": "b-lymphocyte", "ability": "Releases antibodies that mark enemies: 25% more damage for 5 s. It moves.", "name": "B Lymphocyte", "role": "summoner", "damage_type": "antiviral", "cost": 80, "mobility": "mobile",
		"behavior": "summon_marker", "range": 100, "damage": 4, "interval": 4.0, "mark": 0.25, "mark_seconds": 5.0},
	{"id": "bone-marrow", "ability": "Creates up to 3 neutrophils that block enemies.", "name": "Bone Marrow", "role": "summoner", "damage_type": "physical", "cost": 100, "mobility": "fixed",
		"behavior": "summon_units", "range": 60, "summon_interval": 10.0, "summon_cap": 3, "unit_health": 25},
]

const FACTORS := {
	"physical": {"virus": 1.0, "bacterium": 1.0},
	"thermal": {"virus": 1.0, "bacterium": 1.0},
	"chemical": {"virus": 0.5, "bacterium": 1.5},
	"antiviral": {"virus": 1.5, "bacterium": 0.0},
	"immunological": {"virus": 1.0, "bacterium": 1.0},
}

# Level 1, in map units. The map is 360 x 820, taller than the screen, so the player scrolls it.
const LEVEL_1_MAP_SIZE := Vector2(360, 820)
const LEVEL_1_PATH := [
	Vector2(180, 40), Vector2(180, 110), Vector2(60, 110), Vector2(60, 260), Vector2(300, 260), Vector2(300, 410),
	Vector2(60, 410), Vector2(60, 560), Vector2(300, 560), Vector2(300, 700), Vector2(180, 700), Vector2(180, 780),
]
const LEVEL_1_SLOTS := [
	Vector2(180, 185), Vector2(180, 335), Vector2(180, 485), Vector2(240, 630), Vector2(250, 65), Vector2(110, 760),
]


func _initialize() -> void:
	_make_dir(ENEMY_DIR)
	_make_dir(TOWER_DIR)
	_make_dir(LEVEL_DIR)
	for row in ENEMIES:
		_save_enemy(row)
	for row in TOWERS:
		_save_tower(row)
	_save_damage_table()
	_save_economy()
	_save_audio()
	_save_level_1()
	print("generated %d enemies, %d towers, damage table, economy and level 1" % [ENEMIES.size(), TOWERS.size()])
	quit(0)


func _make_dir(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


func _save(res: Resource, path: String) -> void:
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("could not save %s (error %d)" % [path, err])


func _save_enemy(row: Dictionary) -> void:
	var e := EnemyData.new()
	e.id = row["id"]
	e.display_name = row["name"]
	e.type = row["type"]
	e.role = row["role"]
	e.trait_id = row["trait_id"]
	e.trait_description = row["trait"]
	e.health = float(row["health"])
	e.speed = float(row["speed"])
	e.body_damage = int(row["damage"])
	e.amino_acid_reward = int(row["reward"])
	e.armor_percent = float(row.get("armor", 0))
	e.damage_factor_overrides = row.get("overrides", {})
	e.sprite_dir = "res://assets/enemies/%s" % row["id"] if row.get("sprite", false) else ""
	e.sound_hit = "res://assets/audio/enemies/%s/hit.wav" % row["id"]
	e.sound_attack = "res://assets/audio/enemies/%s/attack.wav" % row["id"]
	e.sound_death = "res://assets/audio/enemies/%s/death.wav" % row["id"]
	_save(e, "%s/%s.tres" % [ENEMY_DIR, row["id"]])


func _save_tower(row: Dictionary) -> void:
	var t := TowerData.new()
	t.id = row["id"]
	t.display_name = row["name"]
	t.role = row["role"]
	t.ability_description = row["ability"]
	t.damage_type = row["damage_type"]
	t.cost = int(row["cost"])
	t.mobility = row["mobility"]
	t.in_prototype = row.get("proto", false)
	t.behavior = row["behavior"]
	t.range_px = float(row["range"])
	t.attack_damage = float(row.get("damage", 0))
	t.attack_interval = float(row.get("interval", 1.0))
	t.slow_percent = float(row.get("slow", 0))
	t.puddle_radius = float(row.get("puddle_radius", 0))
	t.puddle_seconds = float(row.get("puddle_seconds", 0))
	t.root_seconds = float(row.get("root", 0))
	t.root_cooldown = float(row.get("root_cooldown", 0))
	t.dot_damage = float(row.get("dot", 0))
	t.dot_seconds = float(row.get("dot_seconds", 0))
	t.mark_bonus = float(row.get("mark", 0))
	t.mark_seconds = float(row.get("mark_seconds", 0))
	t.summon_interval = float(row.get("summon_interval", 0))
	t.summon_cap = int(row.get("summon_cap", 0))
	t.unit_health = float(row.get("unit_health", 0))
	t.mist_color = row.get("mist", Color(0, 0, 0, 0))
	t.sound_attack = "res://assets/audio/towers/%s/attack.wav" % row["id"]
	_save(t, "%s/%s.tres" % [TOWER_DIR, row["id"]])


func _save_damage_table() -> void:
	var table := DamageTable.new()
	table.factors = FACTORS.duplicate(true)
	_save(table, "res://data/damage_table.tres")


func _save_economy() -> void:
	var config := EconomyConfig.new()
	config.refund_fraction = 0.6
	_save(config, "res://data/economy.tres")


func _save_audio() -> void:
	var config := AudioConfig.new()
	config.sfx_volume_db = -6.0
	config.music_volume_db = -14.0
	config.blocked_sound = "res://assets/audio/common/block.wav"
	_save(config, "res://data/audio.tres")


func _save_level_1() -> void:
	var level := LevelData.new()
	level.id = "level_1"
	level.display_name = "Garganta"
	level.music = "res://assets/audio/music/garganta.wav"
	level.map_size = LEVEL_1_MAP_SIZE
	level.path_points = PackedVector2Array(LEVEL_1_PATH)
	level.slots = PackedVector2Array(LEVEL_1_SLOTS)
	level.starting_amino_acids = 150
	level.body_health = 20
	level.tower_ids = ["macrophage", "mucus-cell", "interferon"]
	var waves: Array[WaveData] = []
	waves.append(_wave(5.0, 1.2, [{"enemy": "rhinovirus", "count": 8}]))
	waves.append(_wave(50.0, 1.0, [{"enemy": "rhinovirus", "count": 10}, {"enemy": "influenza", "count": 4}]))
	waves.append(_wave(150.0, 0.9, [{"enemy": "influenza", "count": 6}, {"enemy": "streptococcus-pyogenes", "count": 4}]))
	level.waves = waves
	_save(level, "%s/level_1.tres" % LEVEL_DIR)


func _wave(start_time: float, interval: float, entries: Array) -> WaveData:
	var wave := WaveData.new()
	wave.start_time = start_time
	wave.spawn_interval = interval
	wave.entries = entries
	return wave
