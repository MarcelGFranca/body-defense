## Plays many games with bots that build in different ways and records everything that happened.
## Usage: godot --headless --path . --fixed-fps 60 res://tools/playtest.tscn -- --games 100 --out res://playtests/round_1 [--difficulty medium] [--level N]
## Writes games.jsonl (one game per line) and summary.csv in the output folder.
extends Node

const STEP := 0.05
const MAX_SECONDS := 900.0
const STRATEGIES := ["smart", "smart_calls", "damage_only", "random_a", "random_b", "cheap", "support_heavy",
	"worst_slots", "balanced_mix", "few_strong"]
const DAMAGE_TOWERS := ["macrophage", "neutrophil", "lysozyme", "hypothalamus", "t-lymphocyte", "interferon", "b-lymphocyte"]
const SUPPORT_TOWERS := ["mucus-cell", "platelet", "bone-marrow", "b-lymphocyte", "macrophage", "interferon"]
const REACH := 85.0

## Humans are not perfect: with noise on, a bot builds a little late, sometimes picks another tower and
## sometimes swaps the order of two slots. The same strategy then plays differently every time.
var noise := true


func _ready() -> void:
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	var games := int(_arg(args, "--games", "100"))
	var out := String(_arg(args, "--out", "res://playtests/latest"))
	var difficulty_id := String(_arg(args, "--difficulty", "medium"))
	var only_level := int(_arg(args, "--level", "0"))
	var first := int(_arg(args, "--from", "0"))
	noise = _arg(args, "--noise", "1") == "1"
	var difficulty: DifficultyData = load("res://data/difficulties/%s.tres" % difficulty_id)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var lines := PackedStringArray()
	var csv := PackedStringArray(["game,level,strategy,difficulty,result,health,health_max,time,amino_end,amino_spent,leaks,first_leak_time"])
	for index in range(first, first + games):
		var number := only_level if only_level != 0 else index % 10 + 1
		var strategy: String = STRATEGIES[(index / 10 if only_level == 0 else index) % STRATEGIES.size()]
		var record := _play(index, number, strategy, difficulty)
		lines.append(JSON.stringify(record))
		var leaks := 0
		for id in record["leaks"]:
			leaks += int(record["leaks"][id])
		csv.append("%d,%d,%s,%s,%s,%d,%d,%.1f,%d,%d,%d,%.1f" % [index, number, strategy, difficulty_id, record["result"],
			record["health"], record["health_max"], record["time"], record["amino_end"], record["amino_spent"], leaks,
			record["first_leak_time"]])
	_write("%s/games.jsonl" % out, "\n".join(lines) + "\n")
	_write("%s/summary.csv" % out, "\n".join(csv) + "\n")
	print("wrote %d games to %s" % [games, out])
	get_tree().quit()


func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	var at := args.find(name)
	return args[at + 1] if at >= 0 and at + 1 < args.size() else fallback


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)


func _play(index: int, number: int, strategy: String, difficulty: DifficultyData) -> Dictionary:
	var level := Level.new(Session.load_level(number), difficulty)
	get_tree().root.add_child(level)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000 + index
	var plan := _plan(level, strategy, rng)
	if noise:
		plan = _jitter(level, plan, rng)
	var next_allowed := rng.randf_range(0.0, 8.0) if noise else 0.0
	var call_waves := strategy == "smart_calls"
	var next := 0
	var built := 0
	for i in int(MAX_SECONDS / STEP):
		level.step(STEP)
		if next < plan.size() and level.scheduler.clock >= next_allowed and level.build_tower(plan[next][0], plan[next][1]):
			next += 1
			built += 1
			if noise:
				next_allowed = level.scheduler.clock + rng.randf_range(0.0, 5.0)
		if call_waves and level.enemies.is_empty() and level.scheduler.time_to_next_wave() > 8.0:
			level.call_next_wave()
		if level.state != "running":
			break
	var stats := level.stats
	var waves := {}
	for wave_index in level.data.waves.size():
		var w: Dictionary = stats.waves.get(wave_index, {"kills": 0, "leaks": 0, "first_spawn": -1.0, "last_end": -1.0})
		waves[str(wave_index)] = w
	var record := {
		"game": index, "level": number, "level_name": level.data.display_name, "strategy": strategy,
		"difficulty": difficulty.id, "result": level.state, "health": level.body_health, "health_max": level.max_body_health,
		"time": snappedf(level.scheduler.clock, 0.1), "amino_end": Economy.balance(), "amino_spent": stats.amino_spent,
		"towers_planned": plan.size(), "towers_built": stats.towers_built, "kills": stats.kills, "leaks": stats.leaks,
		"damage_by_tower": _rounded(stats.damage_by_source), "kills_by_tower": stats.kills_by_source,
		"first_leak_time": snappedf(stats.first_leak_time, 0.1), "waves": waves,
	}
	get_tree().root.remove_child(level)
	level.free()
	return record


func _jitter(level: Level, plan: Array, rng: RandomNumberGenerator) -> Array:
	var result := plan.duplicate(true)
	for i in result.size():
		if rng.randf() < 0.15:
			result[i][1] = level.data.tower_ids[rng.randi_range(0, level.data.tower_ids.size() - 1)]
		if i + 1 < result.size() and rng.randf() < 0.25:
			var slot = result[i][0]
			result[i][0] = result[i + 1][0]
			result[i + 1][0] = slot
	return result


func _rounded(source: Dictionary) -> Dictionary:
	var out := {}
	for key in source:
		out[key] = roundi(source[key])
	return out


# --- build plans -------------------------------------------------------------

func _ranked_slots(level: Level) -> Array:
	var data := level.data
	var curve := Curve2D.new()
	for point in data.path_points:
		curve.add_point(point)
	var samples: Array[Vector2] = []
	var at := 0.0
	while at < curve.get_baked_length():
		samples.append(curve.sample_baked(at))
		at += 12.0
	var ranked: Array = []
	for i in data.slots.size():
		var seen := 0
		for sample in samples:
			if sample.distance_to(data.slots[i]) <= REACH:
				seen += 1
		ranked.append([i, seen])
	ranked.sort_custom(func(a: Array, b: Array) -> bool: return a[1] > b[1])
	return ranked.map(func(r: Array) -> int: return r[0])


func _available(level: Level, wanted: Array) -> Array:
	return wanted.filter(func(id: String) -> bool: return level.data.tower_ids.has(id))


func _plan(level: Level, strategy: String, rng: RandomNumberGenerator) -> Array:
	var slots := _ranked_slots(level)
	var plan: Array = []
	match strategy:
		"smart", "smart_calls":
			return AutoplayBot.build_plan(level)
		"damage_only":
			var order := _available(level, DAMAGE_TOWERS)
			for rank in slots.size():
				plan.append([slots[rank], order[rank % order.size()]])
		"random_a", "random_b":
			var shuffled := slots.duplicate()
			for i in range(shuffled.size() - 1, 0, -1):
				var j := rng.randi_range(0, i)
				var tmp = shuffled[i]
				shuffled[i] = shuffled[j]
				shuffled[j] = tmp
			for slot in shuffled:
				plan.append([slot, level.data.tower_ids[rng.randi_range(0, level.data.tower_ids.size() - 1)]])
		"cheap":
			var cheapest: String = level.data.tower_ids[0]
			for id in level.data.tower_ids:
				if level.tower_catalog[id].cost < level.tower_catalog[cheapest].cost:
					cheapest = id
			for slot in slots:
				plan.append([slot, cheapest])
		"support_heavy":
			var order := _available(level, SUPPORT_TOWERS)
			for rank in slots.size():
				plan.append([slots[rank], order[rank % order.size()]])
		"worst_slots":
			var reversed := slots.duplicate()
			reversed.reverse()
			var order := _available(level, AutoplayBot.PREFERENCE)
			for rank in reversed.size():
				plan.append([reversed[rank], order[rank % order.size()]])
		"balanced_mix":
			var order := _available(level, ["macrophage", "interferon", "lysozyme", "macrophage", "mucus-cell", "hypothalamus"])
			for rank in slots.size():
				plan.append([slots[rank], order[rank % order.size()]])
		"few_strong":
			var order := _available(level, ["t-lymphocyte", "hypothalamus", "macrophage", "lysozyme", "interferon"])
			for rank in ceili(slots.size() / 2.0):
				plan.append([slots[rank], order[rank % order.size()]])
	return plan
