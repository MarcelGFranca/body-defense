## Plays every level with the bot and with no towers, and prints the results, to tune the balance.
## Usage: godot --headless --path . --fixed-fps 60 res://tools/balance_probe.tscn [-- --level N]
extends Node

const MAX_SECONDS := 700.0


func _ready() -> void:
	await get_tree().process_frame
	var only := 0
	var args := OS.get_cmdline_user_args()
	if "--level" in args:
		only = int(args[args.find("--level") + 1])
	for number in range(1, Session.LEVEL_COUNT + 1):
		if only != 0 and number != only:
			continue
		for plan_name in ["no towers", "bot", "bot, half money"]:
			_play(number, plan_name)
	get_tree().quit()


func _play(number: int, plan_name: String) -> void:
	var level := Level.new(Session.load_level(number))
	get_tree().root.add_child(level)
	var plan: Array = [] if plan_name == "no towers" else AutoplayBot.build_plan(level)
	if plan_name == "bot, half money":
		Economy.reset(level.data.starting_amino_acids / 2)
	var next := 0
	var leaks := 0
	level.body_health_changed.connect(func(_v: int, _m: int) -> void: leaks += 1)
	for i in int(MAX_SECONDS / 0.05):
		level.step(0.05)
		if next < plan.size() and level.build_tower(plan[next][0], plan[next][1]):
			next += 1
		if level.state != "running":
			break
	print("L%-2d %-10s %-16s %-7s health %2d/%d  built %2d/%2d  time %5.1f s  wave %d/%d  amino %d" % [
		number, level.data.display_name, plan_name, level.state, level.body_health, level.data.body_health,
		next, plan.size(), level.scheduler.clock, level.scheduler.started_count(), level.data.waves.size(), Economy.balance()])
	get_tree().root.remove_child(level)
	level.free()
