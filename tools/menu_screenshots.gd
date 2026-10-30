## Saves screenshots of the start screen pages. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/menu_screenshots.tscn -- --out=/some/folder
extends Node

var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	var splash: Control = load("res://scenes/splash.tscn").instantiate()
	add_child(splash)
	await get_tree().create_timer(1.5).timeout
	await _shot("splash")
	splash.queue_free()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _shot("menu_1_start")
	menu._open_tutorial(1)
	await _shot("menu_3_tutorial")
	menu._open_tutorial(5)
	await _shot("menu_4_tutorial_last")
	menu._open_settings()
	await _shot("menu_2_settings")
	Session.language = "ja"
	Localization.apply("ja")
	menu._open_languages()
	await _shot("menu_5_languages")
	menu._close_languages()
	menu._open_tutorial(1)
	await _shot("menu_6_tutorial_ja")
	Localization.apply("en")
	get_tree().quit()


func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [_out, name])
