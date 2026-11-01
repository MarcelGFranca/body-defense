## Saves screenshots of crowded levels, the same way every time, so two versions of the game can be compared pixel by pixel
## (`tools/compare_shots.py`). Every slot gets a tower, the simulation runs by hand until a crowd is on the field, then it
## is frozen and a few frames are drawn. Needs a window: run it with xvfb-run.
## Usage: xvfb-run -a godot --path . --fixed-fps 60 res://tools/perf_shot.tscn -- --out DIR [--levels 3,9,10] [--crowd 25]
extends Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var out := String(_arg(args, "--out", "/tmp/shots"))
	var crowd := int(_arg(args, "--crowd", "25"))
	DirAccess.make_dir_recursive_absolute(out)
	GameAudio.set_muted(true)
	for entry in String(_arg(args, "--levels", "3,9,10")).split(","):
		await _shoot(int(entry), crowd, out)
	get_tree().quit()


func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	var at := args.find(name)
	return args[at + 1] if at >= 0 and at + 1 < args.size() else fallback


func _shoot(number: int, crowd: int, out: String) -> void:
	seed(7)
	var level := Level.new(Session.load_level(number), load("res://data/difficulties/medium.tres"))
	add_child(level)
	level.max_body_health = 1000000000
	level.body_health = level.max_body_health
	Economy.add(1000000)
	var hud := Hud.new(level)
	add_child(hud)
	var ids: Array = level.data.tower_ids
	for slot in level.data.slots.size():
		level.build_tower(slot, ids[slot % ids.size()])
	for i in 6000:
		level.step(1.0 / 60.0)
		if level.enemies.size() >= crowd:
			break
	# Hurt a few enemies so their bars show, and select a tower so its range ring shows.
	for i in level.enemies.size():
		if i % 3 == 0:
			level.enemies[i].health = level.enemies[i].max_health * (0.2 + 0.25 * (i % 4))
	level.set_selected_tower(0)
	level.set_process(false)
	for i in 20:
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	image.save_png("%s/level_%d.png" % [out, number])
	remove_child(hud)
	hud.free()
	remove_child(level)
	level.free()
	await get_tree().process_frame
