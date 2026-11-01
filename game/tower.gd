## A defender built on a slot.
class_name Tower
extends Node2D

const NORMAL_DISABLE_SECONDS := 3.0
const MOBILE_DISABLE_SECONDS := 6.0
const FLASH_SECONDS := 0.15
const SETTLE_SECONDS := 1.5
## How often a slowing tower plays its secreting animation while enemies are in range.
const SECRETE_INTERVAL := 2.0
## An area attack sends a ring from the tower out to the edge of its range in this time.
const PULSE_SECONDS := 0.6
## The fever wave of the hypothalamus is slower, so the fire along it can be seen.
const FEVER_WAVE_SECONDS := 1.1
const FEVER_FLAMES := 16
## While enemies burn, the hypothalamus attacks again this often.
const FEVER_INTERVAL := 1.0
## A mist stays this long after the last attack that fed it, fading out.
const MIST_FADE_SECONDS := 1.5
const PULSE_COLORS := {
	"chemical": Color("aaff78"),
	"antiviral": Color("7fe8ff"),
	"thermal": Color("ff9a5c"),
	"physical": Color("ffffff"),
}

var data: TowerData
var slot_index := -1
## Total amino acids spent on this tower, used for the sell refund.
var spent := 0
## True while the amino acids are still flying to the tower: it is hidden and does nothing.
var under_construction := false
var selected := false:
	set(value):
		selected = value
		queue_redraw()

var _level: Level
## Name this tower goes by in the slows and roots it puts on enemies (made once: it is used every frame).
var _source_key := ""
var _cooldown := 0.0
var _disabled_for := 0.0
var _flash := 0.0
var _flash_target := Vector2.ZERO
## Seconds since the last area attack, or -1 when no ring is spreading.
var _pulse_age := -1.0
var _pulse := 0.0
## How strength the mist is, from 0 (hidden) to 1; every attack refills it.
var _mist_level := 0.0
var _was_animated := false
var _missing_art := false
var _sprite: AnimatedSprite2D
var _on_attack_done := Callable()
var _settling := 0.0
## Plain arrays: their entries are freed objects once they die, which typed arrays and typed parameters reject.
var _units: Array = []
## Enemies this tower is holding: {"enemy": Enemy, "age": seconds since it was caught}.
var _holds: Array[Dictionary] = []
var _beam: TowerBeam


func setup(tower_data: TowerData, slot: int, level: Level) -> void:
	data = tower_data
	slot_index = slot
	spent = data.cost
	_level = level
	_source_key = str(get_instance_id())
	var frames := TowerSprites.frames_for(data.id)
	var art_path := "res://assets/towers/%s.png" % data.id
	if frames != null:
		_sprite = AnimatedSprite2D.new()
		_sprite.sprite_frames = frames
		add_child(_sprite)
		_sprite.play("idle")
	elif ResourceLoader.exists(art_path):
		var sprite := Sprite2D.new()
		sprite.texture = load(art_path)
		add_child(sprite)
	else:
		_missing_art = true
	if data.beam_width > 0.0:
		_beam = TowerBeam.new()
		_beam.setup(data.beam_width)
		add_child(_beam)
	if data.behavior == "root_aura":
		var tendrils := RootTendrils.new()
		tendrils.setup(self)
		add_child(tendrils)


## How visible the mist is, from 0 to 1.
func mist_level() -> float:
	return _mist_level


## Advanced by the level every frame, so tests can step the simulation by hand.
func step(delta: float) -> void:
	if under_construction:
		return
	_pulse += delta
	_update_holds(delta)
	_flash = maxf(0.0, _flash - delta)
	_mist_level = maxf(0.0, _mist_level - delta / MIST_FADE_SECONDS)
	if _pulse_age >= 0.0:
		_pulse_age = _pulse_age + delta if _pulse_age + delta < _pulse_seconds() else -1.0
	if _settling > 0.0:
		_settling -= delta
		queue_redraw()
		return
	if _disabled_for > 0.0:
		_disabled_for -= delta
		queue_redraw()
		return
	match data.behavior:
		"single_target":
			_step_single_target(delta)
		"damage_aura":
			_step_damage_aura(delta)
		"slow_puddle":
			_step_slow_puddle(delta)
		"slow_aura":
			_step_slow_aura(delta)
		"root_aura":
			_step_root_aura()
		"dot_aura":
			_step_dot_aura(delta)
		"summon_marker":
			_step_summon_marker(delta)
		"summon_units":
			_step_summon_units(delta)
	_redraw_if_animated()


## Redraws only while something drawn by the tower changes (aura, mist, ring, flash, shade, selection), and once more when it stops.
func _redraw_if_animated() -> void:
	var animated := selected or data.behavior.ends_with("_aura") or _pulse_age >= 0.0 or _flash > 0.0 \
		or _mist_level > 0.0 or _disabled_for > 0.0 or _settling > 0.0
	if animated or _was_animated:
		queue_redraw()
	_was_animated = animated


## Name of the animation being played, or an empty string for towers drawn as a still image.
func current_animation() -> String:
	return String(_sprite.animation) if _sprite != null else ""


## Plays the attack animation once, facing the target when `direction_x` is not 0.
func play_attack(direction_x: float = 0.0) -> void:
	if _sprite == null or not _sprite.sprite_frames.has_animation("attack"):
		return
	if direction_x != 0.0:
		_sprite.flip_h = direction_x < 0.0
	if _on_attack_done.is_valid() and _sprite.animation_finished.is_connected(_on_attack_done):
		_sprite.animation_finished.disconnect(_on_attack_done)
	_sprite.speed_scale = 1.0
	_sprite.play("attack")
	_on_attack_done = _after_attack
	_sprite.animation_finished.connect(_on_attack_done, CONNECT_ONE_SHOT)


## A tower with a charging animation spends the rest of its interval charging, then waits fully charged.
func _after_attack() -> void:
	var frames := _sprite.sprite_frames
	if not frames.has_animation("charge"):
		_sprite.play("idle")
		return
	var attack_seconds := frames.get_frame_count("attack") / frames.get_animation_speed("attack")
	var charge_seconds := frames.get_frame_count("charge") / frames.get_animation_speed("charge")
	_sprite.speed_scale = charge_seconds / maxf(data.attack_interval - attack_seconds, 0.1)
	_sprite.play("charge")


## Stops the tower for a while. Lymphocytes (mobile towers) stay disabled twice as long.
func disable() -> void:
	_disabled_for = MOBILE_DISABLE_SECONDS if data.mobility == "mobile" else NORMAL_DISABLE_SECONDS


## Hides the tower until its amino acids arrive.
func begin_construction() -> void:
	under_construction = true
	visible = false


## The amino acids arrived: the tower appears with a small pop.
func finish_construction() -> void:
	if not under_construction:
		return
	under_construction = false
	visible = true
	scale = Vector2(0.6, 0.6)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	queue_redraw()


## A lymphocyte that has just been moved rests for a moment before it works again.
func settle() -> void:
	_settling = SETTLE_SECONDS
	_cooldown = 0.0
	queue_redraw()


func is_settling() -> bool:
	return _settling > 0.0


func is_disabled() -> bool:
	return _disabled_for > 0.0


func _enemies() -> Array:
	return _level.enemies_in_range(position, data.range_px)


## The enemy in range that is furthest along the path: the first one of the queue.
func _first_enemy() -> Enemy:
	return _level.first_enemy_in_range(position, data.range_px)


func _step_single_target(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := _first_enemy()
	if target == null:
		return
	target.take_damage(data.attack_damage, data.damage_type, data.id)
	_cooldown = data.attack_interval
	_flash = FLASH_SECONDS
	_flash_target = target.position - position
	if _beam != null:
		_beam.fire(_flash_target)
	play_attack(_flash_target.x)
	GameAudio.play_sfx(data.sound_attack)


func _step_damage_aura(delta: float) -> void:
	if data.slow_percent > 0.0:
		_slow_unaffected_enemies_excluded()
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var targets := _enemies()
	if targets.is_empty():
		return
	for enemy: Enemy in targets:
		enemy.take_damage(data.attack_damage, data.damage_type, data.id)
	_cooldown = data.attack_interval
	_pulse_age = 0.0
	_mist_level = 1.0
	play_attack()
	GameAudio.play_sfx(data.sound_attack)


## Throws a glob of mucus at the first enemy in range; it leaves a puddle that slows whoever crosses it.
func _step_slow_puddle(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := _first_enemy()
	if target == null:
		return
	_level.throw_mucus(position, target, data)
	_cooldown = data.attack_interval
	play_attack(target.position.x - position.x)
	GameAudio.play_sfx(data.sound_attack)


## A damaging tower that also slows only slows the targets its damage type can affect.
func _slow_unaffected_enemies_excluded() -> void:
	for enemy: Enemy in _enemies():
		if DamageCalculator.factor_for(data.damage_type, enemy.data, _level.damage_table) > 0.0:
			enemy.status.apply_slow(_source_key, data.slow_percent)


func _step_slow_aura(delta: float) -> void:
	var targets := _enemies()
	for enemy: Enemy in targets:
		if enemy.status.apply_slow(_source_key, data.slow_percent):
			enemy.notify_slowed()
	_cooldown -= delta
	if not targets.is_empty() and _cooldown <= 0.0:
		_cooldown = SECRETE_INTERVAL
		play_attack()


## The enemies held by tendrils right now.
func holds() -> Array[Dictionary]:
	return _holds


func _update_holds(delta: float) -> void:
	# Untyped on purpose: a rooted enemy that died has been freed, and a typed variable cannot hold it.
	_holds = _holds.filter(func(hold: Dictionary) -> bool:
		var enemy = hold["enemy"]
		return is_instance_valid(enemy) and not enemy.finished and enemy.status.is_rooted())
	for hold in _holds:
		hold["age"] = float(hold["age"]) + delta


## Sends a tendril to each enemy in range that is ready to be rooted, the ones furthest along the path first,
## up to `root_targets` held at the same time. A tendril stays until its enemy is free; only a new send
## makes the tower animate and play its sound (once per step, however many tendrils it sends).
func _step_root_aura() -> void:
	var free := data.root_targets - _holds.size()
	if free <= 0:
		return
	var sent := false
	var targets := _enemies()
	targets.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.progress > b.progress)
	for enemy: Enemy in targets:
		if free <= 0:
			break
		if enemy.status.apply_root(_source_key, data.root_seconds, data.root_cooldown):
			free -= 1
			_holds.append({"enemy": enemy, "age": 0.0})
			if not sent:
				sent = true
				play_attack(enemy.position.x - position.x)
	if sent:
		GameAudio.play_sfx(data.sound_attack)


## Keeps the enemies in range burning: the fire goes back to its full time every step. The tower animates,
## plays its sound and sends the fever wave when it ignites a new enemy and then once per second while any
## enemy in range burns, so it never looks idle with enemies near.
func _step_dot_aura(delta: float) -> void:
	_cooldown -= delta
	var ignited := false
	var targets := _enemies()
	for enemy: Enemy in targets:
		var was_burning := enemy.status.has_dot()
		enemy.status.apply_dot(data.dot_damage, data.damage_type, data.dot_seconds, data.id)
		if not was_burning:
			ignited = true
	if ignited or (not targets.is_empty() and _cooldown <= 0.0):
		_cooldown = FEVER_INTERVAL
		_pulse_age = 0.0
		play_attack()
		GameAudio.play_sfx(data.sound_attack)


## A B Lymphocyte releases antibodies: the strongest enemies in range are marked and hurt a little.
func _step_summon_marker(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var targets := _enemies()
	if targets.is_empty():
		return
	targets.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.progress > b.progress)
	for enemy: Enemy in targets.slice(0, maxi(1, data.mark_targets)):
		enemy.status.apply_mark(data.mark_bonus, data.mark_seconds, data.mark_color)
		enemy.take_damage(data.attack_damage, data.damage_type, data.id)
	_cooldown = data.attack_interval
	_flash = FLASH_SECONDS
	_flash_target = targets[0].position - position
	play_attack(_flash_target.x)
	GameAudio.play_sfx(data.sound_attack)


## Bone Marrow keeps a clock that never stops: every `summon_interval` seconds it creates a neutrophil if it has
## fewer than `summon_cap`. Deaths do not restart the clock, so a lost neutrophil is replaced at the next tick.
func _step_summon_units(delta: float) -> void:
	# Untyped on purpose: a neutrophil that died has been freed, and a typed parameter cannot take it.
	_units = _units.filter(func(unit) -> bool: return is_instance_valid(unit) and unit.is_alive())
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	_cooldown += data.summon_interval
	if _units.size() >= data.summon_cap:
		return
	var shift := (float(_units.size()) - 1.0) * 16.0
	_units.append(_level.add_blocker(position, shift, data.unit_health, data.unit_damage, self, data.unit_radius, data.unit_speed, data.unit_regen))
	play_attack()
	GameAudio.play_sfx(data.sound_attack)


## Waves of soft puffs that keep drifting outward and fading across the tower's area.
func _draw_mist() -> void:
	var strength := _mist_level
	const WAVES := 3
	const PUFFS := 10
	const PERIOD := 2.4
	for wave in WAVES:
		var phase := fposmod(_pulse / PERIOD + float(wave) / WAVES, 1.0)
		var radius := data.range_px * (0.2 + 0.8 * phase)
		var color := Color(data.mist_color, (1.0 - phase) * 0.42 * strength)
		for i in PUFFS:
			var angle := TAU * i / PUFFS + wave * 0.7 + sin(_pulse * 0.6 + wave) * 0.25
			CanvasShapes.disc(self, Vector2(cos(angle), sin(angle)) * radius * 0.85, 6.0 + 11.0 * phase, color)
	CanvasShapes.disc(self, Vector2.ZERO, data.range_px * (0.55 + 0.08 * sin(_pulse * 2.6)), Color(data.mist_color, 0.14 * strength))


func _pulse_seconds() -> float:
	return FEVER_WAVE_SECONDS if data.behavior == "dot_aura" else PULSE_SECONDS


## A red wave runs out to the edge of the range with stylised flames along its front.
func _draw_fever_wave() -> void:
	var fraction := _pulse_age / FEVER_WAVE_SECONDS
	var fade := 1.0 - fraction
	var radius := data.range_px * (1.0 - pow(fade, 2.0))
	CanvasShapes.disc(self, Vector2.ZERO, radius, Color(1.0, 0.15, 0.05, 0.16 * fade))
	draw_arc(Vector2.ZERO, radius * 0.8, 0.0, TAU, 48, Color(1.0, 0.3, 0.1, 0.5 * fade), 4.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(0.95, 0.12, 0.1, 0.9 * fade), 7.0)
	for i in FEVER_FLAMES:
		var angle := TAU * i / FEVER_FLAMES
		var phase := _pulse * 12.0 + i * 1.7
		BurnFlames.draw_flame(self, Vector2.from_angle(angle) * radius, 14.0 + 5.0 * sin(phase), 10.0, 3.0 * sin(phase * 0.8), fade)


func _draw() -> void:
	if data.mist_color.a > 0.0 and _mist_level > 0.0:
		_draw_mist()
	if _missing_art:
		CanvasShapes.disc(self, Vector2.ZERO, 12.0, Color("b9a7d6"))
	var is_aura := data.behavior.ends_with("_aura")
	if is_aura and data.mist_color.a == 0.0:
		var alpha := 0.10 + 0.05 * sin(_pulse * 3.0)
		CanvasShapes.disc(self, Vector2.ZERO, data.range_px, Color(0.8, 0.9, 1.0, alpha))
		draw_arc(Vector2.ZERO, data.range_px, 0.0, TAU, 48, Color(1, 1, 1, 0.25), 1.0)
	elif is_aura:
		draw_arc(Vector2.ZERO, data.range_px, 0.0, TAU, 48, Color(1, 1, 1, 0.18), 1.0)
	elif selected:
		draw_arc(Vector2.ZERO, data.range_px, 0.0, TAU, 48, Color(1, 1, 1, 0.5), 1.0)
	if selected and is_aura:
		draw_arc(Vector2.ZERO, data.range_px, 0.0, TAU, 48, Color(1, 1, 1, 0.8), 2.0)
	if _pulse_age >= 0.0 and data.behavior == "dot_aura":
		_draw_fever_wave()
	elif _pulse_age >= 0.0:
		var fraction := _pulse_age / PULSE_SECONDS
		var color: Color = PULSE_COLORS.get(data.damage_type, Color.WHITE)
		draw_arc(Vector2.ZERO, data.range_px * fraction, 0.0, TAU, 48, Color(color, 0.8 * (1.0 - fraction)), 3.0)
	if _flash > 0.0 and _beam == null:
		draw_line(Vector2.ZERO, _flash_target, Color("ffb3c7"), 3.0)
	if _disabled_for > 0.0 or _settling > 0.0:
		CanvasShapes.disc(self, Vector2.ZERO, 14.0, Color(0, 0, 0, 0.45))
