## A neutrophil summoned by a Bone Marrow tower. It stands on the path and holds back one enemy.
class_name BlockerUnit
extends Node2D

signal died(unit: BlockerUnit)

## How far (along the path) an enemy must be from the unit to be stopped by it.
const REACH := 14.0
const HIT_INTERVAL := 1.0
## Damage per second that a blocked enemy deals to the unit, per point of body damage.
const ENEMY_DPS := 4.0

var offset := 0.0
var health := 0.0
var max_health := 0.0
var damage := 0.0
var owner_tower: Tower
var _clock := 0.0
var _taken := 0.0


func setup(path_offset: float, point: Vector2, unit_health: float, unit_damage: float) -> void:
	offset = path_offset
	position = point
	health = unit_health
	max_health = unit_health
	damage = unit_damage


func is_alive() -> bool:
	return health > 0.0


func blocks(enemy: Enemy) -> bool:
	return is_alive() and not enemy.finished and absf(enemy.progress - offset) <= REACH and enemy.progress <= offset + REACH


## One step of the fight against a blocked enemy.
func fight(enemy: Enemy, delta: float) -> void:
	_clock += delta
	health -= ENEMY_DPS * enemy.body_damage * delta
	if _clock >= HIT_INTERVAL:
		_clock -= HIT_INTERVAL
		enemy.take_damage(damage, "physical")
	queue_redraw()
	if health <= 0.0:
		died.emit(self)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2(0, 2), 7.0, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, 6.0, Color("e6eaf2"))
	draw_arc(Vector2.ZERO, 6.0, 0.0, TAU, 16, Color("2b1b3a"), 1.5)
	draw_circle(Vector2(-2, -1), 1.0, Color("2b1b3a"))
	draw_circle(Vector2(2, -1), 1.0, Color("2b1b3a"))
	if health < max_health:
		var fraction := clampf(health / max_health, 0.0, 1.0)
		draw_rect(Rect2(-7, -13, 14, 2), Color("2b1b3a"))
		draw_rect(Rect2(-7, -13, 14.0 * fraction, 2), Color("6ad4a0"))
