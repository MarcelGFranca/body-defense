## One playable level: the map, enemies, towers, waves and the win and lose rules.
class_name Level
extends Node

signal body_health_changed(value: int, max_value: int)
signal wave_started(number: int, total: int)
signal victory
signal defeat
## Emitted when an enemy dies, so the HUD can fly amino acid orbs to the counter.
signal orbs_requested(world_position: Vector2, amount: int)
## Emitted when a tower is built, so the HUD can fly amino acid orbs from the counter to it.
signal tower_built(world_position: Vector2, cost: int)
signal enemy_tapped(enemy: Enemy)
signal slot_tapped(slot_index: int)
signal tower_tapped(slot_index: int)
signal nothing_tapped
signal speed_changed(speed: int)
signal scrolled

const LEVEL_PATH := "res://data/levels/level_1.tres"
const LEVEL_PATH_FORMAT := "res://data/levels/level_%d.tres"
const DIFFICULTY_PATH_FORMAT := "res://data/difficulties/%s.tres"
const DAMAGE_TABLE_PATH := "res://data/damage_table.tres"
## Screen pixels per map unit: the map is drawn at 360 x 640 and shown at 2x.
const SHRINK := 2
## When the field is empty between waves, the next wave starts after at most this many seconds.
const EMPTY_FIELD_WAIT := 5.0
const TAP_RADIUS := 24.0
## Size of the drawn view in map units, and the parts of it covered by the HUD bars.
const VIEW_SIZE := Vector2(360, 640)
const SAFE_TOP := 56.0
const SAFE_BOTTOM := 100.0

var data: LevelData
var difficulty: DifficultyData
var stats := GameStats.new()
var max_body_health := 0
var damage_table: DamageTable
var enemy_catalog: Dictionary = {}
var tower_catalog: Dictionary = {}
var curve := Curve2D.new()
var scheduler: WaveScheduler
var enemies: Array[Enemy] = []
var puddles: Array[MucusPuddle] = []
var blockers: Array[BlockerUnit] = []
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


func _init(level_data: LevelData = null, difficulty_data: DifficultyData = null) -> void:
	data = level_data
	difficulty = difficulty_data


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	if data == null:
		data = load(LEVEL_PATH)
	if difficulty == null:
		difficulty = load(DIFFICULTY_PATH_FORMAT % "medium") as DifficultyData
	if difficulty == null:
		difficulty = DifficultyData.new()
	damage_table = load(DAMAGE_TABLE_PATH)
	enemy_catalog = DataLoader.load_all("res://data/enemies")
	tower_catalog = DataLoader.load_all("res://data/towers")
	for point in data.path_points:
		curve.add_point(point)
	_build_view()
	set_scroll(Vector2(0.0, -SAFE_TOP))
	scheduler = WaveScheduler.new(data.waves, difficulty.wave_time)
	scheduler.enemy_spawned.connect(_spawn_enemy)
	scheduler.wave_started.connect(func(index: int) -> void: wave_started.emit(index + 1, data.waves.size()))
	Economy.reset(roundi(data.starting_amino_acids * difficulty.start_amino))
	max_body_health = maxi(1, roundi(data.body_health * difficulty.body_health))
	body_health = max_body_health
	body_health_changed.emit(body_health, max_body_health)
	victory.connect(func() -> void: GameAudio.play_jingle(GameAudio.config.victory_music))
	defeat.connect(func() -> void: GameAudio.play_jingle(GameAudio.config.defeat_music))
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
	if enemies.is_empty() and scheduler.started_count() > 0 and not scheduler.is_spawning():
		scheduler.shorten_wait(EMPTY_FIELD_WAIT)
	for tower: Tower in towers.values():
		tower.step(delta)
	for unit in blockers.duplicate():
		if is_instance_valid(unit):
			unit.step(delta, enemies)
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


## Slot of the built tower under a point given in screen pixels, or -1.
func tower_slot_at(screen_position: Vector2) -> int:
	var point := screen_to_world(screen_position)
	for i in data.slots.size():
		if towers.has(i) and data.slots[i].distance_to(point) <= TAP_RADIUS:
			return i
	return -1


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
	stats.record_build(tower_id, tower_data.cost)
	var tower := Tower.new()
	tower.position = data.slots[slot]
	_tower_layer.add_child(tower)
	tower.setup(tower_data, slot, self)
	towers[slot] = tower
	_map.queue_redraw()
	tower_built.emit(tower.position, tower_data.cost)
	return true


## Sells a tower and returns the amino acids it gave back.
func sell_tower(slot: int) -> int:
	if state != "running" or not towers.has(slot):
		return 0
	var tower: Tower = towers[slot]
	var refund := Economy.refund_for(tower.spent)
	Economy.add(refund)
	towers.erase(slot)
	for unit in blockers.duplicate():
		if unit.owner_tower == tower:
			unit.queue_free()
	tower.queue_free()
	_map.queue_redraw()
	return refund


## Moves a mobile tower (a lymphocyte) to another empty slot. It needs a moment to settle in.
func move_tower(from_slot: int, to_slot: int) -> bool:
	if state != "running" or not towers.has(from_slot) or towers.has(to_slot):
		return false
	if to_slot < 0 or to_slot >= data.slots.size():
		return false
	var tower: Tower = towers[from_slot]
	if tower.data.mobility != "mobile":
		return false
	towers.erase(from_slot)
	towers[to_slot] = tower
	tower.slot_index = to_slot
	tower.position = data.slots[to_slot]
	tower.settle()
	_map.queue_redraw()
	return true


## Places a neutrophil on the path, as close to `near` as the path allows.
func add_blocker(near: Vector2, shift: float, unit_health: float, unit_damage: float, source: Tower, radius: float = 0.0, move_speed: float = 0.0, regen: float = 0.0) -> BlockerUnit:
	var offset := clampf(curve.get_closest_offset(near) + shift, 20.0, curve.get_baked_length() - 20.0)
	var unit := BlockerUnit.new()
	_ground_layer.add_child(unit)
	unit.setup(curve, offset, unit_health, unit_damage, radius, move_speed, regen)
	unit.owner_tower = source
	blockers.append(unit)
	unit.died.connect(func(u: BlockerUnit) -> void: blockers.erase(u))
	unit.tree_exited.connect(func() -> void: blockers.erase(unit))
	return unit


func blocker_for(enemy: Enemy) -> BlockerUnit:
	for unit in blockers:
		if is_instance_valid(unit) and unit.try_hold(enemy):
			return unit
	return null


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
	if enemy_data.trait_id == "chain" and trait_enabled("chain"):
		_spawn_chain(enemy_data)
		return
	add_enemy(enemy_data)


## Puts an enemy on the path. `options` is passed on to `Enemy.setup`.
func add_enemy(enemy_data: EnemyData, options: Dictionary = {}) -> Enemy:
	var enemy := Enemy.new()
	_enemy_layer.add_child(enemy)
	options["level"] = self
	if not options.has("wave"):
		options["wave"] = scheduler.spawning_wave
	stats.record_spawn(int(options["wave"]), scheduler.clock)
	enemy.setup(enemy_data, curve, damage_table, options)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_exit.connect(_on_enemy_reached_exit)
	enemy.split.connect(_on_enemy_split)
	enemies.append(enemy)
	return enemy


func trait_enabled(trait_id: String) -> bool:
	return not data.disabled_traits.has(trait_id)


## A chain (Streptococcus) walks as separate segments: each has its share of health and reward.
func _spawn_chain(enemy_data: EnemyData) -> void:
	var segments := int(enemy_data.trait_params.get("segments", 3))
	var segment_data: EnemyData = enemy_data.duplicate()
	segment_data.sprite_dir = String(enemy_data.trait_params.get("segment_sprite", enemy_data.sprite_dir))
	for i in segments:
		add_enemy(segment_data, {
			"health": ceilf(enemy_data.health / segments),
			"reward": maxi(1, roundi(float(enemy_data.amino_acid_reward) / segments)),
			"damage": maxi(1, ceili(float(enemy_data.body_damage) / segments)),
			"progress": -float(i) * float(enemy_data.trait_params.get("spacing", 16.0)),
			"wave": scheduler.spawning_wave,
		})


func _on_enemy_split(enemy: Enemy) -> void:
	enemies.erase(enemy)
	var copies := int(enemy.data.trait_params.get("copies", 2))
	for i in copies:
		add_enemy(enemy.data, {
			"health": ceilf(enemy.health / copies),
			"reward": maxi(1, roundi(float(enemy.reward) / copies)),
			"damage": maxi(1, ceili(float(enemy.body_damage) / copies)),
			"progress": enemy.progress - float(i) * 10.0,
			"scale": float(enemy.data.trait_params.get("scale", 0.75)),
			"copy": true,
			"final": true,
			"wave": enemy.wave,
		})


func _release_minions(enemy: Enemy) -> void:
	var minion_data: EnemyData = enemy_catalog.get(String(enemy.data.trait_params.get("enemy", "rhinovirus")))
	if minion_data == null:
		return
	for i in int(enemy.data.trait_params.get("count", 2)):
		add_enemy(minion_data, {
			"progress": enemy.progress - float(i) * 12.0,
			"scale": float(enemy.data.trait_params.get("scale", 0.7)),
			"copy": true,
			"wave": enemy.wave,
		})


func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	stats.record_kill(enemy.data.id, enemy.last_source if enemy.last_source != "" else "other", enemy.wave, scheduler.clock)
	Economy.add(enemy.reward)
	orbs_requested.emit(enemy.position, enemy.reward)
	if enemy.has_trait("release_minions"):
		_release_minions(enemy)
	_check_victory()


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	enemies.erase(enemy)
	stats.record_leak(enemy.data.id, enemy.wave, scheduler.clock)
	body_health = maxi(0, body_health - enemy.body_damage)
	body_health_changed.emit(body_health, max_body_health)
	if body_health <= 0:
		state = "lost"
		defeat.emit()
		return
	_check_victory()


func _check_victory() -> void:
	if state == "running" and body_health > 0 and scheduler.spawning_done() and enemies.is_empty():
		state = "won"
		victory.emit()
