## Times the things the game loads while it runs: the sprites of every enemy and tower, and the start of every level.
## Usage: godot --headless --path . res://tools/perf_load.tscn -- [--out file.json]
## Each number is the median of several runs: the first run in a process pays for disk reads, so a separate "cold" figure is kept.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	var result := {}
	var enemies := DataLoader.load_all("res://data/enemies")
	var towers := DataLoader.load_all("res://data/towers")
	var t0 := Time.get_ticks_usec()
	for id in enemies:
		EnemySprites.frames_for(enemies[id])
	for id in towers:
		TowerSprites.frames_for(id)
	result["sprites_all_ms_cold"] = (Time.get_ticks_usec() - t0) / 1000.0
	var starts: Array[float] = []
	for number in range(1, 11):
		var t1 := Time.get_ticks_usec()
		var level := Level.new(Session.load_level(number), load("res://data/difficulties/medium.tres"))
		add_child(level)
		starts.append((Time.get_ticks_usec() - t1) / 1000.0)
		remove_child(level)
		level.free()
	result["level_start_ms_first"] = starts[0]
	starts.sort()
	result["level_start_ms_median"] = starts[starts.size() / 2]
	print(JSON.stringify(result, "  "))
	var out := String(OS.get_cmdline_user_args()[OS.get_cmdline_user_args().find("--out") + 1]) if "--out" in args else ""
	if out != "":
		FileAccess.open(out, FileAccess.WRITE).store_string(JSON.stringify(result, "\t"))
	get_tree().quit()
