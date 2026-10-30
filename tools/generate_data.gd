## Generates every data file from the tables below.
## Usage: godot --headless --path . --script res://tools/generate_data.gd
extends SceneTree

const ENEMY_DIR := "res://data/enemies"
const TOWER_DIR := "res://data/towers"
const LEVEL_DIR := "res://data/levels"
const DIFFICULTY_DIR := "res://data/difficulties"

# All numbers are provisional starting values, tuned during playtests.
const ENEMIES := [
	# Regular viruses
	{"id": "rhinovirus", "name": "Rhinovirus", "type": "virus", "role": "swarm", "trait_id": "large_groups",
		"trait": "Appears in large groups, very low health.", "health": 20, "speed": 45, "damage": 1, "reward": 2, "sprite": true},
	{"id": "influenza", "name": "Influenza", "type": "virus", "role": "fast", "trait_id": "high_speed",
		"trait": "High speed, low health.", "health": 30, "speed": 79, "damage": 1, "reward": 3, "sprite": true},
	{"id": "sars-cov-2", "name": "SARS-CoV-2", "type": "virus", "role": "contagious", "trait_id": "release_minions",
		"trait": "Releases smaller viruses when defeated.", "health": 60, "speed": 45, "damage": 2, "reward": 5,
		"params": {"enemy": "rhinovirus", "count": 2, "scale": 0.7}, "sprite": true},
	{"id": "herpes-simplex", "name": "Herpes Simplex", "type": "virus", "role": "stealthy", "trait_id": "dormant",
		"trait": "Goes dormant and is immune to attacks for a few moments.", "health": 50, "speed": 50, "damage": 1, "reward": 4,
		"params": {"period": 4.0, "seconds": 1.5}, "sprite": true},
	{"id": "hpv", "name": "HPV", "type": "virus", "role": "resistant", "trait_id": "shell",
		"trait": "Shell that reduces damage taken.", "health": 85, "speed": 40, "damage": 2, "reward": 5, "armor": 30, "sprite": true},
	# Regular bacteria
	{"id": "e-coli", "name": "E. coli", "type": "bacterium", "role": "basic", "trait_id": "basic",
		"trait": "Default enemy with medium health and speed.", "health": 40, "speed": 50, "damage": 1, "reward": 3, "sprite": true},
	{"id": "streptococcus-pyogenes", "name": "Streptococcus pyogenes", "type": "bacterium", "role": "chained", "trait_id": "chain",
		"trait": "Moves as a chain of segments that die separately.",
		"health": 100, "speed": 40, "damage": 2, "reward": 6, "sprite": true,
		"params": {"segments": 3, "spacing": 16.0, "segment_sprite": "res://assets/enemies/streptococcus-pyogenes-segment"}},
	{"id": "staphylococcus-aureus", "name": "Staphylococcus aureus", "type": "bacterium", "role": "resistant", "trait_id": "gain_resistance",
		"trait": "Gains resistance to one damage type along the path.", "health": 75, "speed": 45, "damage": 2, "reward": 6,
		"params": {"at": 0.4, "factor": 0.5}, "sprite": true},
	{"id": "helicobacter-pylori", "name": "Helicobacter pylori", "type": "bacterium", "role": "slow-immune", "trait_id": "slow_immune",
		"trait": "Unaffected by slowing effects.", "health": 60, "speed": 45, "damage": 2, "reward": 5, "sprite": true},
	{"id": "clostridioides-difficile", "name": "Clostridioides difficile", "type": "bacterium", "role": "spore", "trait_id": "revive",
		"trait": "Comes back once after being defeated, with low health.", "health": 45, "speed": 45, "damage": 2, "reward": 5,
		"overrides": {"thermal": 0.5, "chemical": 0.5}, "params": {"health": 0.2}, "sprite": true},
	# Bosses
	{"id": "hiv", "name": "HIV", "type": "virus", "role": "boss", "trait_id": "tower_disable_aura",
		"trait": "Very high health, disables nearby towers in an aura, and affects lymphocytes longer.",
		"health": 400, "speed": 30, "damage": 10, "reward": 25, "params": {"radius": 65.0, "interval": 3.5}, "sprite": true},
	{"id": "mycobacterium-tuberculosis", "name": "Mycobacterium tuberculosis", "type": "bacterium", "role": "boss", "trait_id": "heavy_armor",
		"trait": "Very high health, very low speed, heavy armor.", "health": 300, "speed": 22, "damage": 8, "reward": 30, "armor": 30, "sprite": true},
	{"id": "neisseria-meningitidis", "name": "Neisseria meningitidis", "type": "bacterium", "role": "boss", "trait_id": "split_at_half",
		"trait": "High health, splits into two smaller copies when half of its health is gone.",
		"health": 290, "speed": 35, "damage": 8, "reward": 25, "params": {"copies": 2, "scale": 0.75}, "sprite": true},
]

const TOWERS := [
	{"id": "macrophage", "ability": "Engulfs the first enemy in its range with a strong hit.", "name": "Macrophage", "role": "single-target", "damage_type": "physical", "cost": 50, "mobility": "fixed",
		"proto": true, "behavior": "single_target", "range": 95, "damage": 14, "interval": 1.0},
	{"id": "neutrophil", "ability": "Attacks very fast with weak hits.", "name": "Neutrophil", "role": "rapid fire", "damage_type": "physical", "cost": 45, "mobility": "fixed",
		"behavior": "single_target", "range": 80, "damage": 5, "interval": 0.4},
	{"id": "mucus-cell", "ability": "Throws mucus at the first enemy. The puddle slows enemies by 40% for 6 s.", "name": "Mucus Cell", "role": "slow", "damage_type": "none", "cost": 40, "mobility": "fixed",
		"proto": true, "behavior": "slow_puddle", "range": 90, "interval": 3.0, "slow": 40, "puddle_radius": 24, "puddle_seconds": 6.0},
	{"id": "platelet", "ability": "Holds up to 3 enemies in place for 3 s each. Bosses are held for half the time.", "name": "Platelet", "role": "root", "damage_type": "none", "cost": 55, "mobility": "fixed",
		"behavior": "root_aura", "range": 80, "root": 3.0, "root_cooldown": 3.0, "root_targets": 3},
	{"id": "hypothalamus", "ability": "Fever: burns enemies for 3 damage per second during 4 s.", "name": "Hypothalamus", "role": "damage over time", "damage_type": "thermal", "cost": 90, "mobility": "fixed",
		"behavior": "dot_aura", "range": 85, "dot": 3, "dot_seconds": 4},
	{"id": "lysozyme", "ability": "Dissolves bacteria. Strong against bacteria, weak against viruses.", "name": "Lysozyme", "role": "area", "damage_type": "chemical", "cost": 70, "mobility": "fixed",
		"behavior": "damage_aura", "range": 85, "damage": 4, "interval": 1.0},
	{"id": "interferon", "ability": "Antiviral pulse that also slows viruses by 25%. Bacteria are immune.", "name": "Interferon", "role": "area", "damage_type": "antiviral", "cost": 70, "mobility": "fixed",
		"proto": true, "behavior": "damage_aura", "range": 85, "damage": 5, "interval": 1.0, "slow": 25,
		"mist": Color(0.7, 0.95, 1.0)},
	{"id": "t-lymphocyte", "ability": "Charges, then fires a thick beam that explodes on one enemy. Ignores armor. It moves.", "name": "T Lymphocyte", "role": "single-target", "damage_type": "immunological", "cost": 90, "mobility": "mobile",
		"behavior": "single_target", "range": 100, "damage": 55, "interval": 2.0, "beam": 14},
	{"id": "b-lymphocyte", "ability": "Releases antibodies that mark up to 4 enemies: 35% more damage for 5 s. It moves.", "name": "B Lymphocyte", "role": "summoner", "damage_type": "antiviral", "cost": 70, "mobility": "mobile",
		"behavior": "summon_marker", "range": 100, "damage": 6, "interval": 3.5, "mark": 0.35, "mark_seconds": 5.0, "mark_targets": 4, "mark_color": Color(0.78, 0.5, 0.9)},
	{"id": "bone-marrow", "ability": "Creates a neutrophil every 15 s, up to 3, that block and fight enemies.", "name": "Bone Marrow", "role": "summoner", "damage_type": "physical", "cost": 90, "mobility": "fixed",
		"behavior": "summon_units", "range": 70, "summon_interval": 15.0, "summon_cap": 3, "unit_health": 40, "unit_damage": 8, "unit_radius": 60, "unit_speed": 80, "unit_regen": 2.0},
]

# The three difficulty settings. Medium is the balanced game; the others change these multipliers.
const DIFFICULTIES := [
	{"id": "easy", "name": "Easy", "desc": "More amino acids and body health, weaker and slower enemies, more time between waves.",
		"start_amino": 1.3, "body_health": 1.5, "enemy_health": 0.8, "enemy_speed": 0.9, "reward": 1.15, "wave_time": 1.25},
	{"id": "medium", "name": "Medium", "desc": "The game as it was designed.",
		"start_amino": 1.0, "body_health": 1.0, "enemy_health": 1.0, "enemy_speed": 1.0, "reward": 1.0, "wave_time": 1.0},
	{"id": "hard", "name": "Hard", "desc": "Less money and body health, tougher and faster enemies, waves come sooner.",
		"start_amino": 0.95, "body_health": 0.8, "enemy_health": 1.12, "enemy_speed": 1.05, "reward": 0.95, "wave_time": 0.92},
]

const FACTORS := {
	"physical": {"virus": 1.0, "bacterium": 1.0},
	"thermal": {"virus": 1.0, "bacterium": 1.0},
	"chemical": {"virus": 0.5, "bacterium": 1.5},
	"antiviral": {"virus": 1.5, "bacterium": 0.0},
	"immunological": {"virus": 1.0, "bacterium": 1.0},
}

# Levels, in map units. Every map is 360 wide and as tall as it needs to be: the player scrolls it.
const LEVEL_1_PATH := [
	Vector2(180, 40), Vector2(180, 110), Vector2(60, 110), Vector2(60, 260), Vector2(300, 260), Vector2(300, 410),
	Vector2(60, 410), Vector2(60, 560), Vector2(300, 560), Vector2(300, 700), Vector2(180, 700), Vector2(180, 780),
]
const LEVEL_1_SLOTS := [
	Vector2(180, 185), Vector2(180, 335), Vector2(180, 485), Vector2(240, 630), Vector2(250, 65), Vector2(110, 760),
]
## A slot must be this far from the path (so it does not cover it) and no farther than this (so it can reach it).
const SLOT_MIN_DISTANCE := 40.0
const SLOT_MAX_DISTANCE := 78.0
const SLOT_SPACING := 46.0
const SLOT_REACH := 85.0

const ALL_TOWERS := ["macrophage", "mucus-cell", "interferon", "neutrophil", "lysozyme", "platelet", "hypothalamus",
	"t-lymphocyte", "b-lymphocyte", "bone-marrow"]


func _initialize() -> void:
	_make_dir(ENEMY_DIR)
	_make_dir(TOWER_DIR)
	_make_dir(LEVEL_DIR)
	_make_dir(DIFFICULTY_DIR)
	for row in DIFFICULTIES:
		_save_difficulty(row)
	for row in ENEMIES:
		_save_enemy(row)
	for row in TOWERS:
		_save_tower(row)
	_save_damage_table()
	_save_economy()
	_save_audio()
	var levels := _levels()
	for row in levels:
		_save_level(row)
	print("generated %d enemies, %d towers, damage table, economy and %d levels" % [ENEMIES.size(), TOWERS.size(), levels.size()])
	quit(0)


## Path builders. They return the corners of a path from the entrance (top) to the exit.
func _sine(center_x: float, amplitude: float, wavelength: float, y_from: float, y_to: float) -> Array:
	var points: Array = []
	var y := y_from
	while y <= y_to:
		points.append(Vector2(center_x + amplitude * sin(TAU * (y - y_from) / wavelength), y))
		y += 14.0
	points.append(Vector2(center_x + amplitude * sin(TAU * (y_to - y_from) / wavelength), y_to))
	return points


## A round spiral that starts at the top of the circle and winds inward, clockwise.
func _spiral(center: Vector2, radius_from: float, radius_to: float, turns: float) -> Array:
	var points: Array = []
	var steps := int(turns * 36.0)
	for i in steps + 1:
		var t := float(i) / steps
		var angle := -PI / 2.0 + TAU * turns * t
		var radius := lerpf(radius_from, radius_to, t)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


func _levels() -> Array:
	var spiral_5: Array = [Vector2(180, 40), Vector2(180, 100)]
	spiral_5.append_array(_spiral(Vector2(180, 470), 170.0, 50.0, 1.5))
	var path_10: Array = _sine(180.0, 90.0, 240.0, 40.0, 520.0)
	path_10.append_array([Vector2(180, 580), Vector2(60, 580), Vector2(60, 760), Vector2(300, 760), Vector2(300, 940),
		Vector2(60, 940), Vector2(60, 1120), Vector2(300, 1120), Vector2(300, 1300), Vector2(180, 1300)])
	var path_4: Array = [Vector2(180, 40)]
	path_4.append_array(_sine(180.0, 55.0, 170.0, 80.0, 930.0))
	path_4.append(Vector2(180, 980))
	return [
		{"number": 1, "name": "Throat", "part": "Nose and throat", "first": 1.0,
			"desc": "Viruses come in through the nose. Hold the line before they reach the lungs.",
			"music": "throat", "size": Vector2(360, 820), "path": LEVEL_1_PATH, "slots": LEVEL_1_SLOTS, "decor": "blobs",
			"colors": ["3a1f2b", "4d2a3a", "7a1d2e", "c4364f", "e8667d"], "amino": 150, "health": 20,
			"towers": ["macrophage", "mucus-cell", "interferon"], "disabled": ["chain"], "boss": "",
			"waves": [
				[5.0, 1.2, [["rhinovirus", 8]]],
				[50.0, 1.0, [["rhinovirus", 10], ["influenza", 4]]],
				[150.0, 0.9, [["influenza", 6], ["streptococcus-pyogenes", 4]]],
			]},
		{"number": 2, "name": "Trachea", "part": "The windpipe", "scale": 1.5, "squeeze": 0.8,
			"desc": "A long tube with the first coronaviruses and a chain of strep bacteria. The neutrophil and lysozyme join the fight.",
			"music": "trachea", "size": Vector2(360, 900),
			"path": [Vector2(180, 40), Vector2(180, 100), Vector2(70, 160), Vector2(290, 320), Vector2(70, 480), Vector2(290, 640),
				Vector2(70, 800), Vector2(180, 860)],
			"slot_count": 7, "decor": "rings", "colors": ["2a2438", "3a3350", "5b3b78", "a56ad8", "d2a8f2"],
			"amino": 250, "health": 20, "towers": ["macrophage", "mucus-cell", "interferon", "neutrophil", "lysozyme"],
			"disabled": [], "boss": "",
			"waves": [
				[5.0, 1.1, [["rhinovirus", 10], ["e-coli", 3]]],
				[45.0, 1.0, [["influenza", 8], ["e-coli", 5]]],
				[95.0, 1.0, [["sars-cov-2", 4], ["streptococcus-pyogenes", 3]]],
				[150.0, 0.9, [["influenza", 8], ["sars-cov-2", 5], ["streptococcus-pyogenes", 4]]],
			]},
		{"number": 3, "name": "Lungs", "part": "Lungs", "scale": 0.8,
			"desc": "Tuberculosis hides in the alveoli. Beat its heavy armor with chemical and heat attacks. First boss.",
			"music": "lungs", "size": Vector2(360, 920),
			"path": [Vector2(60, 140), Vector2(300, 140), Vector2(300, 860), Vector2(60, 860), Vector2(60, 260), Vector2(220, 260),
				Vector2(220, 740), Vector2(140, 740), Vector2(140, 400)],
			"slot_count": 8, "decor": "rings", "colors": ["3a2431", "5a3447", "7b3552", "e07a9c", "f5b3c8"],
			"amino": 270, "health": 20,
			"towers": ["macrophage", "mucus-cell", "interferon", "neutrophil", "lysozyme", "platelet", "hypothalamus"],
			"disabled": [], "boss": "mycobacterium-tuberculosis",
			"waves": [
				[5.0, 1.0, [["sars-cov-2", 5], ["staphylococcus-aureus", 4]]],
				[50.0, 0.9, [["influenza", 10], ["streptococcus-pyogenes", 4]]],
				[100.0, 0.9, [["sars-cov-2", 6], ["staphylococcus-aureus", 6], ["e-coli", 6]]],
				[165.0, 1.5, [["streptococcus-pyogenes", 4], ["sars-cov-2", 4], ["mycobacterium-tuberculosis", 1]]],
			]},
		{"number": 4, "name": "Esophagus", "part": "The food pipe", "scale": 0.6, "squeeze": 0.8,
			"desc": "A narrow, wavy tube. Herpes goes dormant and HPV wears a shell, so time your attacks. The T lymphocyte arrives.",
			"music": "esophagus", "size": Vector2(360, 1020), "path": path_4,
			"slot_count": 8, "decor": "stripes", "colors": ["3a2326", "52302f", "8a3b2e", "e0703f", "f4a77c"],
			"amino": 290, "health": 20,
			"towers": ["macrophage", "mucus-cell", "interferon", "neutrophil", "lysozyme", "platelet", "hypothalamus", "t-lymphocyte"],
			"disabled": [], "boss": "",
			"waves": [
				[5.0, 1.0, [["herpes-simplex", 6], ["rhinovirus", 8]]],
				[50.0, 1.0, [["hpv", 6], ["e-coli", 8]]],
				[100.0, 0.9, [["herpes-simplex", 8], ["hpv", 6], ["streptococcus-pyogenes", 4]]],
				[155.0, 0.8, [["hpv", 8], ["herpes-simplex", 8], ["influenza", 8]]],
			]},
		{"number": 5, "name": "Stomach", "part": "The stomach", "scale": 0.33, "squeeze": 0.8,
			"desc": "Acid everywhere. H. pylori laughs at slowing attacks, so build damage. The B lymphocyte joins.",
			"music": "stomach", "size": Vector2(360, 900), "path": spiral_5,
			"slot_count": 8, "decor": "blobs", "colors": ["35301c", "4a4424", "6f6a1d", "c8bd3b", "e6df7d"],
			"amino": 300, "health": 20,
			"towers": ["macrophage", "mucus-cell", "interferon", "neutrophil", "lysozyme", "platelet", "hypothalamus", "t-lymphocyte", "b-lymphocyte"],
			"disabled": [], "boss": "",
			"waves": [
				[5.0, 1.0, [["helicobacter-pylori", 6], ["e-coli", 8]]],
				[50.0, 0.9, [["helicobacter-pylori", 8], ["hpv", 6]]],
				[100.0, 0.9, [["staphylococcus-aureus", 8], ["herpes-simplex", 6], ["e-coli", 8]]],
				[150.0, 0.8, [["helicobacter-pylori", 10], ["hpv", 8], ["staphylococcus-aureus", 6]]],
				[205.0, 0.8, [["helicobacter-pylori", 10], ["herpes-simplex", 8], ["hpv", 8]]],
			]},
		{"number": 6, "name": "Intestines", "part": "The intestines", "scale": 0.66,
			"desc": "A long winding road. C. difficile spores come back from the dead. Bone Marrow now sends neutrophils to block the way.",
			"music": "intestines", "size": Vector2(360, 1250),
			"path": [Vector2(180, 40), Vector2(180, 100), Vector2(50, 100), Vector2(50, 250), Vector2(310, 250), Vector2(310, 400),
				Vector2(50, 400), Vector2(50, 550), Vector2(310, 550), Vector2(310, 700), Vector2(50, 700), Vector2(50, 850),
				Vector2(310, 850), Vector2(310, 1000), Vector2(50, 1000), Vector2(50, 1150), Vector2(180, 1150), Vector2(180, 1210)],
			"slot_count": 9, "decor": "stripes", "colors": ["40281f", "5a3828", "7a4a24", "d78a45", "f2c28a"],
			"amino": 320, "health": 20, "towers": ALL_TOWERS, "disabled": [], "boss": "",
			"waves": [
				[5.0, 1.0, [["clostridioides-difficile", 6], ["e-coli", 10]]],
				[50.0, 0.9, [["clostridioides-difficile", 8], ["staphylococcus-aureus", 6]]],
				[100.0, 0.9, [["e-coli", 12], ["sars-cov-2", 6], ["helicobacter-pylori", 6]]],
				[155.0, 0.8, [["clostridioides-difficile", 10], ["hpv", 6], ["streptococcus-pyogenes", 5]]],
				[210.0, 0.8, [["clostridioides-difficile", 12], ["staphylococcus-aureus", 8], ["e-coli", 10]]],
			]},
		{"number": 7, "name": "Bloodstream", "part": "The blood", "scale": 0.55,
			"desc": "The fast lane to every organ. Meningococcus rides the blood and splits in two when it is hurt. Second boss.",
			"music": "bloodstream", "size": Vector2(360, 1060), "path": _sine(180.0, 110.0, 440.0, 40.0, 1000.0),
			"slot_count": 9, "decor": "blobs", "colors": ["2f1620", "45202e", "8a1020", "e0243c", "ff8a98"],
			"amino": 340, "health": 20, "towers": ALL_TOWERS, "disabled": [], "boss": "neisseria-meningitidis",
			"waves": [
				[5.0, 0.9, [["staphylococcus-aureus", 8], ["influenza", 10]]],
				[50.0, 0.9, [["sars-cov-2", 8], ["hpv", 6]]],
				[100.0, 0.8, [["herpes-simplex", 8], ["clostridioides-difficile", 8], ["e-coli", 8]]],
				[155.0, 0.8, [["staphylococcus-aureus", 10], ["sars-cov-2", 8], ["streptococcus-pyogenes", 5]]],
				[215.0, 1.4, [["hpv", 6], ["herpes-simplex", 6], ["neisseria-meningitidis", 1]]],
			]},
		{"number": 8, "name": "Liver", "part": "The liver", "scale": 1.4,
			"desc": "Three long lanes through the liver. Expect a bit of everything, in numbers.",
			"music": "liver", "size": Vector2(360, 920),
			"path": [Vector2(60, 40), Vector2(60, 820), Vector2(180, 820), Vector2(180, 100), Vector2(300, 100), Vector2(300, 880)],
			"slot_count": 10, "decor": "blobs", "colors": ["2c1b1b", "4a2a22", "5a2418", "a8472f", "e08a6a"],
			"amino": 360, "health": 20, "towers": ALL_TOWERS, "disabled": [], "boss": "",
			"waves": [
				[5.0, 0.8, [["rhinovirus", 16], ["e-coli", 10], ["helicobacter-pylori", 6]]],
				[50.0, 0.8, [["herpes-simplex", 10], ["hpv", 8], ["staphylococcus-aureus", 6]]],
				[100.0, 0.7, [["clostridioides-difficile", 10], ["sars-cov-2", 8], ["influenza", 10]]],
				[155.0, 0.7, [["staphylococcus-aureus", 10], ["hpv", 10], ["streptococcus-pyogenes", 6]]],
				[215.0, 0.7, [["clostridioides-difficile", 12], ["herpes-simplex", 10], ["helicobacter-pylori", 10]]],
			]},
		{"number": 9, "name": "Spleen", "part": "The spleen", "scale": 1.73,
			"desc": "The immune system's filter is under siege. Every kind of invader attacks at once.",
			"music": "spleen", "size": Vector2(360, 960),
			"path": [Vector2(60, 40), Vector2(300, 40), Vector2(60, 220), Vector2(300, 220), Vector2(60, 400), Vector2(300, 400),
				Vector2(60, 580), Vector2(300, 580), Vector2(60, 760), Vector2(300, 760), Vector2(180, 900)],
			"slot_count": 10, "decor": "rings", "colors": ["2c1d3b", "40285a", "5a2a8a", "9a5ad8", "cfa8f5"],
			"amino": 380, "health": 20, "towers": ALL_TOWERS, "disabled": [], "boss": "",
			"waves": [
				[5.0, 0.8, [["influenza", 14], ["sars-cov-2", 8], ["e-coli", 10]]],
				[50.0, 0.8, [["hpv", 10], ["herpes-simplex", 10], ["staphylococcus-aureus", 8]]],
				[100.0, 0.7, [["clostridioides-difficile", 12], ["helicobacter-pylori", 10], ["streptococcus-pyogenes", 6]]],
				[155.0, 0.7, [["sars-cov-2", 12], ["hpv", 10], ["staphylococcus-aureus", 10]]],
				[210.0, 0.7, [["herpes-simplex", 12], ["clostridioides-difficile", 12], ["influenza", 14]]],
				[265.0, 0.6, [["hpv", 12], ["staphylococcus-aureus", 12], ["sars-cov-2", 10], ["helicobacter-pylori", 10]]],
			]},
		{"number": 10, "name": "Lymph Nodes", "part": "The lymphatic system", "scale": 0.99,
			"desc": "The last stand. HIV attacks the defenders themselves and switches off towers around it. Final boss.",
			"music": "lymph-nodes", "size": Vector2(360, 1360), "path": path_10,
			"slot_count": 11, "decor": "rings", "colors": ["1d2b33", "27414d", "1f6f8a", "46c0d8", "9be9f5"],
			"amino": 400, "health": 20, "towers": ALL_TOWERS, "disabled": [], "boss": "hiv",
			"waves": [
				[5.0, 0.8, [["sars-cov-2", 10], ["staphylococcus-aureus", 10], ["e-coli", 10]]],
				[55.0, 0.7, [["hpv", 12], ["herpes-simplex", 12], ["influenza", 12]]],
				[110.0, 0.7, [["clostridioides-difficile", 12], ["helicobacter-pylori", 10], ["streptococcus-pyogenes", 8]]],
				[170.0, 0.6, [["sars-cov-2", 12], ["hpv", 12], ["staphylococcus-aureus", 12]]],
				[230.0, 0.6, [["herpes-simplex", 14], ["clostridioides-difficile", 14], ["rhinovirus", 20]]],
				[290.0, 1.2, [["hpv", 10], ["staphylococcus-aureus", 10], ["hiv", 1]]],
			]},
	]


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
	e.trait_params = row.get("params", {})
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
	t.root_targets = int(row.get("root_targets", 0))
	t.beam_width = float(row.get("beam", 0))
	t.unit_radius = float(row.get("unit_radius", 0))
	t.unit_speed = float(row.get("unit_speed", 0))
	t.unit_regen = float(row.get("unit_regen", 0))
	t.dot_damage = float(row.get("dot", 0))
	t.dot_seconds = float(row.get("dot_seconds", 0))
	t.mark_bonus = float(row.get("mark", 0))
	t.mark_seconds = float(row.get("mark_seconds", 0))
	t.summon_interval = float(row.get("summon_interval", 0))
	t.summon_cap = int(row.get("summon_cap", 0))
	t.unit_health = float(row.get("unit_health", 0))
	t.unit_damage = float(row.get("unit_damage", 0))
	t.mark_targets = int(row.get("mark_targets", 0))
	t.mark_color = row.get("mark_color", Color.WHITE)
	t.mist_color = row.get("mist", Color(0, 0, 0, 0))
	t.sound_attack = "res://assets/audio/towers/%s/attack.wav" % row["id"]
	_save(t, "%s/%s.tres" % [TOWER_DIR, row["id"]])


func _save_difficulty(row: Dictionary) -> void:
	var d := DifficultyData.new()
	d.id = row["id"]
	d.display_name = row["name"]
	d.description = row["desc"]
	d.start_amino = row["start_amino"]
	d.body_health = row["body_health"]
	d.enemy_health = row["enemy_health"]
	d.enemy_speed = row["enemy_speed"]
	d.reward = row["reward"]
	d.wave_time = row["wave_time"]
	_save(d, "%s/%s.tres" % [DIFFICULTY_DIR, row["id"]])


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
	config.unlock_sound = "res://assets/audio/common/unlock.wav"
	_save(config, "res://data/audio.tres")


func _save_level(row: Dictionary) -> void:
	var level := LevelData.new()
	level.number = row["number"]
	level.id = "level_%d" % level.number
	level.display_name = row["name"]
	level.body_part = row["part"]
	level.description = row["desc"]
	level.music = "res://assets/audio/music/%s.wav" % row["music"]
	level.map_size = row["size"]
	var path := PackedVector2Array(row["path"])
	level.path_points = path
	if row.has("slots"):
		level.slots = PackedVector2Array(row["slots"])
	else:
		level.slots = _pick_slots(path, row["size"], int(row["slot_count"]))
	var colors: Array = row["colors"]
	level.background_color = Color(colors[0])
	level.tissue_color = Color(colors[1])
	level.path_edge_color = Color(colors[2])
	level.path_fill_color = Color(colors[3])
	level.path_dash_color = Color(colors[4])
	level.decor = row["decor"]
	level.starting_amino_acids = row["amino"]
	level.body_health = row["health"]
	level.tower_ids = row["towers"].duplicate()
	level.disabled_traits = row["disabled"].duplicate()
	level.boss_id = row["boss"]
	var waves: Array[WaveData] = []
	var scale: float = row.get("scale", 1.0)
	# The wave tuner (tools/tune_waves.py) sweeps this to find the scale each level needs.
	if OS.get_environment("BD_SCALE_MULT") != "" and level.number > 1:
		scale *= float(OS.get_environment("BD_SCALE_MULT"))
	## Squeezes the schedule: waves start sooner and release their enemies faster, so they overlap more.
	var squeeze: float = row.get("squeeze", 1.0)
	## The first wave of levels 2 to 10 comes a little later, so there is time to build.
	var delay: float = row.get("delay", 15.0 if level.number > 1 else 0.0)
	var wave_total: int = row["waves"].size()
	## The first wave is a share of the full size and the waves grow to 100% by the last one, so the
	## player has time to build before the field fills up.
	var first_share: float = row.get("first", 0.4)
	for wave_index in wave_total:
		var entry: Array = row["waves"][wave_index]
		var ramp := first_share + (1.0 - first_share) * pow(float(wave_index) / maxf(1.0, wave_total - 1.0), 0.7)
		var entries: Array = []
		for pair in entry[2]:
			var count: int = pair[1] if _is_boss(pair[0]) else maxi(1, roundi(pair[1] * scale * ramp))
			entries.append({"enemy": pair[0], "count": count})
		waves.append(_wave(5.0 + delay + (entry[0] - 5.0) * squeeze, maxf(0.6, entry[1] * squeeze), entries))
	level.waves = waves
	_save(level, "%s/level_%d.tres" % [LEVEL_DIR, level.number])


## Picks `count` tower slots that cover as much of the path as possible without covering the path itself.
func _pick_slots(path: PackedVector2Array, map_size: Vector2, count: int) -> PackedVector2Array:
	var samples := _sample_path(path, 12.0)
	var weights: Array[float] = []
	weights.resize(samples.size())
	weights.fill(1.0)
	var candidates: Array[Vector2] = []
	var y := 30.0
	while y <= map_size.y - 30.0:
		var x := 30.0
		while x <= map_size.x - 30.0:
			var point := Vector2(x, y)
			var distance := _distance_to_path(path, point)
			if distance >= SLOT_MIN_DISTANCE and distance <= SLOT_MAX_DISTANCE \
					and point.distance_to(path[0]) > 50.0 and point.distance_to(path[path.size() - 1]) > 50.0:
				candidates.append(point)
			x += 10.0
		y += 10.0
	var chosen := PackedVector2Array()
	for n in count:
		var best := Vector2.ZERO
		var best_score := -1.0
		for point in candidates:
			if _too_close(chosen, point):
				continue
			var score := 0.0
			for i in samples.size():
				if samples[i].distance_to(point) <= SLOT_REACH:
					score += weights[i]
			if score > best_score:
				best_score = score
				best = point
		if best_score < 0.0:
			break
		chosen.append(best)
		for i in samples.size():
			if samples[i].distance_to(best) <= SLOT_REACH:
				weights[i] *= 0.45
	return chosen


func _too_close(chosen: PackedVector2Array, point: Vector2) -> bool:
	for other in chosen:
		if other.distance_to(point) < SLOT_SPACING:
			return true
	return false


func _sample_path(path: PackedVector2Array, spacing: float) -> Array[Vector2]:
	var samples: Array[Vector2] = []
	for i in path.size() - 1:
		var length := path[i].distance_to(path[i + 1])
		var steps := maxi(1, int(length / spacing))
		for k in steps:
			samples.append(path[i].lerp(path[i + 1], float(k) / steps))
	samples.append(path[path.size() - 1])
	return samples


func _distance_to_path(path: PackedVector2Array, point: Vector2) -> float:
	var best := INF
	for i in path.size() - 1:
		best = minf(best, point.distance_to(Geometry2D.get_closest_point_to_segment(point, path[i], path[i + 1])))
	return best


func _is_boss(enemy_id: String) -> bool:
	for row in ENEMIES:
		if row["id"] == enemy_id:
			return row["role"] == "boss"
	return false


func _wave(start_time: float, interval: float, entries: Array) -> WaveData:
	var wave := WaveData.new()
	wave.start_time = start_time
	wave.spawn_interval = interval
	wave.entries = entries
	return wave
