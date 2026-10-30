## A neutrophil summoned by a Bone Marrow tower. It keeps moving around its post on the path, goes to meet
## the enemies that come within its guard radius and holds back one enemy. It slowly recovers its health.
class_name BlockerUnit
extends Node2D

signal died(unit: BlockerUnit)

## How far (along the path) an enemy must be from the unit to be stopped by it.
const REACH := 14.0
const HIT_INTERVAL := 1.0
## Damage per second that a blocked enemy deals to the unit, per point of body damage.
const ENEMY_DPS := 4.0
## How far along the path the unit drifts around its post while it waits, and how fast.
const WANDER := 7.0
const WANDER_SPEED := 1.3
## The unit stops this far ahead of the enemy it goes to meet (it must stay within REACH to block it).
const MEET_DISTANCE := 12.0
const SPRITE_SCALE := 0.425

var offset := 0.0
var health := 0.0
var max_health := 0.0
var damage := 0.0
var owner_tower: Tower
## Where the unit waits, along the path, and how far from there it looks for enemies.
var home_offset := 0.0
var guard_radius := 0.0
var speed := 0.0
## Health recovered per second.
var regen := 0.0

var _curve: Curve2D
var _home_point := Vector2.ZERO
var _sprite: AnimatedSprite2D
var _clock := 0.0
var _fight_clock := 0.0
var _phase := 0.0


func setup(curve: Curve2D, path_offset: float, unit_health: float, unit_damage: float, radius: float, move_speed: float, health_regen: float = 0.0) -> void:
	_curve = curve
	z_index = 1
	offset = path_offset
	home_offset = path_offset
	_home_point = curve.sample_baked(path_offset)
	position = _home_point
	health = unit_health
	max_health = unit_health
	damage = unit_damage
	guard_radius = radius
	speed = move_speed
	regen = health_regen
	_phase = fmod(path_offset * 0.37, TAU)
	var frames := TowerSprites.frames_for("neutrophil")
	if frames != null:
		_sprite = AnimatedSprite2D.new()
		_sprite.sprite_frames = frames
		_sprite.scale = Vector2.ONE * SPRITE_SCALE
		add_child(_sprite)
		_sprite.play("idle")


## Name of the animation being played, or an empty string when the unit has no sprite.
func current_animation() -> String:
	return String(_sprite.animation) if _sprite != null else ""


## Plays the attack animation once, facing the enemy, then goes back to idle.
func _play_attack(direction_x: float) -> void:
	if _sprite == null or not _sprite.sprite_frames.has_animation("attack"):
		return
	if direction_x != 0.0:
		_sprite.flip_h = direction_x < 0.0
	_sprite.play("attack")
	if not _sprite.animation_finished.is_connected(_back_to_idle):
		_sprite.animation_finished.connect(_back_to_idle, CONNECT_ONE_SHOT)


func _back_to_idle() -> void:
	if _sprite != null:
		_sprite.play("idle")


func is_alive() -> bool:
	return health > 0.0


func blocks(enemy: Enemy) -> bool:
	return is_alive() and not enemy.finished and absf(enemy.progress - offset) <= REACH and enemy.progress <= offset + REACH


## The enemy the unit goes to meet: the closest one inside its guard radius. Bosses push through, so they are ignored.
func target_among(enemies: Array) -> Enemy:
	var nearest: Enemy = null
	var nearest_distance := guard_radius
	for enemy: Enemy in enemies:
		if enemy.finished or enemy.data.role == "boss":
			continue
		var distance := enemy.position.distance_to(_home_point)
		if distance <= nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


## Advanced by the level every frame: wanders around the post, or walks along the path to meet an enemy.
func step(delta: float, enemies: Array) -> void:
	_clock += delta
	if health < max_health:
		health = minf(max_health, health + regen * delta)
	var target := target_among(enemies)
	var goal := home_offset + sin(_clock * WANDER_SPEED + _phase) * WANDER
	if target != null:
		goal = target.progress + MEET_DISTANCE
	var before := offset
	offset = move_toward(offset, clampf(goal, 0.0, _curve.get_baked_length()), speed * delta)
	position = _curve.sample_baked(offset)
	if _sprite != null and not is_equal_approx(before, offset):
		var heading := _curve.sample_baked(offset + 1.0).x - position.x
		if absf(heading) > 0.01:
			_sprite.flip_h = (heading < 0.0) != (offset < before)
	queue_redraw()


## One step of the fight against a blocked enemy.
func fight(enemy: Enemy, delta: float) -> void:
	_fight_clock += delta
	health -= ENEMY_DPS * enemy.body_damage * delta
	if _fight_clock >= HIT_INTERVAL:
		_fight_clock -= HIT_INTERVAL
		enemy.take_damage(damage, "physical", "bone-marrow")
		_play_attack(enemy.position.x - position.x)
	queue_redraw()
	if health <= 0.0:
		died.emit(self)
		queue_free()


func _draw() -> void:
	if guard_radius > 0.0:
		var center := _home_point - position
		draw_arc(center, guard_radius, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 1.0)
	if health < max_health:
		var fraction := clampf(health / max_health, 0.0, 1.0)
		draw_rect(Rect2(-5, -9, 10, 2), Color("2b1b3a"))
		draw_rect(Rect2(-5, -9, 10.0 * fraction, 2), Color("6ad4a0"))
