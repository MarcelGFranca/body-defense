## Which level is being played and how far the player has got. Registered as the `Session` autoload.
## Progress is saved on the device, so a level opens only after the one before it was won.
extends Node

signal progress_changed

const LEVEL_COUNT := 10
const LEVEL_PATH_FORMAT := "res://data/levels/level_%d.tres"
const SAVE_PATH := "user://progress.cfg"
const LEVEL_SCENE := "res://scenes/main.tscn"
const MENU_SCENE := "res://scenes/menu.tscn"

var current_level := 1
## Level number -> the most body health left after winning it.
var best_health: Dictionary = {}
var save_path := SAVE_PATH


func _ready() -> void:
	load_progress()


func load_level(number: int) -> LevelData:
	return load(LEVEL_PATH_FORMAT % clampi(number, 1, LEVEL_COUNT)) as LevelData


func is_completed(number: int) -> bool:
	return best_health.has(number)


func is_unlocked(number: int) -> bool:
	return number == 1 or is_completed(number - 1)


## The level after the highest one that was won, or the last level once the game is done.
func next_to_play() -> int:
	for number in range(1, LEVEL_COUNT + 1):
		if not is_completed(number):
			return number
	return LEVEL_COUNT


func has_next(number: int) -> bool:
	return number < LEVEL_COUNT


func record_victory(number: int, body_health: int) -> void:
	best_health[number] = maxi(int(best_health.get(number, 0)), body_health)
	save_progress()
	progress_changed.emit()


func reset_progress() -> void:
	best_health.clear()
	save_progress()
	progress_changed.emit()


func save_progress() -> void:
	var file := ConfigFile.new()
	for number in best_health:
		file.set_value("best_health", str(number), int(best_health[number]))
	file.save(save_path)


func load_progress() -> void:
	best_health.clear()
	var file := ConfigFile.new()
	if file.load(save_path) != OK:
		return
	if file.has_section("best_health"):
		for key in file.get_section_keys("best_health"):
			best_health[int(key)] = int(file.get_value("best_health", key))


func start_level(number: int) -> void:
	current_level = clampi(number, 1, LEVEL_COUNT)
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(LEVEL_SCENE)


func open_menu() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(MENU_SCENE)
