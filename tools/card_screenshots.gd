## Saves a screenshot of the tower card of each prototype tower. Needs a window (no --headless).
## Usage: godot --path . --resolution 1080x2400 res://tools/card_screenshots.tscn -- --out=/some/folder
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
	Economy.reset(1000)
	for id in ["macrophage", "mucus-cell", "interferon"]:
		level.build_tower(1, id)
		level.tower_tapped.emit(1)
		for i in 4:
			await get_tree().process_frame
		var card: Control = hud._popup.get_node("TowerCard")
		var ability: Label = card.get_node("Ability")
		print("%s: ability lines %d, label %.0f x %.0f (box 408 x 120), card %.0f wide" % [
			id, ability.get_line_count(), ability.size.x, ability.size.y, card.size.x])
		get_viewport().get_texture().get_image().save_png("%s/card_%s.png" % [_out, id])
		level.sell_tower(1)
		hud._dismiss_all()
	get_tree().quit()
