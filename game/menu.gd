## The level menu: ten levels in a list, locked until the one before is won. Tap one to see it and start it.
## `-- --autoplay [--level N]` skips the menu and lets the bot play.
extends Control

const SCREEN := Vector2(720, 1280)
const CARD_SIZE := Vector2(640, 128)
const MIN_TAP := 96.0
## Finger travel, in pixels, after which a press on the level list becomes a scroll.
const DRAG_THRESHOLD := 16.0
const HERO_ROW_Y := 252.0
## Secret code on the two fighters: enemy three times, tower twice, enemy once. It opens every level.
const SECRET_CODE := ["enemy", "enemy", "enemy", "tower", "tower", "enemy"]
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const COLOR_BG := Color("2b1b3a")
const COLOR_BORDER := Color("ffb3c7")
const COLOR_TEXT := Color("fff2f6")
const COLOR_DIM := Color("9b8aa6")
const COLOR_BAD := Color("e84a5f")
const COLOR_GOOD := Color("6ad4a0")
const COLOR_GOLD := Color("f4d35e")

var _list: VBoxContainer
var _scroll: ScrollContainer
var _detail: Control

var _settings: Control
var _tutorial: Control
var _languages: Control
## Dragging the level list: the buttons inside it swallow touches, so the menu scrolls it by hand.
var _press_in_list := false
var _dragging := false
var _drag_travel := 0.0
var _reset_armed := false
var _taps: Array[String] = []
var _levels: Array[LevelData] = []
var _enemy_catalog: Dictionary = {}


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--autoplay" in args:
		var number := 1
		if "--level" in args and args.find("--level") + 1 < args.size():
			number = int(args[args.find("--level") + 1])
		call_deferred("_start", number)
		return
	for number in range(1, Session.LEVEL_COUNT + 1):
		_levels.append(Session.load_level(number))
	_enemy_catalog = DataLoader.load_all("res://data/enemies")
	var theme := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		theme.default_font = load(FONT_PATH)
	theme.default_font_size = 20
	self.theme = theme
	_build()
	Session.progress_changed.connect(_refresh)
	GameAudio.play_music(_levels[0].music)


func _exit_tree() -> void:
	GameAudio.stop_music(0.0)


func _start(number: int) -> void:
	Session.start_level(number)


func _build() -> void:
	var background := ColorRect.new()
	background.color = Color("3a1f2b")
	background.size = SCREEN
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("BODY DEFENSE", 44, COLOR_GOLD)
	title.position = Vector2(0, 60)
	title.size = Vector2(SCREEN.x, 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var tagline := _label(tr("DEFEND THE HUMAN BODY"), 18, COLOR_BORDER)
	tagline.position = Vector2(0, 136)
	tagline.size = Vector2(SCREEN.x, 26)
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(tagline)
	# The two fighters and "VS" share one row: equal gaps from the screen edges and from "VS".
	_add_hero("res://assets/towers/macrophage.png", Vector2(180, HERO_ROW_Y), "tower")
	_add_hero("res://assets/enemies/rhinovirus/rhinovirus_sprite.png", Vector2(540, HERO_ROW_Y), "enemy", true)
	var bolt := _label(tr("VS"), 30, COLOR_GOLD)
	bolt.position = Vector2(0, HERO_ROW_Y - 20)
	bolt.size = Vector2(SCREEN.x, 40)
	bolt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(bolt)

	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(40, 340)
	_scroll.size = Vector2(640, 780)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	add_child(_scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 14)
	_scroll.add_child(_list)

	var tutorial := _button(tr("HOW TO PLAY"), Vector2(300, 72), 16)
	tutorial.name = "TutorialButton"
	tutorial.position = Vector2(40, 1150)
	tutorial.pressed.connect(_open_tutorial.bind(0))
	add_child(tutorial)
	var settings := _button(tr("SETTINGS"), Vector2(300, 72), 16)
	settings.name = "SettingsButton"
	settings.position = Vector2(380, 1150)
	settings.pressed.connect(_open_settings)
	add_child(settings)
	var version := _label("V%s" % ProjectSettings.get_setting("application/config/version", "0"), 10, COLOR_DIM)
	version.name = "VersionLabel"
	version.position = Vector2(0, 1240)
	version.size = Vector2(SCREEN.x, 16)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(version)
	var language := _button(Localization.name_of(Session.language), Vector2(220, 52), 16)
	language.name = "LanguageButton"
	language.position = Vector2(16, 4)
	language.pressed.connect(_open_languages)
	add_child(language)
	var fps := FpsCounter.new()
	fps.place_top_right(SCREEN.x, 8.0)
	add_child(fps)
	_refresh()
	# Start with the level to play next in view.
	var next := Session.next_to_play()
	call_deferred("_scroll_to", next)


## Drag scrolling for the level list. A drag past DRAG_THRESHOLD scrolls and cancels the tap on the card under the finger.
func _input(event: InputEvent) -> void:
	if _scroll == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_in_list = _detail == null and _settings == null and _tutorial == null and _scroll.get_global_rect().has_point(event.position)
			_dragging = false
			_drag_travel = 0.0
	elif event is InputEventMouseMotion and _press_in_list and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_drag_travel += absf(event.relative.y)
		if _drag_travel > DRAG_THRESHOLD:
			_dragging = true
		if _dragging:
			_scroll.scroll_vertical -= roundi(event.relative.y)
			get_viewport().set_input_as_handled()


func _scroll_to(number: int) -> void:
	_scroll.scroll_vertical = maxi(0, int((number - 2) * (CARD_SIZE.y + 14.0)))


func _add_hero(path: String, at: Vector2, kind: String, flip := false) -> void:
	var icon := TextureRect.new()
	icon.texture = load(path)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.size = Vector2(128, 128)
	icon.position = at - icon.size / 2.0
	icon.flip_h = flip
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.name = "Hero_%s" % kind
	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			tap_hero(kind))
	add_child(icon)


## Counts taps on the fighters; the last taps matching `SECRET_CODE` open every level until the game is closed.
func tap_hero(kind: String) -> void:
	_taps.append(kind)
	if _taps.size() > SECRET_CODE.size():
		_taps.pop_front()
	if _taps == SECRET_CODE and not Session.all_levels_open:
		Session.open_all_levels()
		GameAudio.play_sfx(GameAudio.config.unlock_sound)


func _refresh() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	for data in _levels:
		_list.add_child(_level_card(data))


func _level_card(data: LevelData) -> Button:
	var unlocked := Session.is_unlocked(data.number)
	var card := _button("", CARD_SIZE, 20)
	card.name = "Level_%d" % data.number
	card.custom_minimum_size = CARD_SIZE
	card.modulate = Color.WHITE if unlocked else Color(1, 1, 1, 0.45)
	var number := _label(str(data.number), 44, COLOR_GOLD if unlocked else COLOR_DIM)
	number.position = Vector2(20, 38)
	number.size = Vector2(96, 56)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(number)
	var title := _label(tr(data.display_name).to_upper(), 24, COLOR_TEXT if unlocked else COLOR_DIM)
	title.position = Vector2(132, 24)
	title.size = Vector2(380, 30)
	title.clip_text = true
	card.add_child(title)
	var part := _label(tr(data.body_part).to_upper() if unlocked else tr("LOCKED"), 14, COLOR_BORDER if unlocked else COLOR_DIM)
	part.position = Vector2(132, 70)
	part.size = Vector2(380, 20)
	part.clip_text = true
	card.add_child(part)
	if Session.is_completed(data.number):
		var best := _label(tr("BEST %d") % Session.best_health[data.number], 14, COLOR_GOOD)
		best.position = Vector2(132, 96)
		best.size = Vector2(300, 20)
		card.add_child(best)
	if data.boss_id != "" and _enemy_catalog.has(data.boss_id):
		var boss: EnemyData = _enemy_catalog[data.boss_id]
		var icon := TextureRect.new()
		icon.texture = load("%s/%s_sprite.png" % [boss.sprite_dir, boss.id])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.size = Vector2(80, 80)
		icon.position = Vector2(540, 14)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(icon)
		var tag := _label(tr("BOSS"), 12, COLOR_BAD)
		tag.position = Vector2(540, 98)
		tag.size = Vector2(80, 16)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(tag)
	card.pressed.connect(_on_card_pressed.bind(data))
	return card


func _on_card_pressed(data: LevelData) -> void:
	if _dragging:
		return
	if not Session.is_unlocked(data.number):
		return
	_open_detail(data)


func _open_detail(data: LevelData) -> void:
	_close_detail()
	_detail = Control.new()
	_detail.name = "Detail"
	_detail.size = SCREEN
	add_child(_detail)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = SCREEN
	_detail.add_child(dim)
	var panel := _panel(Rect2(60, 250, 600, 700))
	_detail.add_child(panel)
	var heading := _label(tr("LEVEL %d") % data.number, 20, COLOR_BORDER)
	heading.position = Vector2(30, 30)
	heading.size = Vector2(540, 26)
	panel.add_child(heading)
	var name_label := _label(tr(data.display_name).to_upper(), 34, COLOR_TEXT)
	name_label.position = Vector2(30, 70)
	name_label.size = Vector2(540, 44)
	name_label.clip_text = true
	panel.add_child(name_label)
	var text := _label(tr(data.description), 18, Color("d9cce6"))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.position = Vector2(30, 140)
	text.size = Vector2(540, 230)
	text.add_theme_constant_override("line_spacing", 10)
	panel.add_child(text)
	var facts := _label(tr("WAVES: %d   TOWERS: %d   %s") % [data.waves.size(), data.tower_ids.size(), tr(Session.difficulty_data().display_name).to_upper()], 14, COLOR_GOOD)
	facts.position = Vector2(30, 400)
	facts.size = Vector2(540, 22)
	panel.add_child(facts)
	_add_enemy_row(panel, data, Vector2(30, 450))
	var play := _button(tr("PLAY"), Vector2(260, MIN_TAP), 26)
	play.name = "PlayButton"
	play.position = Vector2(30, 574)
	play.pressed.connect(func() -> void: Session.start_level(data.number))
	panel.add_child(play)
	var back := _button(tr("BACK"), Vector2(260, MIN_TAP), 22)
	back.position = Vector2(310, 574)
	back.pressed.connect(_close_detail)
	panel.add_child(back)


## The enemies of the level as small pictures, so the player knows who is coming.
func _add_enemy_row(panel: Control, data: LevelData, at: Vector2) -> void:
	var ids: Array = []
	for wave in data.waves:
		for entry in wave.entries:
			if not ids.has(entry["enemy"]):
				ids.append(entry["enemy"])
	var x := 0.0
	for id in ids:
		var enemy: EnemyData = _enemy_catalog.get(id)
		if enemy == null or enemy.sprite_dir == "":
			continue
		var icon := TextureRect.new()
		icon.texture = load("%s/%s_sprite.png" % [enemy.sprite_dir, enemy.id])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.size = Vector2(72, 72)
		icon.position = at + Vector2(x, 0)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon)
		x += 76.0


## The tutorial: one page of TutorialPages at a time, with buttons to go back, forward and close.
func _open_tutorial(index: int) -> void:
	_close_detail()
	_close_settings()
	_close_languages()
	_close_tutorial()
	var pages := TutorialPages.PAGES
	index = clampi(index, 0, pages.size() - 1)
	_tutorial = Control.new()
	_tutorial.name = "Tutorial"
	_tutorial.size = SCREEN
	add_child(_tutorial)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = SCREEN
	_tutorial.add_child(dim)
	var panel := _panel(Rect2(40, 140, 640, 940))
	_tutorial.add_child(panel)
	var heading := _label(tr(pages[index]["title"]), 28, COLOR_GOLD)
	heading.name = "TutorialTitle"
	heading.position = Vector2(30, 36)
	heading.size = Vector2(580, 40)
	panel.add_child(heading)
	var counter := _label("%d/%d" % [index + 1, pages.size()], 16, COLOR_DIM)
	counter.name = "TutorialCounter"
	counter.position = Vector2(30, 90)
	counter.size = Vector2(580, 22)
	panel.add_child(counter)
	var text := _label("\n\n".join(pages[index]["paragraphs"].map(func(paragraph: String) -> String: return tr(paragraph))), 18, Color("d9cce6"))
	text.name = "TutorialText"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.position = Vector2(30, 140)
	text.size = Vector2(580, 560)
	text.add_theme_constant_override("line_spacing", 10)
	panel.add_child(text)
	var back := _button(tr("BACK"), Vector2(280, MIN_TAP), 22)
	back.name = "TutorialBack"
	back.position = Vector2(30, 720)
	back.disabled = index == 0
	back.pressed.connect(_open_tutorial.bind(index - 1))
	panel.add_child(back)
	var last := index == pages.size() - 1
	var forward := _button(tr("DONE") if last else tr("NEXT"), Vector2(280, MIN_TAP), 22)
	forward.name = "TutorialNext"
	forward.position = Vector2(330, 720)
	forward.pressed.connect(_close_tutorial if last else _open_tutorial.bind(index + 1))
	panel.add_child(forward)
	var close := _button(tr("CLOSE"), Vector2(580, MIN_TAP), 22)
	close.name = "TutorialClose"
	close.position = Vector2(30, 824)
	close.pressed.connect(_close_tutorial)
	panel.add_child(close)


## The language page: one button per language, each written in its own language.
func _open_languages() -> void:
	_close_detail()
	_close_settings()
	_close_tutorial()
	_close_languages()
	_languages = Control.new()
	_languages.name = "Languages"
	_languages.size = SCREEN
	add_child(_languages)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = SCREEN
	_languages.add_child(dim)
	var rows: int = Localization.LANGUAGES.size()
	var panel := _panel(Rect2(60, 140, 600, 100.0 + rows * MIN_TAP + 10.0 + (MIN_TAP - 8.0) + 30.0))
	_languages.add_child(panel)
	var heading := _label(tr("LANGUAGE"), 30, COLOR_TEXT)
	heading.position = Vector2(30, 30)
	heading.size = Vector2(540, 40)
	panel.add_child(heading)
	var y := 100.0
	for entry in Localization.LANGUAGES:
		var code: String = entry["code"]
		var button := _button(entry["name"], Vector2(540, MIN_TAP - 8.0), 26)
		button.name = "Language_%s" % code
		button.position = Vector2(30, y)
		_mark_selected(button, Session.language == code)
		button.pressed.connect(func() -> void:
			Session.set_language(code)
			get_tree().reload_current_scene())
		panel.add_child(button)
		y += MIN_TAP
	var back := _button(tr("BACK"), Vector2(540, MIN_TAP - 8.0), 22)
	back.name = "LanguageBack"
	back.position = Vector2(30, y + 10.0)
	back.pressed.connect(_close_languages)
	panel.add_child(back)


func _close_languages() -> void:
	if _languages != null:
		remove_child(_languages)
		_languages.queue_free()
		_languages = null


func _close_tutorial() -> void:
	if _tutorial != null:
		remove_child(_tutorial)
		_tutorial.queue_free()
		_tutorial = null


## The settings page: the difficulty, the sound, and a way to start over.
func _open_settings() -> void:
	_close_detail()
	_close_tutorial()
	_close_languages()
	_close_settings()
	_reset_armed = false
	_settings = Control.new()
	_settings.name = "Settings"
	_settings.size = SCREEN
	add_child(_settings)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.size = SCREEN
	_settings.add_child(dim)
	var panel := _panel(Rect2(60, 100, 600, 1080))
	panel.name = "SettingsPanel"
	_settings.add_child(panel)
	var heading := _label(tr("SETTINGS"), 34, COLOR_TEXT)
	heading.position = Vector2(30, 24)
	heading.size = Vector2(540, 44)
	panel.add_child(heading)
	var sub := _label(tr("DIFFICULTY"), 18, COLOR_BORDER)
	sub.position = Vector2(30, 76)
	sub.size = Vector2(540, 24)
	panel.add_child(sub)
	var y := 104.0
	for id in Session.DIFFICULTY_IDS:
		var option: DifficultyData = Session.load_difficulty(id)
		var button := _button(tr(option.display_name).to_upper(), Vector2(540, MIN_TAP), 24)
		button.name = "Difficulty_%s" % id
		button.position = Vector2(30, y)
		button.pressed.connect(func() -> void:
			Session.set_difficulty(id)
			_open_settings())
		_mark_selected(button, Session.difficulty == id)
		panel.add_child(button)
		y += MIN_TAP + 8.0
	var current: DifficultyData = Session.difficulty_data()
	var text := _label(tr(current.description), 16, Color("d9cce6"))
	text.name = "DifficultyText"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.position = Vector2(30, y + 4.0)
	text.size = Vector2(540, 100)
	text.add_theme_constant_override("line_spacing", 8)
	panel.add_child(text)
	_add_sound_controls(panel, 530.0)
	var reset := _button(tr("RESET PROGRESS"), Vector2(540, MIN_TAP), 20)
	reset.name = "ResetButton"
	reset.position = Vector2(30, 852)
	reset.pressed.connect(func() -> void:
		if not _reset_armed:
			_reset_armed = true
			reset.text = tr("TAP AGAIN TO CONFIRM")
			return
		Session.reset_progress()
		_open_settings())
	panel.add_child(reset)
	var back := _button(tr("BACK"), Vector2(540, MIN_TAP), 22)
	back.name = "BackButton"
	back.position = Vector2(30, 956)
	back.pressed.connect(_close_settings)
	panel.add_child(back)


## The sound section: a mute switch and a volume bar each for the music and the effects.
func _add_sound_controls(panel: Control, top: float) -> void:
	var sub := _label(tr("SOUND"), 18, COLOR_BORDER)
	sub.position = Vector2(30, top)
	sub.size = Vector2(540, 24)
	panel.add_child(sub)
	var mute := _button(tr("SOUND ON") if not GameAudio.muted else tr("SOUND OFF"), Vector2(540, MIN_TAP), 22)
	mute.name = "MuteButton"
	mute.position = Vector2(30, top + 26.0)
	_mark_selected(mute, not GameAudio.muted)
	mute.pressed.connect(func() -> void:
		GameAudio.set_muted(not GameAudio.muted)
		Session.save_progress()
		_open_settings())
	panel.add_child(mute)
	_add_volume_row(panel, "MusicVolume", tr("MUSIC"), top + 134.0, GameAudio.music_volume, func(value: float) -> void:
		GameAudio.set_music_volume(value)
		Session.save_progress())
	_add_volume_row(panel, "SfxVolume", tr("EFFECTS"), top + 224.0, GameAudio.sfx_volume, func(value: float) -> void:
		GameAudio.set_sfx_volume(value)
		Session.save_progress()
		GameAudio.play_sfx("res://assets/audio/common/block.wav"))


func _add_volume_row(panel: Control, node_name: String, title: String, y: float, start: float, on_change: Callable) -> void:
	var caption := _label(title, 16, Color("d9cce6"))
	caption.position = Vector2(30, y)
	caption.size = Vector2(540, 22)
	panel.add_child(caption)
	var bar := VolumeBar.new()
	bar.name = node_name
	bar.position = Vector2(30, y + 26.0)
	bar.size = Vector2(540, 56)
	bar.value = start
	bar.value_changed.connect(on_change)
	panel.add_child(bar)


func _close_settings() -> void:
	if _settings != null:
		remove_child(_settings)
		_settings.queue_free()
		_settings = null


## The chosen option has a gold border and a lighter fill.
func _mark_selected(button: Button, selected: bool) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("6a3a8f") if selected else Color("3a2552")
		style.set_border_width_all(4)
		style.border_color = COLOR_GOLD if selected else COLOR_BORDER
		button.add_theme_stylebox_override(state, style)


func _close_detail() -> void:
	if _detail != null:
		remove_child(_detail)
		_detail.queue_free()
		_detail = null


func _panel(rect: Rect2) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.set_border_width_all(4)
	style.border_color = COLOR_BORDER
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String, button_size: Vector2, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = button_size
	button.size = button_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("4a2f66") if state == "pressed" else Color("3a2552")
		style.set_border_width_all(4)
		style.border_color = COLOR_BORDER
		button.add_theme_stylebox_override(state, style)
	return button
