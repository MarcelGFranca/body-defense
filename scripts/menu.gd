## The level menu: ten levels in a list, locked until the one before is won. Tap one to see it and start it.
## `-- --autoplay [--level N]` skips the menu and lets the bot play.
extends Control

const SCREEN := Vector2(720, 1280)
const CARD_SIZE := Vector2(640, 128)
const MIN_TAP := 96.0
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
	title.position = Vector2(0, 70)
	title.size = Vector2(SCREEN.x, 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var tagline := _label("DEFEND THE HUMAN BODY", 18, COLOR_BORDER)
	tagline.position = Vector2(0, 142)
	tagline.size = Vector2(SCREEN.x, 26)
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(tagline)
	_add_hero("res://assets/towers/macrophage.png", Vector2(150, 180))
	_add_hero("res://assets/enemies/rhinovirus/rhinovirus_sprite.png", Vector2(450, 180), true)
	var bolt := _label("VS", 30, COLOR_GOLD)
	bolt.position = Vector2(0, 232)
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

	var reset := _button("RESET PROGRESS", Vector2(300, 72), 14)
	reset.position = Vector2(210, 1150)
	reset.pressed.connect(func() -> void: Session.reset_progress())
	add_child(reset)
	_refresh()
	# Start with the level to play next in view.
	var next := Session.next_to_play()
	call_deferred("_scroll_to", next)


func _scroll_to(number: int) -> void:
	_scroll.scroll_vertical = maxi(0, int((number - 2) * (CARD_SIZE.y + 14.0)))


func _add_hero(path: String, at: Vector2, flip := false) -> void:
	var icon := TextureRect.new()
	icon.texture = load(path)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.size = Vector2(128, 128)
	icon.position = at - Vector2(64, 40)
	icon.flip_h = flip
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)


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
	var title := _label(data.display_name.to_upper(), 24, COLOR_TEXT if unlocked else COLOR_DIM)
	title.position = Vector2(132, 24)
	title.size = Vector2(380, 30)
	title.clip_text = true
	card.add_child(title)
	var part := _label(data.body_part.to_upper() if unlocked else "LOCKED", 14, COLOR_BORDER if unlocked else COLOR_DIM)
	part.position = Vector2(132, 70)
	part.size = Vector2(380, 20)
	part.clip_text = true
	card.add_child(part)
	if Session.is_completed(data.number):
		var best := _label("BEST %d/%d" % [Session.best_health[data.number], data.body_health], 14, COLOR_GOOD)
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
		var tag := _label("BOSS", 12, COLOR_BAD)
		tag.position = Vector2(540, 98)
		tag.size = Vector2(80, 16)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(tag)
	card.pressed.connect(_on_card_pressed.bind(data))
	return card


func _on_card_pressed(data: LevelData) -> void:
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
	var heading := _label("LEVEL %d" % data.number, 20, COLOR_BORDER)
	heading.position = Vector2(30, 30)
	heading.size = Vector2(540, 26)
	panel.add_child(heading)
	var name_label := _label(data.display_name.to_upper(), 34, COLOR_TEXT)
	name_label.position = Vector2(30, 70)
	name_label.size = Vector2(540, 44)
	name_label.clip_text = true
	panel.add_child(name_label)
	var text := _label(data.description, 18, Color("d9cce6"))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.position = Vector2(30, 140)
	text.size = Vector2(540, 230)
	text.add_theme_constant_override("line_spacing", 10)
	panel.add_child(text)
	var facts := _label("WAVES: %d     TOWERS: %d" % [data.waves.size(), data.tower_ids.size()], 16, COLOR_GOOD)
	facts.position = Vector2(30, 400)
	facts.size = Vector2(540, 22)
	panel.add_child(facts)
	_add_enemy_row(panel, data, Vector2(30, 450))
	var play := _button("PLAY", Vector2(260, MIN_TAP), 26)
	play.name = "PlayButton"
	play.position = Vector2(30, 574)
	play.pressed.connect(func() -> void: Session.start_level(data.number))
	panel.add_child(play)
	var back := _button("BACK", Vector2(260, MIN_TAP), 22)
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


func _close_detail() -> void:
	if _detail != null:
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
