## Saves screenshots of enemies marked by a B lymphocyte taking on its color. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 --fixed-fps 60 res://tools/blymphocyte_screenshots.tscn -- --out=/some/folder
extends Node

## Seconds after the first release at which a picture is taken.
const MOMENTS := [0.05, 0.4, 4.7, 5.0, 6.0]

var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	await get_tree().process_frame
	var level := Level.new()
	add_child(level)
	add_child(Hud.new(level))
	Economy.reset(1000)
	level.data.tower_ids.append("b-lymphocyte")
	level.build_tower(2, "b-lymphocyte")
	for i in 6:
		level._spawn_enemy("rhinovirus" if i % 2 == 0 else "e-coli")
		level.enemies[i].progress = 800.0 + i * 22.0
		level.enemies[i].speed = 0.0
		level.enemies[i].health = 100000.0
		level.enemies[i].max_health = 100000.0
		level.enemies[i].step(0.0)
	level.scroll_by(Vector2(0, 90))
	var elapsed := 0.0
	for n in MOMENTS.size():
		while elapsed < MOMENTS[n]:
			await get_tree().process_frame
			elapsed += 1.0 / 60.0
		get_viewport().get_texture().get_image().save_png("%s/blymph_%d.png" % [_out, n])
	get_tree().quit()
