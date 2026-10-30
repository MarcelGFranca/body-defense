## One enemy walking along the level path.
class_name Enemy
extends Node2D

signal died(enemy: Enemy)
signal reached_exit(enemy: Enemy)

const HIT_COOLDOWN := 1.4
const SLOW_ANIMATION_COOLDOWN := 3.0
const BAR_SIZE := Vector2(20, 3)

var data: EnemyData
var status: EnemyStatus
var health := 0.0
var progress := 0.0
## True once the enemy has died or reached the exit.
var finished := false

var _curve: Curve2D
var _length := 0.0
var _table: DamageTable
var _sprite: AnimatedSprite2D
var _one_shot_playing := false
var _on_done := Callable()
var _hit_cooldown := 0.0
var _slow_cooldown := 0.0


func setup(enemy_data: EnemyData, curve: Curve2D, table: DamageTable) -> void:
	data = enemy_data
	health = data.health
	status = EnemyStatus.new(data)
	_curve = curve
	_length = curve.get_baked_length()
	_table = table
	position = curve.sample_baked(0.0)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = EnemySprites.frames_for(data)
	add_child(_sprite)
	_sprite.play("walk")


## Advanced by the level every frame, so tests can step the simulation by hand.
func step(delta: float) -> void:
	if finished:
		return
	_hit_cooldown -= delta
	_slow_cooldown -= delta
	for tick in status.advance(delta):
		take_damage(float(tick["damage"]), String(tick["type"]))
		if finished:
			return
	progress += data.speed * status.speed_multiplier() * delta
	_sprite.speed_scale = maxf(0.3, status.speed_multiplier())
	position = _curve.sample_baked(minf(progress, _length))
	if progress >= _length:
		_exit()


## Applies an attack. Returns the damage that was actually dealt.
func take_damage(amount: float, damage_type: String) -> int:
	if finished:
		return 0
	var dealt := DamageCalculator.resolve(amount, damage_type, data, _table, status.mark_bonus())
	health -= dealt
	queue_redraw()
	if health <= 0.0:
		_die()
	else:
		if DamageCalculator.factor_for(damage_type, data, _table) <= 0.0:
			GameAudio.play_sfx(GameAudio.config.blocked_sound)
		elif dealt > 0:
			GameAudio.play_sfx(data.sound_hit)
		if _hit_cooldown <= 0.0 and not _one_shot_playing:
			_hit_cooldown = HIT_COOLDOWN
			_play_once(_hit_animation(damage_type, dealt))
	return dealt


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


func _die() -> void:
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
	_sprite.play(anim)
	_on_done = func() -> void:
		if free_after:
			queue_free()
		else:
			_one_shot_playing = false
			_sprite.play("walk")
	_sprite.animation_finished.connect(_on_done, CONNECT_ONE_SHOT)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if finished or health >= data.health:
		return
	var origin := Vector2(-BAR_SIZE.x / 2.0, -22.0)
	draw_rect(Rect2(origin - Vector2(1, 1), BAR_SIZE + Vector2(2, 2)), Color("2b1b3a"))
	var fraction := clampf(health / data.health, 0.0, 1.0)
	var color := Color("6ad4a0") if fraction > 0.5 else Color("f4d35e") if fraction > 0.25 else Color("e84a5f")
	draw_rect(Rect2(origin, Vector2(BAR_SIZE.x * fraction, BAR_SIZE.y)), color)
