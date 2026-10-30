## Saves screenshots of Bone Marrow neutrophils waiting, going to meet an enemy and holding it. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 --fixed-fps 60 res://tools/neutrophil_screenshots.tscn -- --out=/some/folder
extends Node

## Seconds at which a picture is taken. The enemy is sent at 1.0 s.
const MOMENTS := [0.3, 0.8, 1.2, 1.6, 2.2, 3.0]

var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	await get_tree().process_frame
	var level := Level.new(Session.load_level(6))
	add_child(level)
	add_child(Hud.new(level))
	Economy.reset(1000)
	level.build_tower(0, "bone-marrow")
	var elapsed := 0.0
	var sent := false
	for n in MOMENTS.size():
		while elapsed < MOMENTS[n]:
			await get_tree().process_frame
			elapsed += 1.0 / 60.0
			if not sent and elapsed >= 1.0:
				sent = true
				var home: BlockerUnit = level.blockers[0]
				level._spawn_enemy("rhinovirus")
				level.enemies[0].progress = home.home_offset - 60.0
		get_viewport().get_texture().get_image().save_png("%s/neutro_%d.png" % [_out, n])
	get_tree().quit()
