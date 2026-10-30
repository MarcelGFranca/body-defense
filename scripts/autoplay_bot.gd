## A simple bot that plays level 1: it builds towers in a fixed order whenever it can afford them.
## Used to verify the level end to end. Start the game with `-- --autoplay [--call-waves]`.
class_name AutoplayBot
extends Node

## Build order as [slot index, tower id].
const PLAN := [
	[1, "macrophage"], [2, "interferon"], [0, "macrophage"], [3, "mucus-cell"], [4, "macrophage"], [5, "interferon"],
]

var level: Level
var call_waves := false
var _next := 0


func _init(game_level: Level, should_call_waves: bool = false) -> void:
	level = game_level
	call_waves = should_call_waves
	level.victory.connect(func() -> void: _report("VICTORY"))
	level.defeat.connect(func() -> void: _report("DEFEAT"))


func _process(_delta: float) -> void:
	think()


## One decision step: build the next tower if affordable, call a wave if the field is clear.
func think() -> void:
	if level.state != "running":
		return
	if _next < PLAN.size():
		var step: Array = PLAN[_next]
		if level.build_tower(step[0], step[1]):
			_next += 1
	if call_waves and level.enemies.is_empty() and level.scheduler.time_to_next_wave() > 8.0:
		level.call_next_wave()


func _report(result: String) -> void:
	print("%s at level time %.1f s, body health %d/%d, amino acids %d" % [
		result, level.scheduler.clock, level.body_health, level.data.body_health, Economy.balance()])
	if "--autoplay" in OS.get_cmdline_user_args():
		get_tree().quit()
