## Saves screenshots of the main HUD states. Needs a window (no --headless).
## Usage: godot --path . --resolution 720x1280 res://tools/ui_screenshots.tscn -- --out=/some/folder
extends Node

var _out := "/tmp"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	await get_tree().process_frame
	var level := Level.new()
	add_child(level)
	var hud := Hud.new(level)
	add_child(hud)
	await _shot("1_start")
	level.slot_tapped.emit(1)
	await _shot("2_build_menu")
	hud._popup.get_node("BuildMenu").get_node("Card_macrophage").pressed.emit()
	level.slot_tapped.emit(2)
	await _shot("3_build_menu_after_one_tower")
	Economy.reset(10)
	hud._popup.get_node("BuildMenu").get_node("Card_interferon").pressed.emit()
	await _shot("4_not_enough")
	hud._dismiss_all()
	Economy.reset(150)
	level.tower_tapped.emit(1)
	await _shot("5_sell_menu")
	hud._dismiss_all()
	for i in 6:
		level._spawn_enemy("streptococcus-pyogenes")
		level.enemies[level.enemies.size() - 1].progress = 200.0 + i * 40.0
	level.enemies[0].step(0.0)
	for e in level.enemies:
		e.step(0.0)
	level.enemy_tapped.emit(level.enemies[0])
	await _shot("6_enemy_card")
	hud._dismiss_all()
	level.toggle_speed()
	hud._pause_button.pressed.emit()
	await _shot("7_pause_2x")
	hud._overlay.find_children("*", "Button", true, false)[0].pressed.emit()
	level.toggle_speed()
	level.state = "running"
	level.defeat.emit()
	await _shot("8_defeat")
	get_tree().quit()


func _shot(name: String) -> void:
	for i in 4:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [_out, name])
