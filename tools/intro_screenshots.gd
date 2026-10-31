## Saves screenshots of the level 1 intro at key moments. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/intro_screenshots.tscn -- --out=/some/folder
extends Node

const MOMENTS := [2.0, 4.3, 4.9, 5.2, 5.9, 6.7, 8.8, 10.5]
var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	var intro: LevelIntro = load("res://game/intro.tscn").instantiate()
	add_child(intro)
	for moment: float in MOMENTS:
		while intro.clock < moment:
			intro.step(1.0 / 60.0)
		await RenderingServer.frame_post_draw
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/intro_%.1f.png" % [_out, moment])
	get_tree().quit()
