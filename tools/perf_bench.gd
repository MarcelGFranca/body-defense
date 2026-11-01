## Measures how long the level simulation takes, with every slot filled and an unbeatable body, so the cost of
## towers, enemies and effects shows at its worst. No rendering is involved: it times `Level.step` only.
## Usage: godot --headless --path . --fixed-fps 60 res://tools/perf_bench.tscn -- [--seconds 240] [--levels 3,5,10] [--out file.json]
## Prints one line per level and writes the numbers as JSON. The simulation is deterministic, so two runs
## differ only by machine noise: compare medians of several runs, never a single one.
extends Node

const STEP := 1.0 / 60.0


func _ready() -> void:
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	var seconds := float(_arg(args, "--seconds", "240"))
	var levels := String(_arg(args, "--levels", "1,2,3,4,5,6,7,8,9,10")).split(",")
	var report := {}
	var total_usec := 0
	var total_steps := 0
	for entry in levels:
		var number := int(entry)
		var result := _run(number, seconds)
		report[str(number)] = result
		total_usec += int(result["usec"])
		total_steps += int(result["steps"])
		print("level %2d  steps %6d  %6.1f us/step  peak enemies %3d  mean enemies %5.1f  towers %2d  state %s" % [
			number, result["steps"], result["us_per_step"], result["peak_enemies"], result["mean_enemies"], result["towers"], result["state"]])
	var summary := {"us_per_step": float(total_usec) / maxf(1.0, total_steps), "steps": total_steps}
	report["all"] = summary
	print("all      steps %6d  %6.1f us/step" % [total_steps, summary["us_per_step"]])
	var out := String(_arg(args, "--out", ""))
	if out != "":
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify(report, "\t"))
	get_tree().quit()


func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	var at := args.find(name)
	return args[at + 1] if at >= 0 and at + 1 < args.size() else fallback


func _run(number: int, seconds: float) -> Dictionary:
	var level := Level.new(Session.load_level(number), load("res://data/difficulties/medium.tres"))
	get_tree().root.add_child(level)
	level.max_body_health = 1000000000
	level.body_health = level.max_body_health
	Economy.add(1000000)
	var ids: Array = level.data.tower_ids
	for slot in level.data.slots.size():
		level.build_tower(slot, ids[slot % ids.size()])
	var steps := int(seconds / STEP)
	var done := 0
	var enemy_sum := 0
	var peak := 0
	var usec := 0
	for i in steps:
		var t0 := Time.get_ticks_usec()
		level.step(STEP)
		usec += Time.get_ticks_usec() - t0
		done += 1
		enemy_sum += level.enemies.size()
		peak = maxi(peak, level.enemies.size())
		if level.state != "running":
			break
	var result := {"steps": done, "usec": usec, "us_per_step": float(usec) / maxf(1.0, done), "peak_enemies": peak,
		"mean_enemies": float(enemy_sum) / maxf(1.0, done), "towers": level.towers.size(), "state": level.state}
	get_tree().root.remove_child(level)
	level.free()
	return result
