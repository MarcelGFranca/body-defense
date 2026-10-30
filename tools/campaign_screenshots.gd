## Saves screenshots of the menu and of several levels in play. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/campaign_screenshots.tscn -- --out=/some/folder
extends Node

var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	await get_tree().process_frame
	Session.save_path = "user://screenshot_progress.cfg"
	Session.best_health = {1: 16, 2: 20, 3: 14}
	var menu: Control = load("res://game/menu.tscn").instantiate()
	add_child(menu)
	await _shot("menu")
	menu.find_child("Level_4", true, false).pressed.emit()
	await _shot("menu_detail")
	menu.find_child("SettingsButton", true, false).pressed.emit()
	await _shot("menu_settings")
	menu.queue_free()
	for number in [2, 3, 5, 7, 8, 10]:
		await _play(number)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://screenshot_progress.cfg"))
	get_tree().quit()


func _play(number: int) -> void:
	var level := Level.new(Session.load_level(number))
	add_child(level)
	var hud := Hud.new(level)
	add_child(hud)
	Economy.reset(2000)
	var plan := AutoplayBot.build_plan(level)
	for step in plan:
		level.build_tower(step[0], step[1])
	var first := level.curve.get_baked_length() * 0.3
	for id in level.data.waves[0].entries.map(func(e: Dictionary) -> String: return e["enemy"]):
		level._spawn_enemy(id)
	for i in level.enemies.size():
		level.enemies[i].progress = first + i * 22.0
		level.enemies[i].step(0.0)
	for i in 120:
		level.step(0.05)
	await _shot("level_%d" % number)
	level.set_scroll(Vector2(0, level.data.map_size.y))
	await _shot("level_%d_bottom" % number)
	hud.queue_free()
	level.queue_free()
	await get_tree().process_frame


func _shot(shot_name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [_out, shot_name])
