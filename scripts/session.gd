## Which level is being played and how far the player has got. Registered as the `Session` autoload.
## Progress is saved on the device, so a level opens only after the one before it was won.
extends Node

signal progress_changed

const LEVEL_COUNT := 10
const LEVEL_PATH_FORMAT := "res://data/levels/level_%d.tres"
const SAVE_PATH := "user://progress.cfg"
const DIFFICULTY_IDS := ["easy", "medium", "hard"]
const DIFFICULTY_PATH_FORMAT := "res://data/difficulties/%s.tres"
const LEVEL_SCENE := "res://scenes/main.tscn"
const MENU_SCENE := "res://scenes/menu.tscn"

var current_level := 1
## Level number -> the most body health left after winning it.
var best_health: Dictionary = {}
var save_path := SAVE_PATH
## "easy", "medium" or "hard": chosen in the settings and saved on the device.
var difficulty := "medium"
## A code from Localization.LANGUAGES, chosen on the start screen and saved on the device.
var language := "en"
## Set by the secret tap code in the menu. It is not saved: it lasts until the game is closed.
var all_levels_open := false
## The secret tap code also turns on the debug aids (the FPS readout).
var debug_mode: bool:
	get:
		return all_levels_open


func _ready() -> void:
	Localization.prepare_font()
	var first_run := not FileAccess.file_exists(save_path)
	load_progress()
	if first_run:
		language = Localization.from_os()
	Localization.apply(language)


func load_level(number: int) -> LevelData:
	return load(LEVEL_PATH_FORMAT % clampi(number, 1, LEVEL_COUNT)) as LevelData


func difficulty_data() -> DifficultyData:
	return load_difficulty(difficulty)


func load_difficulty(id: String) -> DifficultyData:
	return load(DIFFICULTY_PATH_FORMAT % id) as DifficultyData


func set_difficulty(id: String) -> void:
	if not DIFFICULTY_IDS.has(id):
		return
	difficulty = id
	save_progress()
	progress_changed.emit()


func set_language(code: String) -> void:
	if not Localization.is_supported(code):
		return
	language = code
	Localization.apply(code)
	save_progress()
	progress_changed.emit()


func is_completed(number: int) -> bool:
	return best_health.has(number)


func is_unlocked(number: int) -> bool:
	return all_levels_open or number == 1 or is_completed(number - 1)


func open_all_levels() -> void:
	all_levels_open = true
	progress_changed.emit()


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
	file.set_value("settings", "difficulty", difficulty)
	file.set_value("settings", "language", language)
	file.set_value("settings", "music_volume", GameAudio.music_volume)
	file.set_value("settings", "sfx_volume", GameAudio.sfx_volume)
	file.set_value("settings", "muted", GameAudio.muted)
	file.save(save_path)


func load_progress() -> void:
	best_health.clear()
	difficulty = "medium"
	language = "en"
	GameAudio.set_music_volume(1.0)
	GameAudio.set_sfx_volume(1.0)
	GameAudio.set_muted(false)
	var file := ConfigFile.new()
	if file.load(save_path) != OK:
		return
	var saved_language := String(file.get_value("settings", "language", "en"))
	language = saved_language if Localization.is_supported(saved_language) else "en"
	GameAudio.set_music_volume(float(file.get_value("settings", "music_volume", 1.0)))
	GameAudio.set_sfx_volume(float(file.get_value("settings", "sfx_volume", 1.0)))
	GameAudio.set_muted(bool(file.get_value("settings", "muted", false)))
	var saved := String(file.get_value("settings", "difficulty", "medium"))
	difficulty = saved if DIFFICULTY_IDS.has(saved) else "medium"
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
