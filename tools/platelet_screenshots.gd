## Saves screenshots of a platelet holding up to 3 enemies, one tendril each. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 --fixed-fps 60 res://tools/platelet_screenshots.tscn -- --out=/some/folder
extends Node

## Seconds after the enemy is caught at which a picture is taken.
const MOMENTS := [0.1, 0.5, 1.0, 1.15, 1.6]

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
	level.data.tower_ids.append("platelet")
	level.build_tower(2, "platelet")
	for i in 4:
		level._spawn_enemy("rhinovirus")
		level.enemies[i].progress = 835.0 + i * 14.0
		level.enemies[i].step(0.0)
	var elapsed := 0.0
	for n in MOMENTS.size():
		while elapsed < MOMENTS[n]:
			await get_tree().process_frame
			elapsed += 1.0 / 60.0
		get_viewport().get_texture().get_image().save_png("%s/platelet_%d.png" % [_out, n])
	get_tree().quit()
