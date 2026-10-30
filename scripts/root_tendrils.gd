## One tendril per enemy: a platelet holds each rooted enemy with its own tendril, until the enemy is free again.
class_name RootTendrils
extends Node2D

const GROW_SECONDS := 0.25
const FADE_SECONDS := 0.25
const SEGMENTS := 14
const OUTLINE := Color("7a3b24")
const FILL := Color("ffb36b")

var _tower: Tower
var _clock := 0.0


func setup(tower: Tower) -> void:
	_tower = tower
	z_index = 2


func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()


func _draw() -> void:
	var holds := _tower.holds()
	for i in holds.size():
		var hold := holds[i]
		var enemy: Enemy = hold["enemy"]
		var grown := clampf(float(hold["age"]) / GROW_SECONDS, 0.0, 1.0)
		var fade := clampf(enemy.status.root_remaining() / FADE_SECONDS, 0.0, 1.0)
		_draw_enemy_tendrils(enemy.position - _tower.position, grown, fade, i)


func _draw_enemy_tendrils(target: Vector2, grown: float, fade: float, index: int) -> void:
	var direction := target.normalized()
	var side := direction.rotated(PI / 2.0)
	var start := direction * 7.0
	var end := target - direction * 3.0
	var points := PackedVector2Array()
	for step in SEGMENTS + 1:
		var t := float(step) / SEGMENTS * grown
		var wobble := sin(t * TAU * 1.5 + _clock * 7.0 + index * 2.1) * 4.0 * sin(t * PI)
		points.append(start.lerp(end, t) + side * wobble)
	draw_polyline(points, Color(OUTLINE, fade), 5.5)
	draw_polyline(points, Color(FILL, fade), 2.5)
	if grown >= 1.0:
		var around := (-direction).angle()
		draw_arc(target, 8.0, around - 1.4, around + 1.4, 12, Color(OUTLINE, fade), 5.5)
		draw_arc(target, 8.0, around - 1.4, around + 1.4, 12, Color(FILL, fade), 2.5)
