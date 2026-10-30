## Saves screenshots of the towers attacking. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/tower_screenshots.tscn -- --out=/some/folder
extends Node

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
	level.build_tower(0, "macrophage")
	level.build_tower(1, "mucus-cell")
	level.scheduler.call_next_wave()
	for i in 14:
		level._spawn_enemy("rhinovirus" if i % 3 != 2 else "streptococcus-pyogenes")
		level.enemies[i].progress = 330.0 + i * 38.0
		level.enemies[i].step(0.0)
	for n in 5:
		for i in 25:
			await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png("%s/tower_%d.png" % [_out, n])
	get_tree().quit()
