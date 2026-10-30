## Draws the level background, the path, the entrance, the exit and the empty slots.
class_name MapView
extends Node2D

const BACKGROUND := Color("3a1f2b")
const TISSUE := Color("4d2a3a")
const PATH_EDGE := Color("7a1d2e")
const PATH_FILL := Color("c4364f")
const PATH_DASH := Color("e8667d")
const SLOT_FILL := Color("2a1722")
const SLOT_EDGE := Color("ffb3c7")

var _level: Level


func setup(level: Level) -> void:
	_level = level
	queue_redraw()


func _draw() -> void:
	if _level == null or _level.data == null:
		return
	var map_size := _level.data.map_size
	draw_rect(Rect2(Vector2(-40, -80), map_size + Vector2(80, 160)), BACKGROUND)
	var random := RandomNumberGenerator.new()
	random.seed = 7
	for i in int(map_size.y / 45.0):
		draw_circle(Vector2(random.randf_range(0.0, map_size.x), random.randf_range(0.0, map_size.y)),
			random.randf_range(18.0, 34.0), TISSUE)
	var points := _level.data.path_points
	draw_polyline(points, PATH_EDGE, 40.0)
	draw_polyline(points, PATH_FILL, 30.0)
	_draw_dashes(points)
	var entrance := points[0]
	var exit_point := points[points.size() - 1]
	draw_colored_polygon(PackedVector2Array([entrance + Vector2(-14, 4), entrance + Vector2(14, 4), entrance + Vector2(0, 20)]), Color("f4d35e"))
	draw_colored_polygon(PackedVector2Array([exit_point + Vector2(-16, -26), exit_point + Vector2(16, -26), exit_point + Vector2(0, -8)]), Color("6ad4a0"))
	for i in _level.data.slots.size():
		if _level.towers.has(i):
			continue
		var center := _level.data.slots[i]
		draw_circle(center, 17.0, SLOT_FILL)
		draw_arc(center, 17.0, 0.0, TAU, 24, SLOT_EDGE, 2.0)


func _draw_dashes(points: PackedVector2Array) -> void:
	for i in points.size() - 1:
		var from := points[i]
		var to := points[i + 1]
		var length := from.distance_to(to)
		var direction := (to - from) / length
		var at := 0.0
		while at < length:
			draw_line(from + direction * at, from + direction * minf(at + 6.0, length), PATH_DASH, 2.0)
			at += 16.0
