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
## One notch of the wheel with Ctrl held changes the zoom by this factor.
const ZOOM_STEP := 1.25
## Build menus with more towers than this are drawn in two columns.
const MAX_SINGLE_COLUMN := 6
const CARD_SIZE := Vector2(316, 104)
## Seconds a finger must rest on a build card before its attributes are shown.
const HOLD_SECONDS := 0.3
const INFO_SIZE := Vector2(640, 660)

const COLOR_BG := Color("2b1b3a")
const COLOR_BORDER := Color("ffb3c7")
const COLOR_GOLD := Color("f4d35e")
const COLOR_TEXT := Color("fff2f6")
const COLOR_DIM := Color("9b8aa6")
const COLOR_BAD := Color("e84a5f")
const COLOR_GOOD := Color("6ad4a0")
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
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
## Amino acids already earned whose orbs have not reached the top bar yet.
var _orbs_in_flight := 0
var _enemy_card: Panel
var _card_enemy: Enemy
## Set instead of `_card_enemy` when the card describes a kind of enemy from the next-wave preview.
var _card_data: EnemyData
var _card_lines: Label
var _card_title: Label
var _preview_index := -2
var _slot_for_menu := -1
## True while a long press on a build card showed its attributes: the release must not build. Cleared by the next press.
var _card_held := false
var _slot_for_sell := -1
## Slot of the lymphocyte that is being moved, or -1: the next tap on an empty slot puts it there.
var _move_from := -1
var _toast_tween: Tween
var _wave_banner: Label
var _banner_tween: Tween
var _scroll_track: Control
## Fingers on the map: touch index -> position, used to pinch-zoom.
var _touches: Dictionary = {}
var _track_clock := 0.0
var _pressing := false
var _dragging := false
var _press_position := Vector2.ZERO
var _map_hold: Timer
## True when a long press on a built tower showed its attributes: the release is not a tap.
var _map_held := false


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

	_map_hold = Timer.new()
	_map_hold.one_shot = true
	_map_hold.wait_time = HOLD_SECONDS
	_map_hold.timeout.connect(_on_map_hold)
	add_child(_map_hold)
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
	_wave_banner = _label("", 48, COLOR_GOLD)
	_wave_banner.name = "WaveBanner"
	_wave_banner.position = Vector2(0, 520)
	_wave_banner.size = Vector2(SCREEN.x, 160)
	_wave_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wave_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wave_banner.add_theme_color_override("font_outline_color", COLOR_BG)
	_wave_banner.add_theme_constant_override("outline_size", 12)
	_wave_banner.modulate.a = 0.0
	_root.add_child(_wave_banner)
	_overlay = Control.new()
	_overlay.size = SCREEN
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_overlay)
	var fps := FpsCounter.new()
	fps.place_top_right(SCREEN.x, TOP_BAR_HEIGHT + _safe_top() + 8.0)
	_root.add_child(fps)

	level.slot_tapped.connect(_on_slot_tapped)
	level.tower_tapped.connect(_open_tower_card)
	level.enemy_tapped.connect(_show_enemy_card)
	level.nothing_tapped.connect(_dismiss_all)
	level.orbs_requested.connect(_fly_orbs)
	level.tower_built.connect(_fly_orbs_to_tower)
	level.wave_started.connect(_show_wave_banner)
	level.victory.connect(_show_result.bind(true))
	level.defeat.connect(_show_result.bind(false))
	level.speed_changed.connect(func(value: int) -> void: _speed_button.text = "%dX" % value)
	_refresh_values()


func _process(delta: float) -> void:
	_track_clock += delta
	if _track_clock >= 0.1:
		_track_clock = 0.0
		_scroll_track.queue_redraw()
	_refresh_values()
	_refresh_wave_info()
	_refresh_enemy_card()


# --- layout -----------------------------------------------------------------

## Extra height the top bar needs for a camera cutout. The game is centred in the window with black bars above and
## below on tall phones, and those bars already cover the cutout: only the part of it that reaches into the game counts.
func _safe_top() -> float:
	if not OS.has_feature("android"):
		return 0.0
	var window := Vector2(DisplayServer.window_get_size())
	if window.x <= 0.0 or window.y <= 0.0:
		return 0.0
	var scale := minf(window.x / SCREEN.x, window.y / SCREEN.y)
	var black_bar := (window.y - SCREEN.y * scale) / 2.0
	var cutout := maxf(0.0, float(DisplayServer.get_display_safe_area().position.y))
	return maxf(0.0, cutout - black_bar) / scale


func _build_top_bar() -> void:
	var top := _safe_top()
	var bar := _panel(Rect2(0, 0, SCREEN.x, TOP_BAR_HEIGHT + top))
	bar.name = "TopBar"
	_root.add_child(bar)
	_level_label = _label(tr(level.data.display_name).to_upper(), 22, COLOR_BORDER)
	_level_label.name = "LevelName"
	_level_label.position = Vector2(16, top + 12)
	_level_label.size = Vector2(290, 30)
	_level_label.clip_text = true
	_root.add_child(_level_label)
	_wave_label = _label("", 20, COLOR_DIM)
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
	_countdown_label = _label("", 22, COLOR_TEXT)
	_countdown_label.position = Vector2(16, top + 18)
	_root.add_child(_countdown_label)
	_preview_box = Control.new()
	_preview_box.position = Vector2(16, top + 64)
	_preview_box.size = Vector2(360, 80)
	_preview_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_preview_box)
	_call_button = _button(tr("CALL WAVE"), Vector2(290, MIN_TAP), 22)
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
	var band := (Level.VIEW_SIZE.y - Level.SAFE_TOP - Level.SAFE_BOTTOM) / level.zoom
	if map_height <= band:
		return
	var top := clampf((level.scroll.y + Level.SAFE_TOP / level.zoom) / map_height, 0.0, 1.0)
	var thumb := Rect2(0.0, top * size.y, size.x, maxf(14.0, band / map_height * size.y))
	_scroll_track.draw_rect(thumb, Color(1, 1, 1, 0.55))
	for enemy in level.enemies:
		var y := clampf(enemy.position.y / map_height, 0.0, 1.0) * size.y
		_scroll_track.draw_rect(Rect2(-2.0, y - 2.0, size.x + 4.0, 4.0), COLOR_BAD)


func _build_enemy_card() -> void:
	_enemy_card = _panel(Rect2(16, TOP_BAR_HEIGHT + 12, SCREEN.x - 32, 270))
	_enemy_card.name = "EnemyCard"
	_enemy_card.visible = false
	_card_title = _label("", 28, COLOR_TEXT)
	_card_title.position = Vector2(20, 16)
	_enemy_card.add_child(_card_title)
	_card_lines = _label("", 20, COLOR_TEXT)
	_card_lines.position = Vector2(20, 64)
	_card_lines.size = Vector2(620, 220)
	_card_lines.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_lines.add_theme_constant_override("line_spacing", 10)
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


## The largest font size, from `start` down to `smallest`, at which the text is not wider than `width`
## (the names of the towers are longer in some languages).
func _fit_font_size(text: String, width: float, start: int, smallest: int) -> int:
	var font: Font = _root.theme.default_font
	var size := start
	while size > smallest and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
		size -= 1
	return size


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
	_health_label.text = "%d/%d" % [level.body_health, level.max_body_health]
	_amino_label.text = str(shown_amino_acids())
	_wave_label.text = tr("WAVE %d/%d") % [level.scheduler.started_count(), level.scheduler.wave_count()]


func _refresh_wave_info() -> void:
	var scheduler := level.scheduler
	var next_index := scheduler.next_wave_index()
	_call_button.visible = next_index != -1 and level.state == "running"
	if next_index == -1:
		_countdown_label.text = tr("ALL WAVES STARTED")
	else:
		_countdown_label.text = tr("NEXT WAVE IN %dS") % ceili(scheduler.time_to_next_wave())
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
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.name = "Preview_%s" % enemy_id
		icon.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_show_enemy_kind_card(enemy_data))
		var mark := _label(tr("V") if enemy_data.type == "virus" else tr("B"), 16, COLOR_GOOD if enemy_data.type == "virus" else COLOR_BORDER)
		mark.position = Vector2(46, 52)
		icon.add_child(mark)
		_preview_box.add_child(icon)
		x += 80.0


## A big "NEXT WAVE" notice in the middle of the screen, with the wave number, whenever a wave starts.
func _show_wave_banner(number: int, total: int) -> void:
	_wave_banner.text = "%s\n%s" % [tr("NEXT WAVE"), tr("WAVE %d/%d") % [number, total]]
	_wave_banner.modulate.a = 0.0
	_wave_banner.scale = Vector2(1.0, 1.0)
	if _banner_tween != null:
		_banner_tween.kill()
	_banner_tween = create_tween().set_ignore_time_scale(true)
	_banner_tween.tween_property(_wave_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(1.6)
	_banner_tween.tween_property(_wave_banner, "modulate:a", 0.0, 0.5)


func show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_tween = create_tween().set_ignore_time_scale(true)
	_toast_tween.tween_interval(1.2)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


## The balance as the top bar shows it: amino acids still flying towards the bar are not counted yet.
func shown_amino_acids() -> int:
	return maxi(0, Economy.balance() - _orbs_in_flight)


## Sends orbs to the top bar. The bar counts each orb's share only when that orb arrives.
func _fly_orbs(world_position: Vector2, amount: int) -> void:
	var target := _amino_icon.position + Vector2(8, 8)
	var count := mini(amount, 5)
	_orbs_in_flight += amount
	for i in count:
		var share := amount / count + (amount % count if i == 0 else 0)
		var orb := _icon("res://assets/ui/amino_acid_orb.png", Vector2(28, 28))
		orb.position = level.world_to_screen(world_position) - Vector2(14, 14) + Vector2(randf_range(-14, 14), randf_range(-14, 14))
		_root.add_child(orb)
		var tween := create_tween().set_ignore_time_scale(true)
		tween.tween_interval(i * 0.06)
		tween.tween_property(orb, "position", target, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(_orb_arrived.bind(orb, share))


## The cost of a new tower flows from the top bar into the tower (one orb per 20 amino acids, 2 to 6).
## The tower stays hidden and idle until the last orb arrives.
func _fly_orbs_to_tower(tower: Tower) -> void:
	var count := clampi(tower.data.cost / 20, 2, 6)
	var last := count - 1
	for i in count:
		var orb := _icon("res://assets/ui/amino_acid_orb.png", Vector2(28, 28))
		orb.position = _amino_icon.position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
		_root.add_child(orb)
		var tween := create_tween().set_ignore_time_scale(true)
		tween.tween_interval(i * 0.06)
		tween.tween_property(orb, "position", level.world_to_screen(tower.position) - Vector2(14, 14), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_callback(orb.queue_free)
		if i == last:
			tween.tween_callback(func() -> void:
				if is_instance_valid(tower):
					tower.finish_construction())


func _orb_arrived(orb: Control, share: int) -> void:
	orb.queue_free()
	_orbs_in_flight -= share
	_refresh_values()


# --- taps and menus ---------------------------------------------------------

## A short press is a tap; moving the finger more than DRAG_THRESHOLD scrolls the map instead.
func _on_map_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
		return
	if event is InputEventScreenDrag:
		_pinch(event)
		return
	if event is InputEventMagnifyGesture:
		_dismiss_all()
		level.zoom_by(event.factor, event.position)
		return
	if _touches.size() >= 2:
		# A pinch is going on: the finger that also acts as the mouse must not scroll or tap.
		_map_hold.stop()
		_pressing = false
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_pressing = true
				_dragging = false
				_map_held = false
				_press_position = event.position
				_map_hold.start()
			else:
				_map_hold.stop()
				if _map_held:
					_hide_tower_info()
				elif _pressing and not _dragging:
					_dismiss_all()
					level.handle_tap(event.position)
				_pressing = false
				_dragging = false
		elif event.pressed and event.ctrl_pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			level.zoom_by(ZOOM_STEP if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / ZOOM_STEP, event.position)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_dismiss_all()
			level.scroll_by(Vector2(0.0, -WHEEL_STEP))
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_dismiss_all()
			level.scroll_by(Vector2(0.0, WHEEL_STEP))
	elif event is InputEventMouseMotion and _pressing:
		if not _dragging and event.position.distance_to(_press_position) > DRAG_THRESHOLD:
			_dragging = true
			_map_hold.stop()
			_dismiss_all()
			level.scroll_by(-(event.position - _press_position) / level.screen_scale())
		elif _dragging:
			level.scroll_by(-event.relative / level.screen_scale())


## Two fingers on the map zoom it: the distance between them sets the zoom, around their midpoint.
func _pinch(event: InputEventScreenDrag) -> void:
	if not _touches.has(event.index):
		return
	var before: Array = _touches.values()
	_touches[event.index] = event.position
	if _touches.size() != 2:
		return
	var after: Array = _touches.values()
	var old_distance: float = before[0].distance_to(before[1])
	var new_distance: float = after[0].distance_to(after[1])
	if old_distance > 1.0:
		_dismiss_all()
		level.zoom_by(new_distance / old_distance, (after[0] + after[1]) / 2.0)


## Holding a built tower shows its attributes, like holding a build card.
func _on_map_hold() -> void:
	if not _pressing or _dragging or get_tree().paused or level.state != "running":
		return
	var slot := level.tower_slot_at(_press_position)
	if slot < 0:
		return
	_map_held = true
	_show_tower_info(level.towers[slot].data)


func _dismiss_all() -> void:
	_move_from = -1
	_close_popups()
	_enemy_card.visible = false
	_card_enemy = null
	_card_data = null


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


func _on_slot_tapped(slot: int) -> void:
	if _move_from >= 0:
		var from := _move_from
		_move_from = -1
		if not level.move_tower(from, slot):
			show_toast(tr("CANNOT MOVE THERE"))
		return
	_open_build_menu(slot)


func _open_build_menu(slot: int) -> void:
	_dismiss_all()
	_slot_for_menu = slot
	var ids: Array = level.data.tower_ids.duplicate()
	ids.sort_custom(func(a: String, b: String) -> bool: return level.tower_catalog[a].cost < level.tower_catalog[b].cost)
	var columns := 1 if ids.size() <= MAX_SINGLE_COLUMN else 2
	var rows := ceili(float(ids.size()) / columns)
	var menu_size := Vector2(columns * (CARD_SIZE.x + 12.0) + 12.0, 12.0 + rows * (CARD_SIZE.y + 8.0) + 4.0)
	_popup.add_child(_popup_catcher())
	var menu := _panel(Rect2(_popup_position(level.world_to_screen(level.data.slots[slot]), menu_size), menu_size))
	menu.name = "BuildMenu"
	_popup.add_child(menu)
	for i in ids.size():
		var tower_data: TowerData = level.tower_catalog[ids[i]]
		var at := Vector2(12.0 + (i / rows) * (CARD_SIZE.x + 12.0), 12.0 + (i % rows) * (CARD_SIZE.y + 8.0))
		menu.add_child(_tower_card(tower_data, at))


func _tower_card(tower_data: TowerData, at: Vector2) -> Button:
	var affordable := Economy.balance() >= tower_data.cost
	var card := _button("", CARD_SIZE, 16)
	card.name = "Card_%s" % tower_data.id
	card.position = at
	var icon := _icon("res://assets/towers/%s.png" % tower_data.id, Vector2(64, 64))
	icon.position = Vector2(12, 20)
	icon.modulate = Color.WHITE if affordable else Color(1, 1, 1, 0.35)
	card.add_child(icon)
	var title := _label(tr(tower_data.display_name).to_upper(), 18, COLOR_TEXT if affordable else COLOR_DIM)
	title.name = "Title"
	title.position = Vector2(88, 22)
	title.size = Vector2(CARD_SIZE.x - 88.0 - 8.0, 28)
	title.add_theme_font_size_override("font_size", _fit_font_size(title.text, title.size.x, 18, 10))
	title.clip_text = true
	card.add_child(title)
	var cost := _label(str(tower_data.cost), 22, COLOR_GOOD if affordable else COLOR_BAD)
	cost.position = Vector2(126, 58)
	card.add_child(cost)
	var orb := _icon("res://assets/ui/amino_acid_orb.png", Vector2(28, 28))
	orb.position = Vector2(88, 58)
	card.add_child(orb)
	var hold := Timer.new()
	hold.one_shot = true
	hold.wait_time = HOLD_SECONDS
	hold.timeout.connect(func() -> void:
		_card_held = true
		_show_tower_info(tower_data))
	card.add_child(hold)
	card.button_down.connect(func() -> void:
		_card_held = false
		hold.start())
	card.button_up.connect(func() -> void:
		hold.stop()
		_hide_tower_info())
	card.pressed.connect(_on_card_pressed.bind(tower_data))
	return card


func _on_card_pressed(tower_data: TowerData) -> void:
	if _card_held:
		return
	if Economy.balance() < tower_data.cost:
		show_toast(tr("NOT ENOUGH AMINO ACIDS"))
		return
	if level.build_tower(_slot_for_menu, tower_data.id, false):
		_close_popups()


## The attributes of a tower, shown while a build card is held: stats, ability and which enemies of the level it is good or bad against.
func _show_tower_info(tower_data: TowerData) -> void:
	_hide_tower_info()
	var panel := _panel(Rect2((SCREEN - INFO_SIZE) / 2.0, INFO_SIZE))
	panel.name = "TowerInfo"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title := _label(tr(tower_data.display_name).to_upper(), 24, COLOR_BORDER)
	title.position = Vector2(20, 16)
	panel.add_child(title)
	var body := _label(_tower_info_text(tower_data), 20, COLOR_TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.position = Vector2(20, 64)
	body.size = INFO_SIZE - Vector2(40, 80)
	body.add_theme_constant_override("line_spacing", 10)
	panel.add_child(body)
	_popup.add_child(panel)


func _hide_tower_info() -> void:
	var panel := _popup.get_node_or_null("TowerInfo")
	if panel != null:
		_popup.remove_child(panel)
		panel.queue_free()


func _tower_info_text(tower_data: TowerData) -> String:
	var lines := PackedStringArray()
	lines.append("%s - %s" % [tr(tower_data.role).to_upper(), tr(tower_data.mobility).to_upper()])
	lines.append(tr("COST: %d   RANGE: %d") % [tower_data.cost, int(tower_data.range_px)])
	lines.append(_damage_text(tower_data))
	lines.append(tr(tower_data.ability_description))
	if tower_data.damage_type == "none" or _damage_per_second(tower_data) <= 0.0:
		lines.append(tr("SUPPORT: IT HELPS THE OTHER TOWERS."))
		return "\n\n".join(lines)
	var good: Array[String] = []
	var weak: Array[String] = []
	var immune: Array[String] = []
	for enemy_id in _level_enemy_ids():
		var enemy_data: EnemyData = level.enemy_catalog[enemy_id]
		var factor := DamageCalculator.factor_for(tower_data.damage_type, enemy_data, level.damage_table)
		if tower_data.damage_type == DamageCalculator.PHYSICAL:
			factor *= 1.0 - enemy_data.armor_percent / 100.0
		var label := tr(enemy_data.display_name).to_upper()
		if factor <= 0.0:
			immune.append(label)
		elif factor > 1.0 or (tower_data.damage_type == DamageCalculator.IMMUNOLOGICAL and enemy_data.armor_percent > 0.0):
			good.append(label)
		elif factor < 0.8:
			weak.append(label)
	if not good.is_empty():
		lines.append(tr("GOOD AGAINST: %s") % ", ".join(good))
	if not weak.is_empty():
		lines.append(tr("WEAK AGAINST: %s") % ", ".join(weak))
	if not immune.is_empty():
		lines.append(tr("USELESS AGAINST: %s") % ", ".join(immune))
	return "\n\n".join(lines)


## Ids of the enemies that appear in this level, in order of first appearance.
func _level_enemy_ids() -> Array:
	var ids: Array = []
	for wave in level.data.waves:
		for entry in wave.entries:
			if not ids.has(entry["enemy"]) and level.enemy_catalog.has(entry["enemy"]):
				ids.append(entry["enemy"])
	return ids


func _open_tower_card(slot: int) -> void:
	_dismiss_all()
	_slot_for_sell = slot
	level.set_selected_tower(slot)
	var tower: Tower = level.towers[slot]
	var refund := Economy.refund_for(tower.spent)
	var card_size := Vector2(CARD_WIDTH, 380)
	_popup.add_child(_popup_catcher())
	var card := _panel(Rect2(_popup_position(level.world_to_screen(level.data.slots[slot]), card_size), card_size))
	card.name = "TowerCard"
	card.clip_contents = true
	_popup.add_child(card)
	var title := _label(tr(tower.data.display_name).to_upper(), 24, COLOR_BORDER)
	title.name = "Name"
	title.position = Vector2(16, 16)
	title.size = Vector2(CARD_WIDTH - 32, 30)
	title.clip_text = true
	card.add_child(title)
	var damage := _label(_damage_text(tower.data), 18, COLOR_TEXT)
	damage.name = "Damage"
	damage.position = Vector2(16, 58)
	damage.size = Vector2(CARD_WIDTH - 32, 26)
	card.add_child(damage)
	var ability := _label(tr(tower.data.ability_description), 18, Color("d9cce6"))
	ability.name = "Ability"
	ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ability.custom_minimum_size = Vector2(CARD_WIDTH - 32, 0)
	ability.position = Vector2(16, 96)
	ability.size = Vector2(CARD_WIDTH - 32, 150)
	ability.clip_text = true
	ability.add_theme_constant_override("line_spacing", 8)
	card.add_child(ability)
	var mobile := tower.data.mobility == "mobile"
	var sell := _button(tr("SELL +%d") % refund, Vector2(190 if mobile else 220, MIN_TAP), 20)
	sell.name = "SellButton"
	sell.position = Vector2(CARD_WIDTH - 206.0 if mobile else (CARD_WIDTH - 220.0) / 2.0, 260)
	sell.pressed.connect(func() -> void:
		level.sell_tower(slot)
		_close_popups())
	card.add_child(sell)
	if mobile:
		var move := _button(tr("MOVE"), Vector2(190, MIN_TAP), 20)
		move.name = "MoveButton"
		move.position = Vector2(16, 260)
		move.pressed.connect(func() -> void:
			_close_popups()
			_move_from = slot
			show_toast(tr("TAP AN EMPTY SLOT")))
		card.add_child(move)


func _damage_per_second(tower_data: TowerData) -> float:
	if tower_data.attack_damage > 0.0 and tower_data.attack_interval > 0.0:
		return tower_data.attack_damage / tower_data.attack_interval
	return tower_data.dot_damage


## "DAMAGE: 12/S (PHYSICAL)" for towers that hurt enemies, "DAMAGE: NONE" for the others.
func _damage_text(tower_data: TowerData) -> String:
	var per_second := _damage_per_second(tower_data)
	if per_second <= 0.0 or tower_data.damage_type == "none":
		return tr("DAMAGE: NONE")
	var amount := "%d" % int(per_second) if is_equal_approx(per_second, roundf(per_second)) else "%.1f" % per_second
	return tr("DAMAGE: %s/S (%s)") % [amount, tr(tower_data.damage_type).to_upper()]


# --- enemy card -------------------------------------------------------------

func _show_enemy_card(enemy: Enemy) -> void:
	_dismiss_all()
	_card_enemy = enemy
	_card_data = null
	_enemy_card.visible = true
	_card_title.text = tr(enemy.data.display_name).to_upper()
	_refresh_enemy_card()


## Shows the card of an enemy kind (a tap on the next-wave preview), with its full health.
func _show_enemy_kind_card(data: EnemyData) -> void:
	_dismiss_all()
	_card_enemy = null
	_card_data = data
	_enemy_card.visible = true
	_card_title.text = tr(data.display_name).to_upper()
	_refresh_enemy_card()


func _refresh_enemy_card() -> void:
	if not _enemy_card.visible:
		return
	var data: EnemyData = _card_data
	var lines := PackedStringArray()
	if _card_data == null:
		if _card_enemy == null or not is_instance_valid(_card_enemy) or _card_enemy.finished:
			_dismiss_all()
			return
		data = _card_enemy.data
	lines.append("%s - %s" % [tr(data.type).to_upper(), tr(data.role).to_upper()])
	if _card_data == null:
		lines.append(tr("HP %d/%d") % [maxi(0, ceili(_card_enemy.health)), int(_card_enemy.max_health)])
	else:
		lines.append(tr("HP %d") % roundi(data.health * level.difficulty.enemy_health))
	lines.append_array(EnemyInfo.defense_lines(data, level.damage_table))
	_card_lines.text = "\n".join(lines)


# --- pause and results ------------------------------------------------------

func _on_pause_pressed() -> void:
	if level.state != "running" or get_tree().paused:
		return
	_dismiss_all()
	level.set_paused(true)
	_show_overlay(tr("PAUSED"), [[tr("RESUME"), _resume], [tr("RESTART"), _restart], [tr("MENU"), _to_menu]])


func _resume() -> void:
	_clear_overlay()
	level.set_paused(false)


func _restart() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _to_menu() -> void:
	Session.open_menu()


func _next_level() -> void:
	Session.start_level(level.data.number + 1)


func _show_result(won: bool) -> void:
	_dismiss_all()
	if not won:
		_show_overlay(tr("DEFEAT"), [[tr("RETRY"), _restart], [tr("MENU"), _to_menu]])
	elif Session.has_next(level.data.number):
		_show_overlay(tr("VICTORY!"), [[tr("NEXT LEVEL"), _next_level], [tr("RESTART"), _restart], [tr("MENU"), _to_menu]])
	else:
		_show_overlay(tr("BODY SAVED!"), [[tr("RESTART"), _restart], [tr("MENU"), _to_menu]])


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
