## Saves screenshots of every story (levels 1 to 10 and the ending) at key moments. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/intro_screenshots.tscn -- --out=/some/folder [--story=N]
extends Node

const MOMENTS := [1.5, 3.2, 4.0, 6.6, 9.0]
var _out := "/tmp"
var _only := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--story="):
			_only = int(arg.trim_prefix("--story="))
	for story in LevelIntro.STORIES:
		if _only != 0 and story != _only:
			continue
		Session.intro_story = story
		var intro: LevelIntro = load("res://game/intro.tscn").instantiate()
		add_child(intro)
		intro.set_process(false)
		for moment: float in MOMENTS:
			while intro.clock < moment:
				intro.step(1.0 / 60.0)
			await RenderingServer.frame_post_draw
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/story%d_%.1f.png" % [_out, story, moment])
		intro.queue_free()
		await get_tree().process_frame
	get_tree().quit()
