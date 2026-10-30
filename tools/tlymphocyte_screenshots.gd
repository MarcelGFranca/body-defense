## Saves screenshots of a T lymphocyte charging, firing its beam and the explosion. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 --fixed-fps 60 res://tools/tlymphocyte_screenshots.tscn -- --out=/some/folder
extends Node

## Seconds after the first shot at which a picture is taken.
const MOMENTS := [0.05, 0.15, 0.3, 0.6, 1.2, 1.8, 2.1]

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
	level.data.tower_ids.append("t-lymphocyte")
	level.build_tower(2, "t-lymphocyte")
	level._spawn_enemy("hpv")
	level.enemies[0].progress = 850.0
	level.enemies[0].speed = 0.0
	level.enemies[0].health = 100000.0
	level.enemies[0].max_health = 100000.0
	level.enemies[0].step(0.0)
	level.scroll_by(Vector2(0, 90))
	var elapsed := 0.0
	for n in MOMENTS.size():
		while elapsed < MOMENTS[n]:
			await get_tree().process_frame
			elapsed += 1.0 / 60.0
		get_viewport().get_texture().get_image().save_png("%s/tlymph_%d.png" % [_out, n])
	get_tree().quit()
