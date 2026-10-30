## Validates the enemy, tower and level data. Exits with 1 when there are errors.
## Usage: godot --headless --path . --script res://tools/validate_data.gd
extends SceneTree


func _initialize() -> void:
	var result := DataValidator.validate_all()
	for warning in result["warnings"]:
		print("warning: %s" % warning)
	for error in result["errors"]:
		printerr("error: %s" % error)
	if result["errors"].is_empty():
		print("data is valid (%d warnings)" % result["warnings"].size())
	quit(1 if not result["errors"].is_empty() else 0)
