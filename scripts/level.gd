## One playable level: the map, enemies, towers, waves and the win and lose rules.
class_name Level
extends Node

signal body_health_changed(value: int, max_value: int)
signal wave_started(number: int, total: int)
signal victory
signal defeat
## Emitted when an enemy dies, so the HUD can fly amino acid orbs to the counter.
signal orbs_requested(world_position: Vector2, amount: int)
signal enemy_tapped(enemy: Enemy)
signal slot_tapped(slot_index: int)
signal tower_tapped(slot_index: int)
signal nothing_tapped
signal speed_changed(speed: int)
signal scrolled

const LEVEL_PATH := "res://data/levels/level_1.tres"
const DAMAGE_TABLE_PATH := "res://data/damage_table.tres"
## Screen pixels per map unit: the map is drawn at 360 x 640 and shown at 2x.
const SHRINK := 2
const TAP_RADIUS := 24.0
## Size of the drawn view in map units, and the parts of it covered by the HUD bars.
const VIEW_SIZE := Vector2(360, 640)
const SAFE_TOP := 56.0
const SAFE_BOTTOM := 100.0

var data: LevelData
var damage_table: DamageTable
var enemy_catalog: Dictionary = {}
var tower_catalog: Dictionary = {}
var curve := Curve2D.new()
var scheduler: WaveScheduler
var enemies: Array[Enemy] = []
var puddles: Array[MucusPuddle] = []
var _globs: Array[MucusGlob] = []
var towers: Dictionary = {}  # slot index -> Tower
var body_health := 0
var state := "running"  # "running", "won" or "lost"
var speed := 1
## Map position shown at the top left corner of the view.
var scroll := Vector2.ZERO

var _enemy_layer: Node2D
var _ground_layer: Node2D
var _air_layer: Node2D
var _tower_layer: Node2D
var _map: MapView
var _camera: Camera2D


func _init(level_data: LevelData = null) -> void:
	data = level_data


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	if data == null:
		data = load(LEVEL_PATH)
	damage_table = load(DAMAGE_TABLE_PATH)
	enemy_catalog = DataLoader.load_all("res://data/enemies")
	tower_catalog = DataLoader.load_all("res://data/towers")
	for point in data.path_points:
		curve.add_point(point)
	_build_view()
	set_scroll(Vector2(0.0, -SAFE_TOP))
	scheduler = WaveScheduler.new(data.waves)
	scheduler.enemy_spawned.connect(_spawn_enemy)
	scheduler.wave_started.connect(func(index: int) -> void: wave_started.emit(index + 1, data.waves.size()))
	Economy.reset(data.starting_amino_acids)
	body_health = data.body_health
	body_health_changed.emit(body_health, data.body_health)
	victory.connect(func() -> void: GameAudio.stop_music())
	defeat.connect(func() -> void: GameAudio.stop_music())
	GameAudio.play_music(data.music)


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	GameAudio.stop_music(0.0)


func _process(delta: float) -> void:
	step(delta)


## Advances the whole simulation by `delta` seconds of level time.
func step(delta: float) -> void:
	if state != "running":
		return
	scheduler.tick(delta)
	for tower: Tower in towers.values():
		tower.step(delta)
	for glob in _globs.duplicate():
		glob.step(delta)
	for puddle in puddles.duplicate():
		puddle.step(delta)
	for enemy in enemies.duplicate():
		enemy.step(delta)
	_check_victory()


## Lowest and highest scroll positions: the whole map can be brought between the HUD bars.
func scroll_limits() -> Rect2:
	var low := Vector2(0.0, -SAFE_TOP)
	var high := Vector2(
		maxf(0.0, data.map_size.x - VIEW_SIZE.x),
		maxf(-SAFE_TOP, data.map_size.y - (VIEW_SIZE.y - SAFE_BOTTOM)))
	return Rect2(low, high - low)


func set_scroll(position: Vector2) -> void:
	var limits := scroll_limits()
	scroll = position.clamp(limits.position, limits.end)
	_camera.position = scroll
	scrolled.emit()


func scroll_by(delta: Vector2) -> void:
	set_scroll(scroll + delta)


func screen_to_world(screen_position: Vector2) -> Vector2:
	return screen_position / SHRINK + scroll


func world_to_screen(world_position: Vector2) -> Vector2:
	return (world_position - scroll) * SHRINK


## A Mucus Cell throws a glob at `target`; where it lands it leaves a puddle for a few seconds.
func throw_mucus(from: Vector2, target: Enemy, tower_data: TowerData) -> void:
	var glob := MucusGlob.new()
	_air_layer.add_child(glob)
	glob.setup(from, target)
	_globs.append(glob)
	glob.landed.connect(func(at: Vector2) -> void:
		_globs.erase(glob)
		add_puddle(at, tower_data.puddle_radius, tower_data.slow_percent, tower_data.puddle_seconds))
	glob.tree_exited.connect(func() -> void: _globs.erase(glob))


func add_puddle(at: Vector2, radius: float, slow_percent: float, seconds: float) -> MucusPuddle:
	var puddle := MucusPuddle.new()
	puddle.position = at
	_ground_layer.add_child(puddle)
	puddle.setup(self, radius, slow_percent, seconds)
	puddles.append(puddle)
	puddle.expired.connect(func(p: MucusPuddle) -> void: puddles.erase(p))
	return puddle


func enemies_in_range(center: Vector2, radius: float) -> Array:
	return enemies.filter(func(e: Enemy) -> bool: return not e.finished and e.position.distance_to(center) <= radius)


## Handles a tap given in screen pixels.
func handle_tap(screen_position: Vector2) -> void:
	if state != "running":
		return
	var point := screen_to_world(screen_position)
	var nearest_enemy: Enemy = null
	var nearest_distance := TAP_RADIUS
	for enemy in enemies:
		var distance := enemy.position.distance_to(point)
		if not enemy.finished and distance <= nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance
	if nearest_enemy != null:
		enemy_tapped.emit(nearest_enemy)
		return
	for i in data.slots.size():
		if data.slots[i].distance_to(point) <= TAP_RADIUS:
			if towers.has(i):
				tower_tapped.emit(i)
			else:
				slot_tapped.emit(i)
			return
	nothing_tapped.emit()


## Builds a tower on an empty slot, charging its cost. Returns whether it was built.
func build_tower(slot: int, tower_id: String) -> bool:
	if state != "running" or towers.has(slot) or slot < 0 or slot >= data.slots.size():
		return false
	if not data.tower_ids.has(tower_id):
		return false
	var tower_data: TowerData = tower_catalog[tower_id]
	if not Economy.try_spend(tower_data.cost):
		return false
	var tower := Tower.new()
	tower.position = data.slots[slot]
	_tower_layer.add_child(tower)
	tower.setup(tower_data, slot, self)
	towers[slot] = tower
	_map.queue_redraw()
	return true


## Sells a tower and returns the amino acids it gave back.
func sell_tower(slot: int) -> int:
	if state != "running" or not towers.has(slot):
		return 0
	var tower: Tower = towers[slot]
	var refund := Economy.refund_for(tower.spent)
	Economy.add(refund)
	towers.erase(slot)
	tower.queue_free()
	_map.queue_redraw()
	return refund


func set_selected_tower(slot: int) -> void:
	for i in towers:
		towers[i].selected = (i == slot)


func call_next_wave() -> bool:
	return state == "running" and scheduler.call_next_wave()


func toggle_speed() -> void:
	speed = 2 if speed == 1 else 1
	Engine.time_scale = float(speed)
	speed_changed.emit(speed)


func set_paused(paused: bool) -> void:
	get_tree().paused = paused


func _build_view() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -1
	add_child(layer)
	var container := SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = SHRINK
	container.size = Vector2(720, 1280)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(360, 640)
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	_camera = Camera2D.new()
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	viewport.add_child(_camera)
	_camera.make_current()
	_map = MapView.new()
	viewport.add_child(_map)
	_map.setup(self)
	_ground_layer = Node2D.new()
	viewport.add_child(_ground_layer)
	_tower_layer = Node2D.new()
	viewport.add_child(_tower_layer)
	_enemy_layer = Node2D.new()
	_enemy_layer.y_sort_enabled = true
	viewport.add_child(_enemy_layer)
	_air_layer = Node2D.new()
	viewport.add_child(_air_layer)


func _spawn_enemy(enemy_id: String) -> void:
	var enemy_data: EnemyData = enemy_catalog.get(enemy_id)
	if enemy_data == null:
		push_error("unknown enemy id: %s" % enemy_id)
		return
	var enemy := Enemy.new()
	_enemy_layer.add_child(enemy)
	enemy.setup(enemy_data, curve, damage_table)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_exit.connect(_on_enemy_reached_exit)
	enemies.append(enemy)


func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	Economy.add(enemy.data.amino_acid_reward)
	orbs_requested.emit(enemy.position, enemy.data.amino_acid_reward)
	_check_victory()


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	enemies.erase(enemy)
	body_health = maxi(0, body_health - enemy.data.body_damage)
	body_health_changed.emit(body_health, data.body_health)
	if body_health <= 0:
		state = "lost"
		defeat.emit()
		return
	_check_victory()


func _check_victory() -> void:
	if state == "running" and body_health > 0 and scheduler.spawning_done() and enemies.is_empty():
		state = "won"
		victory.emit()
