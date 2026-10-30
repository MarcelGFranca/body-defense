## The heads-up display: bars, build and sell menus, wave info, enemy card, pause and results.
## It lives at full resolution (720 x 1280), on top of the pixelated map.
class_name Hud
extends CanvasLayer

const SCREEN := Vector2(720, 1280)
## Screen pixels per map unit.
const PX := 2.0
const TOP_BAR_HEIGHT := 112.0
const BOTTOM_BAR_HEIGHT := 200.0
## 48 dp at the 720 px reference width (1 dp = 2 px).
const MIN_TAP := 96.0
const MENU_WIDTH := 296.0
const CARD_WIDTH := 440.0
## Pixels a finger must move before a press becomes a drag.
const DRAG_THRESHOLD := 14.0
const WHEEL_STEP := 40.0
const CARD_SIZE := Vector2(272, 104)

const COLOR_BG := Color("2b1b3a")
const COLOR_BORDER := Color("ffb3c7")
const COLOR_TEXT := Color("fff2f6")
const COLOR_DIM := Color("9b8aa6")
const COLOR_BAD := Color("e84a5f")
const COLOR_GOOD := Color("6ad4a0")
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const DAMAGE_TYPES := ["physical", "thermal", "chemical", "antiviral", "immunological"]

var level: Level

var _root: Control
var _popup: Control
var _overlay: Control
var _toast: Label
var _level_label: Label
var _health_label: Label
var _amino_label: Label
var _wave_label: Label
var _speed_button: Button
var _pause_button: Button
var _countdown_label: Label
var _preview_box: Control
var _call_button: Button
var _amino_icon: TextureRect
var _enemy_card: Panel
var _card_enemy: Enemy
var _card_lines: Label
var _card_title: Label
var _preview_index := -2
var _slot_for_menu := -1
var _slot_for_sell := -1
var _toast_tween: Tween
var _scroll_track: Control
var _pressing := false
var _dragging := false
var _press_position := Vector2.ZERO


func _init(game_level: Level) -> void:
	level = game_level


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.size = SCREEN
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	if ResourceLoader.exists(FONT_PATH):
		theme.default_font = load(FONT_PATH)
	theme.default_font_size = 20
	_root.theme = theme
	add_child(_root)

	var catcher := Control.new()
	catcher.name = "MapInput"
	catcher.size = SCREEN
	catcher.gui_input.connect(_on_map_input)
	_root.add_child(catcher)

	_build_top_bar()
	_build_bottom_bar()
	_build_scroll_track()
	_build_enemy_card()
	_popup = Control.new()
	_popup.size = SCREEN
	_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_popup)
	_toast = _label("", 18, COLOR_BAD)
	_toast.position = Vector2(20, 1030)
	_toast.size = Vector2(680, 36)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.modulate.a = 0.0
	_root.add_child(_toast)
	_overlay = Control.new()
	_overlay.size = SCREEN
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_overlay)

	level.slot_tapped.connect(_open_build_menu)
	level.tower_tapped.connect(_open_tower_card)
	level.enemy_tapped.connect(_show_enemy_card)
	level.nothing_tapped.connect(_dismiss_all)
	level.orbs_requested.connect(_fly_orbs)
	level.victory.connect(_show_result.bind(true))
	level.defeat.connect(_show_result.bind(false))
	level.speed_changed.connect(func(value: int) -> void: _speed_button.text = "%dX" % value)
	_refresh_values()


func _process(_delta: float) -> void:
	_scroll_track.queue_redraw()
	_refresh_values()
	_refresh_wave_info()
	_refresh_enemy_card()


# --- layout -----------------------------------------------------------------

func _safe_top() -> float:
	if not OS.has_feature("android"):
		return 0.0
	var safe := DisplayServer.get_display_safe_area()
	var window_width := DisplayServer.window_get_size().x
	if window_width <= 0:
		return 0.0
	return maxf(0.0, float(safe.position.y)) * SCREEN.x / float(window_width)


func _build_top_bar() -> void:
	var top := _safe_top()
	var bar := _panel(Rect2(0, 0, SCREEN.x, TOP_BAR_HEIGHT + top))
	bar.name = "TopBar"
	_root.add_child(bar)
	_level_label = _label(level.data.display_name.to_upper(), 22, COLOR_BORDER)
	_level_label.name = "LevelName"
	_level_label.position = Vector2(16, top + 12)
	_level_label.size = Vector2(290, 30)
	_level_label.clip_text = true
	_root.add_child(_level_label)
	_wave_label = _label("", 18, COLOR_DIM)
	_wave_label.position = Vector2(300, top + 16)
	_wave_label.size = Vector2(196, 26)
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(_wave_label)
	var heart := _icon("res://assets/ui/heart.png", Vector2(36, 36))
	heart.position = Vector2(16, top + 58)
	_root.add_child(heart)
	_health_label = _label("", 22, COLOR_TEXT)
	_health_label.position = Vector2(62, top + 64)
	_root.add_child(_health_label)
	_amino_icon = _icon("res://assets/ui/amino_acid_orb.png", Vector2(36, 36))
	_amino_icon.position = Vector2(236, top + 58)
	_root.add_child(_amino_icon)
	_amino_label = _label("", 22, COLOR_TEXT)
	_amino_label.position = Vector2(282, top + 64)
	_root.add_child(_amino_label)
	_pause_button = _button("II", Vector2(MIN_TAP, MIN_TAP), 28)
	_pause_button.name = "PauseButton"
	_pause_button.position = Vector2(SCREEN.x - 2 * MIN_TAP - 24, top + 8)
	_pause_button.pressed.connect(_on_pause_pressed)
	_root.add_child(_pause_button)
	_speed_button = _button("1X", Vector2(MIN_TAP, MIN_TAP), 24)
	_speed_button.name = "SpeedButton"
	_speed_button.position = Vector2(SCREEN.x - MIN_TAP - 12, top + 8)
	_speed_button.pressed.connect(func() -> void: level.toggle_speed())
	_root.add_child(_speed_button)


func _build_bottom_bar() -> void:
	var top := SCREEN.y - BOTTOM_BAR_HEIGHT
	var bar := _panel(Rect2(0, top, SCREEN.x, BOTTOM_BAR_HEIGHT))
	bar.name = "BottomBar"
	_root.add_child(bar)
	_countdown_label = _label("", 20, COLOR_TEXT)
	_countdown_label.position = Vector2(16, top + 18)
	_root.add_child(_countdown_label)
	_preview_box = Control.new()
	_preview_box.position = Vector2(16, top + 64)
	_preview_box.size = Vector2(360, 80)
	_preview_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_preview_box)
	_call_button = _button("CALL WAVE", Vector2(290, MIN_TAP), 22)
	_call_button.name = "CallWaveButton"
	_call_button.position = Vector2(SCREEN.x - 290 - 16, top + 56)
	_call_button.pressed.connect(func() -> void: level.call_next_wave())
	_root.add_child(_call_button)


## A thin bar on the right edge that shows which part of the map is on screen, and where enemies are.
func _build_scroll_track() -> void:
	_scroll_track = Control.new()
	_scroll_track.name = "ScrollTrack"
	var top := _safe_top() + TOP_BAR_HEIGHT
	_scroll_track.position = Vector2(SCREEN.x - 10.0, top + 8.0)
	_scroll_track.size = Vector2(6.0, SCREEN.y - BOTTOM_BAR_HEIGHT - top - 16.0)
	_scroll_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll_track.draw.connect(_draw_scroll_track)
	_root.add_child(_scroll_track)


func _draw_scroll_track() -> void:
	var size := _scroll_track.size
	_scroll_track.draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.14))
	var map_height := level.data.map_size.y
	var band := Level.VIEW_SIZE.y - Level.SAFE_TOP - Level.SAFE_BOTTOM
	if map_height <= band:
		return
	var top := clampf((level.scroll.y + Level.SAFE_TOP) / map_height, 0.0, 1.0)
	var thumb := Rect2(0.0, top * size.y, size.x, maxf(14.0, band / map_height * size.y))
	_scroll_track.draw_rect(thumb, Color(1, 1, 1, 0.55))
	for enemy in level.enemies:
		var y := clampf(enemy.position.y / map_height, 0.0, 1.0) * size.y
		_scroll_track.draw_rect(Rect2(-2.0, y - 2.0, size.x + 4.0, 4.0), COLOR_BAD)


func _build_enemy_card() -> void:
	_enemy_card = _panel(Rect2(16, TOP_BAR_HEIGHT + 12, SCREEN.x - 32, 230))
	_enemy_card.name = "EnemyCard"
	_enemy_card.visible = false
	_card_title = _label("", 24, COLOR_TEXT)
	_card_title.position = Vector2(20, 16)
	_enemy_card.add_child(_card_title)
	_card_lines = _label("", 18, COLOR_TEXT)
	_card_lines.position = Vector2(20, 60)
	_card_lines.size = Vector2(620, 160)
	_card_lines.add_theme_constant_override("line_spacing", 8)
	_enemy_card.add_child(_card_lines)
	_root.add_child(_enemy_card)


# --- widgets ----------------------------------------------------------------

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


func _icon(path: String, icon_size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load(path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.size = icon_size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


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
	button.add_to_group("tap_target")
	return button


# --- live values ------------------------------------------------------------

func _refresh_values() -> void:
	_health_label.text = "%d/%d" % [level.body_health, level.data.body_health]
	_amino_label.text = str(Economy.balance())
	_wave_label.text = "WAVE %d/%d" % [level.scheduler.started_count(), level.scheduler.wave_count()]


func _refresh_wave_info() -> void:
	var scheduler := level.scheduler
	var next_index := scheduler.next_wave_index()
	_call_button.visible = next_index != -1 and level.state == "running"
	if next_index == -1:
		_countdown_label.text = "ALL WAVES STARTED"
	else:
		_countdown_label.text = "NEXT WAVE IN %dS" % ceili(scheduler.time_to_next_wave())
	if next_index != _preview_index:
		_preview_index = next_index
		_rebuild_preview(next_index)


func _rebuild_preview(next_index: int) -> void:
	for child in _preview_box.get_children():
		child.queue_free()
	if next_index == -1:
		return
	var x := 0.0
	for enemy_id in level.scheduler.enemy_ids_of(next_index):
		var enemy_data: EnemyData = level.enemy_catalog[enemy_id]
		var icon := TextureRect.new()
		icon.texture = EnemySprites.icon_for(enemy_data)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.size = Vector2(64, 64)
		icon.position = Vector2(x, 0)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mark := _label("V" if enemy_data.type == "virus" else "B", 16, COLOR_GOOD if enemy_data.type == "virus" else COLOR_BORDER)
		mark.position = Vector2(46, 52)
		icon.add_child(mark)
		_preview_box.add_child(icon)
		x += 80.0


func show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_tween = create_tween().set_ignore_time_scale(true)
	_toast_tween.tween_interval(1.2)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


func _fly_orbs(world_position: Vector2, amount: int) -> void:
	var target := _amino_icon.position + Vector2(8, 8)
	for i in mini(amount, 5):
		var orb := _icon("res://assets/ui/amino_acid_orb.png", Vector2(28, 28))
		orb.position = level.world_to_screen(world_position) - Vector2(14, 14) + Vector2(randf_range(-14, 14), randf_range(-14, 14))
		_root.add_child(orb)
		var tween := create_tween().set_ignore_time_scale(true)
		tween.tween_interval(i * 0.06)
		tween.tween_property(orb, "position", target, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(orb.queue_free)


# --- taps and menus ---------------------------------------------------------

## A short press is a tap; moving the finger more than DRAG_THRESHOLD scrolls the map instead.
func _on_map_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_pressing = true
				_dragging = false
				_press_position = event.position
			else:
				if _pressing and not _dragging:
					_dismiss_all()
					level.handle_tap(event.position)
				_pressing = false
				_dragging = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_dismiss_all()
			level.scroll_by(Vector2(0.0, -WHEEL_STEP))
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_dismiss_all()
			level.scroll_by(Vector2(0.0, WHEEL_STEP))
	elif event is InputEventMouseMotion and _pressing:
		if not _dragging and event.position.distance_to(_press_position) > DRAG_THRESHOLD:
			_dragging = true
			_dismiss_all()
			level.scroll_by(-(event.position - _press_position) / Level.SHRINK)
		elif _dragging:
			level.scroll_by(-event.relative / Level.SHRINK)


func _dismiss_all() -> void:
	_close_popups()
	_enemy_card.visible = false
	_card_enemy = null


func _close_popups() -> void:
	for child in _popup.get_children():
		_popup.remove_child(child)
		child.queue_free()
	_slot_for_menu = -1
	_slot_for_sell = -1
	level.set_selected_tower(-1)


func _popup_catcher() -> Control:
	var catcher := Control.new()
	catcher.name = "PopupCatcher"
	catcher.size = SCREEN
	catcher.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_dismiss_all())
	return catcher


func _popup_position(anchor: Vector2, popup_size: Vector2) -> Vector2:
	var x := clampf(anchor.x - popup_size.x / 2.0, 12.0, SCREEN.x - popup_size.x - 12.0)
	var y := anchor.y - popup_size.y - 44.0
	if y < TOP_BAR_HEIGHT + 8.0:
		y = anchor.y + 44.0
	y = clampf(y, TOP_BAR_HEIGHT + 8.0, SCREEN.y - BOTTOM_BAR_HEIGHT - popup_size.y - 8.0)
	return Vector2(x, y)


func _open_build_menu(slot: int) -> void:
	_dismiss_all()
	_slot_for_menu = slot
	var ids: Array = level.data.tower_ids
	var menu_size := Vector2(MENU_WIDTH, 12.0 + ids.size() * (CARD_SIZE.y + 8.0) + 4.0)
	_popup.add_child(_popup_catcher())
	var menu := _panel(Rect2(_popup_position(level.world_to_screen(level.data.slots[slot]), menu_size), menu_size))
	menu.name = "BuildMenu"
	_popup.add_child(menu)
	var y := 12.0
	for id in ids:
		var tower_data: TowerData = level.tower_catalog[id]
		menu.add_child(_tower_card(tower_data, Vector2(12, y)))
		y += CARD_SIZE.y + 8.0


func _tower_card(tower_data: TowerData, at: Vector2) -> Button:
	var affordable := Economy.balance() >= tower_data.cost
	var card := _button("", CARD_SIZE, 16)
	card.name = "Card_%s" % tower_data.id
	card.position = at
	var icon := _icon("res://assets/towers/%s.png" % tower_data.id, Vector2(64, 64))
	icon.position = Vector2(12, 20)
	icon.modulate = Color.WHITE if affordable else Color(1, 1, 1, 0.35)
	card.add_child(icon)
	var title := _label(tower_data.display_name.to_upper(), 16, COLOR_TEXT if affordable else COLOR_DIM)
	title.position = Vector2(88, 22)
	card.add_child(title)
	var cost := _label(str(tower_data.cost), 22, COLOR_GOOD if affordable else COLOR_BAD)
	cost.position = Vector2(126, 60)
	card.add_child(cost)
	var orb := _icon("res://assets/ui/amino_acid_orb.png", Vector2(28, 28))
	orb.position = Vector2(88, 58)
	card.add_child(orb)
	card.pressed.connect(_on_card_pressed.bind(tower_data))
	return card


func _on_card_pressed(tower_data: TowerData) -> void:
	if Economy.balance() < tower_data.cost:
		show_toast("NOT ENOUGH AMINO ACIDS")
		return
	if level.build_tower(_slot_for_menu, tower_data.id):
		_close_popups()


func _open_tower_card(slot: int) -> void:
	_dismiss_all()
	_slot_for_sell = slot
	level.set_selected_tower(slot)
	var tower: Tower = level.towers[slot]
	var refund := Economy.refund_for(tower.spent)
	var card_size := Vector2(CARD_WIDTH, 332)
	_popup.add_child(_popup_catcher())
	var card := _panel(Rect2(_popup_position(level.world_to_screen(level.data.slots[slot]), card_size), card_size))
	card.name = "TowerCard"
	card.clip_contents = true
	_popup.add_child(card)
	var title := _label(tower.data.display_name.to_upper(), 22, COLOR_BORDER)
	title.name = "Name"
	title.position = Vector2(16, 16)
	title.size = Vector2(CARD_WIDTH - 32, 30)
	title.clip_text = true
	card.add_child(title)
	var damage := _label(_damage_text(tower.data), 16, COLOR_TEXT)
	damage.name = "Damage"
	damage.position = Vector2(16, 58)
	damage.size = Vector2(CARD_WIDTH - 32, 22)
	card.add_child(damage)
	var ability := _label(tower.data.ability_description, 16, Color("d9cce6"))
	ability.name = "Ability"
	ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ability.custom_minimum_size = Vector2(CARD_WIDTH - 32, 0)
	ability.position = Vector2(16, 92)
	ability.size = Vector2(CARD_WIDTH - 32, 120)
	ability.clip_text = true
	ability.add_theme_constant_override("line_spacing", 8)
	card.add_child(ability)
	var sell := _button("SELL +%d" % refund, Vector2(220, MIN_TAP), 20)
	sell.name = "SellButton"
	sell.position = Vector2((CARD_WIDTH - 220.0) / 2.0, 220)
	sell.pressed.connect(func() -> void:
		level.sell_tower(slot)
		_close_popups())
	card.add_child(sell)


## "DAMAGE: 12/S (PHYSICAL)" for towers that hurt enemies, "DAMAGE: NONE" for the others.
func _damage_text(tower_data: TowerData) -> String:
	var per_second := 0.0
	if tower_data.attack_damage > 0.0 and tower_data.attack_interval > 0.0:
		per_second = tower_data.attack_damage / tower_data.attack_interval
	elif tower_data.dot_damage > 0.0:
		per_second = tower_data.dot_damage
	if per_second <= 0.0 or tower_data.damage_type == "none":
		return "DAMAGE: NONE"
	var amount := "%d" % int(per_second) if is_equal_approx(per_second, roundf(per_second)) else "%.1f" % per_second
	return "DAMAGE: %s/S (%s)" % [amount, tower_data.damage_type.to_upper()]


# --- enemy card -------------------------------------------------------------

func _show_enemy_card(enemy: Enemy) -> void:
	_dismiss_all()
	_card_enemy = enemy
	_enemy_card.visible = true
	_card_title.text = enemy.data.display_name.to_upper()
	_refresh_enemy_card()


func _refresh_enemy_card() -> void:
	if not _enemy_card.visible:
		return
	if _card_enemy == null or not is_instance_valid(_card_enemy) or _card_enemy.finished:
		_dismiss_all()
		return
	var data := _card_enemy.data
	var lines := PackedStringArray()
	lines.append("%s - %s" % [data.type.to_upper(), data.role.to_upper()])
	lines.append("HP %d/%d" % [maxi(0, ceili(_card_enemy.health)), int(data.health)])
	var weak: Array[String] = []
	var resists: Array[String] = []
	var immune: Array[String] = []
	for damage_type in DAMAGE_TYPES:
		var factor := DamageCalculator.factor_for(damage_type, data, level.damage_table)
		if factor == 0.0:
			immune.append(damage_type)
		elif factor > 1.0:
			weak.append(damage_type)
		elif factor < 1.0:
			resists.append(damage_type)
	if data.armor_percent > 0.0:
		resists.append("physical %d%%" % int(data.armor_percent))
	if not weak.is_empty():
		lines.append("WEAK: %s" % ", ".join(weak).to_upper())
	if not resists.is_empty():
		lines.append("RESISTS: %s" % ", ".join(resists).to_upper())
	if not immune.is_empty():
		lines.append("IMMUNE: %s" % ", ".join(immune).to_upper())
	_card_lines.text = "\n".join(lines)


# --- pause and results ------------------------------------------------------

func _on_pause_pressed() -> void:
	if level.state != "running" or get_tree().paused:
		return
	_dismiss_all()
	level.set_paused(true)
	_show_overlay("PAUSED", [["RESUME", _resume], ["RESTART", _restart]])


func _resume() -> void:
	_clear_overlay()
	level.set_paused(false)


func _restart() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _show_result(won: bool) -> void:
	_dismiss_all()
	_show_overlay("VICTORY!" if won else "DEFEAT", [["RESTART", _restart]])


func _clear_overlay() -> void:
	for child in _overlay.get_children():
		_overlay.remove_child(child)
		child.queue_free()


func _show_overlay(title: String, buttons: Array) -> void:
	_clear_overlay()
	var dim := ColorRect.new()
	dim.name = "OverlayDim"
	dim.color = Color(0, 0, 0, 0.65)
	dim.size = SCREEN
	_overlay.add_child(dim)
	var panel_size := Vector2(480, 150 + buttons.size() * 112)
	var panel := _panel(Rect2((SCREEN - panel_size) / 2.0, panel_size))
	panel.name = "OverlayPanel"
	_overlay.add_child(panel)
	var heading := _label(title, 32, COLOR_TEXT)
	heading.position = Vector2(0, 46)
	heading.size = Vector2(panel_size.x, 40)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(heading)
	var y := 124.0
	for entry in buttons:
		var button := _button(entry[0], Vector2(400, MIN_TAP), 24)
		button.position = Vector2(40, y)
		button.pressed.connect(entry[1])
		panel.add_child(button)
		y += 112.0
