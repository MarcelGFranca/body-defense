## A simple bot that plays a level: it builds towers in a fixed order whenever it can afford them.
## Used to verify every level end to end. Start the game with `-- --autoplay [--level N] [--call-waves]`.
class_name AutoplayBot
extends Node

## Build order of level 1 as [slot index, tower id].
const PLAN := [
	[1, "macrophage"], [2, "interferon"], [0, "macrophage"], [3, "mucus-cell"], [4, "macrophage"], [5, "interferon"],
]
## Towers the bot likes, best first. Bacteria-heavy levels swap the first two.
const PREFERENCE := ["macrophage", "interferon", "lysozyme", "hypothalamus", "t-lymphocyte", "mucus-cell",
	"neutrophil", "b-lymphocyte", "platelet", "bone-marrow"]
const REACH := 85.0

var level: Level
var call_waves := false
var plan: Array = []
var _next := 0


func _init(game_level: Level, should_call_waves: bool = false) -> void:
	level = game_level
	call_waves = should_call_waves
	plan = PLAN if level.data.number == 1 else build_plan(level)
	level.victory.connect(func() -> void: _report("VICTORY"))
	level.defeat.connect(func() -> void: _report("DEFEAT"))


func _process(_delta: float) -> void:
	think()


## One decision step: build the next tower if affordable, call a wave if the field is clear.
func think() -> void:
	if level.state != "running":
		return
	if _next < plan.size():
		var step: Array = plan[_next]
		if level.build_tower(step[0], step[1]):
			_next += 1
	if call_waves and level.enemies.is_empty() and level.scheduler.time_to_next_wave() > 8.0:
		level.call_next_wave()


## Slots from the one that sees most of the path to the one that sees least, each with a different tower.
static func build_plan(game_level: Level) -> Array:
	var data := game_level.data
	var curve := Curve2D.new()
	for point in data.path_points:
		curve.add_point(point)
	var samples: Array[Vector2] = []
	var length := curve.get_baked_length()
	var at := 0.0
	while at < length:
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
	var order: Array = PREFERENCE.filter(func(id: String) -> bool: return data.tower_ids.has(id))
	if _bacteria_share(game_level) > 0.55 and order.has("lysozyme"):
		order.erase("lysozyme")
		order.insert(0, "lysozyme")
	var result: Array = []
	for rank in ranked.size():
		result.append([ranked[rank][0], order[rank % order.size()]])
	return result


static func _bacteria_share(game_level: Level) -> float:
	var bacteria := 0
	var total := 0
	for wave in game_level.data.waves:
		for entry in wave.entries:
			var enemy: EnemyData = game_level.enemy_catalog.get(entry["enemy"])
			total += int(entry["count"])
			if enemy != null and enemy.type == "bacterium":
				bacteria += int(entry["count"])
	return float(bacteria) / maxf(1.0, float(total))


func _report(result: String) -> void:
	print("%s at level time %.1f s, body health %d/%d, amino acids %d" % [
		result, level.scheduler.clock, level.body_health, level.data.body_health, Economy.balance()])
	if "--autoplay" in OS.get_cmdline_user_args():
		get_tree().quit()
