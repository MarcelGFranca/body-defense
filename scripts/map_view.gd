## Draws the level background, the path, the entrance, the exit and the empty slots.
class_name MapView
extends Node2D

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
	var level_data := _level.data
	draw_rect(Rect2(Vector2(-40, -80), map_size + Vector2(80, 160)), level_data.background_color)
	_draw_decor(map_size)
	var points := _level.data.path_points
	draw_polyline(points, level_data.path_edge_color, 40.0)
	draw_polyline(points, level_data.path_fill_color, 30.0)
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


## Tissue behind the path. The seed is fixed so the background looks the same every time.
func _draw_decor(map_size: Vector2) -> void:
	var tissue := _level.data.tissue_color
	var random := RandomNumberGenerator.new()
	random.seed = 6 + _level.data.number
	match _level.data.decor:
		"rings":
			for i in int(map_size.y / 30.0):
				var at := Vector2(random.randf_range(0.0, map_size.x), random.randf_range(0.0, map_size.y))
				var radius := random.randf_range(14.0, 26.0)
				draw_arc(at, radius, 0.0, TAU, 20, tissue, 5.0)
		"stripes":
			var y := 0.0
			while y < map_size.y:
				draw_line(Vector2(0, y), Vector2(map_size.x, y + random.randf_range(-6.0, 6.0)), tissue, random.randf_range(5.0, 10.0))
				y += random.randf_range(22.0, 36.0)
		_:
			for i in int(map_size.y / 45.0):
				draw_circle(Vector2(random.randf_range(0.0, map_size.x), random.randf_range(0.0, map_size.y)),
					random.randf_range(18.0, 34.0), tissue)


func _draw_dashes(points: PackedVector2Array) -> void:
	for i in points.size() - 1:
		var from := points[i]
		var to := points[i + 1]
		var length := from.distance_to(to)
		var direction := (to - from) / length
		var at := 0.0
		while at < length:
			draw_line(from + direction * at, from + direction * minf(at + 6.0, length), _level.data.path_dash_color, 2.0)
			at += 16.0
