## Plays level 1 with several build plans and prints the results, to tune the balance.
## Usage: godot --headless --path . --fixed-fps 60 res://tools/balance_probe.tscn
extends Node

const PLANS := {
	"no towers": [],
	"1 macrophage": [[1, "macrophage"]],
	"2 macrophages": [[1, "macrophage"], [3, "macrophage"]],
	"macrophage + interferon": [[1, "macrophage"], [2, "interferon"]],
	"macrophage + mucus": [[1, "macrophage"], [4, "mucus-cell"]],
	"3 macrophages": [[1, "macrophage"], [3, "macrophage"], [5, "macrophage"]],
	"bot plan": [[1, "macrophage"], [2, "interferon"], [3, "macrophage"], [4, "mucus-cell"], [5, "macrophage"], [0, "interferon"]],
}


func _ready() -> void:
	await get_tree().process_frame
	for plan_name in PLANS:
		var level := Level.new()
		get_tree().root.add_child(level)
		var plan: Array = PLANS[plan_name]
		var next := 0
		var leaks := 0
		level.body_health_changed.connect(func(_v: int, _m: int) -> void: leaks += 1)
		for i in int(400.0 / 0.05):
			level.step(0.05)
			if next < plan.size() and level.build_tower(plan[next][0], plan[next][1]):
				next += 1
			if level.state != "running":
				break
		print("%-26s %s  health %2d/20  built %d/%d  time %5.1f s" % [
			plan_name, level.state, level.body_health, next, plan.size(), level.scheduler.clock])
		get_tree().root.remove_child(level)
		level.free()
	get_tree().quit()
