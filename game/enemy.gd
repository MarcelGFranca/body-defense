## One enemy walking along the level path.
class_name Enemy
extends Node2D

signal died(enemy: Enemy)
signal reached_exit(enemy: Enemy)
## Emitted when a boss that splits loses half of its health; the level replaces it with copies.
signal split(enemy: Enemy)

const HIT_COOLDOWN := 1.4
const SLOW_ANIMATION_COOLDOWN := 3.0
const BAR_SIZE := Vector2(20, 3)
## Colour flashed on the sprite when a type without its own hit animation hurts it.
const HIT_TINTS := {
	"thermal": Color(1.0, 0.6, 0.35),
	"chemical": Color(0.6, 1.0, 0.45),
	"immunological": Color(0.85, 0.6, 1.0),
}
## A reviving enemy lies still this long after its death animation, then gets up.
const REVIVE_PAUSE := 0.5
## Seconds the armour shell takes to close, and the flash when it breaks.
const SHELL_IN := 0.3
const SHELL_OUT := 0.5
const REVIVE_GLOW := Color(0.5, 1.0, 0.55)
const MARK_SHADER := "res://assets/shaders/mark_tint.gdshader"

var data: EnemyData
var status: EnemyStatus
var health := 0.0
var max_health := 0.0
var progress := 0.0
## What this enemy gives when it dies and takes from the body when it gets out. Copies and chain
## segments share the values of the enemy they came from.
var reward := 0
var body_damage := 1
var is_copy := false
## Index of the wave that sent this enemy, and the tower that hurt it last (for the stats).
var wave := -1
var last_source := ""
var speed := 0.0
## Set by the level so traits can reach the towers and spawn other enemies.
var level: Level
## True once the enemy has died or reached the exit.
var finished := false

var _curve: Curve2D
var _length := 0.0
var _table: DamageTable
var _sprite: AnimatedSprite2D
var _one_shot_playing := false
var _on_done := Callable()
var _tint_tween: Tween
var _hit_cooldown := 0.0
var _slow_cooldown := 0.0
var _revived := false
## True while a reviving enemy lies down and gets up again: it cannot be hurt, targeted or moved.
var _reviving := false
var _shell_on := false
var _shell_amount := 0.0
var _shell_burst := 0.0
var _shell_drawn := false
var _revive_clock := 0.0
var _revive_seconds := 0.4
var _revive_has_art := false
var _getting_up := false
var _split_done := false
var _damage_taken: Dictionary = {}  # damage type -> damage dealt so far
var _resisted_type := ""
var _aura_clock := 0.0
var _blocked_by: BlockerUnit
## True while the one-shot animation being played is the attack against a summoned unit.
var _unit_attack_playing := false
var _dye: ShaderMaterial
var _flames: BurnFlames


## `options` may hold "health", "reward", "damage", "scale", "progress", "copy" and "level".
func setup(enemy_data: EnemyData, curve: Curve2D, table: DamageTable, options: Dictionary = {}) -> void:
	data = enemy_data
	level = options.get("level", null)
	# Health and reward come from the roster, scaled by the difficulty, unless they were worked out from
	# an enemy that was already scaled (the copies of a split).
	var difficulty: DifficultyData = level.difficulty if level != null else null
	var health_scale := 1.0 if difficulty == null or bool(options.get("final", false)) else difficulty.enemy_health
	var reward_scale := 1.0 if difficulty == null or bool(options.get("final", false)) else difficulty.reward
	health = ceilf(float(options.get("health", data.health)) * health_scale)
	max_health = health
	reward = maxi(1, roundi(float(options.get("reward", data.amino_acid_reward)) * reward_scale))
	speed = data.speed * (difficulty.enemy_speed if difficulty != null else 1.0)
	wave = int(options.get("wave", -1))
	body_damage = int(options.get("damage", data.body_damage))
	is_copy = bool(options.get("copy", false))
	progress = float(options.get("progress", 0.0))
	status = EnemyStatus.new(data)
	_curve = curve
	_length = curve.get_baked_length()
	_table = table
	position = curve.sample_baked(maxf(progress, 0.0))
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = EnemySprites.frames_for(data)
	_sprite.scale = Vector2.ONE * float(options.get("scale", 1.0))
	add_child(_sprite)
	_sprite.play("walk")
	_flames = BurnFlames.new()
	_flames.visible = false
	add_child(_flames)


## True when the trait is on for this enemy: it belongs to the roster entry and the level allows it.
func has_trait(trait_id: String) -> bool:
	return data.trait_id == trait_id and (level == null or level.trait_enabled(trait_id))


func param(key: String, fallback: float) -> float:
	return float(data.trait_params.get(key, fallback))


## Dormant enemies (Herpes simplex) are immune for a few moments of every cycle.
func is_dormant() -> bool:
	if not has_trait("dormant"):
		return false
	var period := param("period", 4.0)
	return fposmod(status.time, period) >= period - param("seconds", 1.5)


## Advanced by the level every frame, so tests can step the simulation by hand.
func step(delta: float) -> void:
	if finished:
		return
	if _reviving:
		_flames.set_burning(false)
		_step_revive(delta)
		return
	_hit_cooldown -= delta
	_slow_cooldown -= delta
	for tick in status.advance(delta):
		take_damage(float(tick["damage"]), String(tick["type"]), String(tick["source"]))
		if finished:
			return
	_flames.set_burning(status.has_dot())
	_update_mark_dye()
	_update_shell(delta)
	_step_aura(delta)
	_update_blocker(delta)
	var speed_factor := 0.0 if _blocked_by != null else status.speed_multiplier()
	progress += speed * speed_factor * delta
	_sprite.speed_scale = maxf(0.3, status.speed_multiplier())
	position = _curve.sample_baked(clampf(progress, 0.0, _length))
	if progress >= _length:
		_exit()


## A dormant enemy grows a grey armour shell while it is immune. The shell spins in and snaps shut
## (SHELL_IN seconds), and when the immunity ends the plates fly off with a flash (SHELL_OUT).
func _update_shell(delta: float) -> void:
	var armoured := is_dormant()
	if armoured and not _shell_on:
		_shell_amount = 0.0
		_shell_burst = 0.0
	if _shell_on and not armoured:
		_shell_burst = SHELL_OUT
	_shell_on = armoured
	var animating := false
	if armoured:
		_shell_amount = minf(1.0, _shell_amount + delta / SHELL_IN)
		animating = true
	elif _shell_burst > 0.0:
		_shell_burst = maxf(0.0, _shell_burst - delta)
		animating = true
	if animating or _shell_drawn:
		_shell_drawn = animating
		queue_redraw()


## The shell is drawn from the shell amount (0 to 1 while it closes) or the burst (1 to 0 while it breaks).
func _draw_shell() -> void:
	var plates := 8
	var radius := 17.0
	if _shell_on:
		var t := _shell_amount
		var ease := 1.0 - pow(1.0 - t, 3.0)
		var r := lerpf(34.0, radius, ease)
		var spin := (1.0 - ease) * PI
		var alpha := clampf(t * 2.0, 0.0, 1.0)
		_draw_plates(plates, r, spin, 1.0, alpha)
		if t < 1.0:
			draw_arc(Vector2.ZERO, lerpf(40.0, radius, ease), 0.0, TAU, 32, Color(1, 1, 1, (1.0 - t) * 0.6), 2.0)
		else:
			var pulse := 0.5 + 0.5 * sin(status.time * 6.0)
			draw_arc(Vector2.ZERO, radius + 4.0, 0.0, TAU, 32, Color(0.7, 0.85, 1.0, 0.18 + 0.18 * pulse), 2.0)
	elif _shell_burst > 0.0:
		var k := 1.0 - _shell_burst / SHELL_OUT
		_draw_plates(plates, radius + k * 26.0, k * 1.2, 1.0 - k, 1.0 - k)
		var glow := Color(1.0, 0.95, 0.7)
		for ring in 3:
			var kr := clampf(k * 1.3 - ring * 0.15, 0.0, 1.0)
			if kr > 0.0:
				draw_arc(Vector2.ZERO, radius + kr * 34.0, 0.0, TAU, 40, Color(glow.r, glow.g, glow.b, (1.0 - kr) * 0.9), 3.0 - ring * 0.8)
		draw_circle(Vector2.ZERO, radius * (1.0 - k * 0.3), Color(1.0, 0.97, 0.8, (1.0 - k) * 0.55))
		for i in 12:
			var dir := Vector2.from_angle(TAU * i / 12.0 + 0.2)
			draw_line(dir * (radius + k * 10.0), dir * (radius + 6.0 + k * 30.0), Color(1, 1, 0.85, (1.0 - k)), 2.0)


## A ring of steel-grey segments with rivets, turned by spin and faded by alpha.
func _draw_plates(plates: int, radius: float, spin: float, _scale: float, alpha: float) -> void:
	for i in plates:
		var a0 := TAU * i / plates + 0.06 + spin
		var a1 := TAU * (i + 1) / plates - 0.06 + spin
		draw_arc(Vector2.ZERO, radius, a0, a1, 6, Color(0.66, 0.72, 0.8, 0.95 * alpha), 5.0)
		draw_arc(Vector2.ZERO, radius + 2.0, a0, a1, 6, Color(0.9, 0.94, 1.0, 0.9 * alpha), 1.5)
		draw_circle(Vector2.from_angle((a0 + a1) / 2.0) * radius, 1.6, Color(0.35, 0.4, 0.5, alpha))


## A marked enemy is dyed with the color of the lymphocyte that marked it, until the mark ends.
func _update_mark_dye() -> void:
	var amount := status.mark_amount()
	if amount <= 0.0 and _dye == null:
		return
	if _dye == null:
		_dye = ShaderMaterial.new()
		_dye.shader = load(MARK_SHADER)
		_sprite.material = _dye
	_dye.set_shader_parameter("tint", status.mark_color())
	_dye.set_shader_parameter("amount", amount)


## HIV switches off the towers around it every few seconds.
func _step_aura(delta: float) -> void:
	if level == null or not has_trait("tower_disable_aura"):
		return
	_aura_clock += delta
	if _aura_clock < param("interval", 3.0):
		return
	_aura_clock = 0.0
	for tower: Tower in level.towers.values():
		if tower.position.distance_to(position) <= param("radius", 70.0):
			tower.disable()
	queue_redraw()


## A summoned unit in the way holds the enemy and trades blows with it. Bosses push through.
func _update_blocker(delta: float) -> void:
	if level == null or data.role == "boss":
		_blocked_by = null
		return
	if _blocked_by != null and (not is_instance_valid(_blocked_by) or not _blocked_by.is_alive()):
		_blocked_by = null
	if _blocked_by == null:
		_blocked_by = level.blocker_for(self)
	if _blocked_by != null:
		_blocked_by.fight(self, delta)
		if not _one_shot_playing:
			_start_unit_attack()


## The summoned unit that holds this enemy right now, or null.
func held_by() -> BlockerUnit:
	return _blocked_by if _is_fighting_unit() else null


## True while a summoned unit holds this enemy and is still alive.
func _is_fighting_unit() -> bool:
	return not finished and _blocked_by != null and is_instance_valid(_blocked_by) and _blocked_by.is_alive()


## An enemy held by a neutrophil strikes back with its attack animation, facing the neutrophil, over and over
## until the neutrophil is gone. A hit reaction may interrupt it; the attack then starts again.
func _start_unit_attack() -> void:
	if not _is_fighting_unit() or not _sprite.sprite_frames.has_animation("attack"):
		return
	_sprite.flip_h = _blocked_by.position.x < position.x
	_play_once("attack")
	_unit_attack_playing = true


## True while the enemy lies down and gets up again (Clostridioides difficile).
func is_reviving() -> bool:
	return _reviving


## Name of the animation being played.
func current_animation() -> String:
	return String(_sprite.animation)


## Applies an attack. Returns the damage that was actually dealt.
func take_damage(amount: float, damage_type: String, source: String = "") -> int:
	if finished or is_dormant() or _reviving:
		return 0
	_update_resistance()
	var resistance := param("factor", 0.5) if damage_type == _resisted_type and _resisted_type != "" else 1.0
	var dealt := DamageCalculator.resolve(amount, damage_type, data, _table, status.mark_bonus(), resistance)
	if source != "":
		last_source = source
	if level != null:
		level.stats.record_damage(source if source != "" else "other", minf(float(dealt), maxf(health, 0.0)))
	health -= dealt
	_damage_taken[damage_type] = float(_damage_taken.get(damage_type, 0.0)) + dealt
	queue_redraw()
	if health <= 0.0:
		_die()
	elif _should_split():
		_split_in_two()
	else:
		if DamageCalculator.factor_for(damage_type, data, _table) <= 0.0:
			GameAudio.play_sfx(GameAudio.config.blocked_sound)
		elif dealt > 0:
			GameAudio.play_sfx(data.sound_hit)
		if _hit_cooldown <= 0.0 and (not _one_shot_playing or _unit_attack_playing):
			_hit_cooldown = HIT_COOLDOWN
			_play_once(_hit_animation(damage_type, dealt))
		if dealt > 0:
			_tint_hit(damage_type)
	return dealt


## Types without their own hit animation flash their colour on the sprite.
func _tint_hit(damage_type: String) -> void:
	if _sprite == null or not HIT_TINTS.has(damage_type):
		return
	if _tint_tween != null:
		_tint_tween.kill()
	_sprite.self_modulate = HIT_TINTS[damage_type]
	_tint_tween = create_tween()
	_tint_tween.tween_property(_sprite, "self_modulate", Color.WHITE, 0.25)


## Plays the slowed reaction the first time a slow reaches the enemy.
func notify_slowed() -> void:
	if finished or _one_shot_playing or _slow_cooldown > 0.0:
		return
	_slow_cooldown = SLOW_ANIMATION_COOLDOWN
	_play_once("hit_mucus")


func _hit_animation(damage_type: String, dealt: int) -> String:
	if damage_type == "antiviral":
		return "hit_antiviral" if dealt > 0 else "immune_antiviral"
	return "hit_physical"


## Staphylococcus aureus gains resistance, along the path, to the damage type that hurt it the most.
func _update_resistance() -> void:
	if _resisted_type != "" or not has_trait("gain_resistance") or progress < _length * param("at", 0.4):
		return
	var most := 0.0
	for type in _damage_taken:
		if float(_damage_taken[type]) > most:
			most = float(_damage_taken[type])
			_resisted_type = String(type)
	if _resisted_type != "" and _sprite != null:
		_flash_resistance()


func _flash_resistance() -> void:
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(1.0, 0.8, 0.3), 0.15)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.3)


func resisted_type() -> String:
	return _resisted_type


func _should_split() -> bool:
	return has_trait("split_at_half") and not is_copy and not _split_done and health <= max_health * 0.5


## Neisseria meningitidis breaks into smaller copies when half of its health is gone.
func _split_in_two() -> void:
	_split_done = true
	finished = true
	queue_redraw()
	split.emit(self)
	_fade_out()


## Clostridioides difficile comes back once, as a spore with little health: it dies, lies still, then
## gets up (the death animation played backwards, with a green glow). Timed by step(), like the rest of the game.
func _revive() -> void:
	_revived = true
	_reviving = true
	_one_shot_playing = true
	_revive_clock = 0.0
	_damage_taken.clear()
	health = 0.0
	queue_redraw()
	GameAudio.play_sfx(data.sound_death)
	if _on_done.is_valid() and _sprite.animation_finished.is_connected(_on_done):
		_sprite.animation_finished.disconnect(_on_done)
	var frames := _sprite.sprite_frames
	_revive_has_art = frames.has_animation("death")
	_revive_seconds = frames.get_frame_count("death") / frames.get_animation_speed("death") if _revive_has_art else 0.4
	_getting_up = false
	if _revive_has_art:
		_sprite.play("death")


## Moves the revive along: lying down, getting up (animation backwards and glow), then back to work.
func _step_revive(delta: float) -> void:
	_revive_clock += delta
	var lying := _revive_seconds + REVIVE_PAUSE
	if _revive_clock < lying:
		if not _revive_has_art:
			_sprite.modulate.a = lerpf(1.0, 0.3, minf(_revive_clock / _revive_seconds, 1.0))
		return
	var risen := (_revive_clock - lying) / _revive_seconds
	if risen >= 1.0:
		_reviving = false
		_one_shot_playing = false
		health = ceilf(max_health * param("health", 0.25))
		_sprite.modulate = Color.WHITE
		_sprite.play("walk")
		queue_redraw()
		return
	if not _getting_up:
		_getting_up = true
		if _revive_has_art:
			_sprite.play_backwards("death")
	var glow := 1.0 - absf(risen * 2.0 - 1.0)
	_sprite.modulate = Color.WHITE.lerp(REVIVE_GLOW, glow)
	if not _revive_has_art:
		_sprite.modulate.a = lerpf(0.3, 1.0, risen)


func _die() -> void:
	if has_trait("revive") and not _revived:
		_revive()
		return
	finished = true
	queue_redraw()
	GameAudio.play_sfx(data.sound_death)
	died.emit(self)
	_play_once("death", true)


func _exit() -> void:
	finished = true
	queue_redraw()
	GameAudio.play_sfx(data.sound_attack)
	reached_exit.emit(self)
	_play_once("attack", true)


func _play_once(anim: String, free_after := false) -> void:
	var frames := _sprite.sprite_frames
	if _on_done.is_valid() and _sprite.animation_finished.is_connected(_on_done):
		_sprite.animation_finished.disconnect(_on_done)
	if not frames.has_animation(anim):
		if free_after:
			_fade_out()
		return
	_one_shot_playing = true
	_unit_attack_playing = false
	_sprite.play(anim)
	_on_done = func() -> void:
		if free_after:
			queue_free()
		else:
			_one_shot_playing = false
			_unit_attack_playing = false
			_sprite.flip_h = false
			_sprite.play("walk")
			_start_unit_attack()
	_sprite.animation_finished.connect(_on_done, CONNECT_ONE_SHOT)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if finished:
		return
	if level != null and has_trait("tower_disable_aura"):
		draw_arc(Vector2.ZERO, param("radius", 70.0), 0.0, TAU, 48, Color(0.9, 0.3, 0.3, 0.35), 1.0)
	if _shell_on or _shell_burst > 0.0:
		_draw_shell()
	if health >= max_health:
		return
	var origin := Vector2(-BAR_SIZE.x / 2.0, -22.0)
	draw_rect(Rect2(origin - Vector2(1, 1), BAR_SIZE + Vector2(2, 2)), Color("2b1b3a"))
	var fraction := clampf(health / max_health, 0.0, 1.0)
	var color := Color("6ad4a0") if fraction > 0.5 else Color("f4d35e") if fraction > 0.25 else Color("e84a5f")
	draw_rect(Rect2(origin, Vector2(BAR_SIZE.x * fraction, BAR_SIZE.y)), color)
