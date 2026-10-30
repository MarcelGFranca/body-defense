## Draws the level background, the path, the entrance, the exit and the empty slots.
## The tissue breathes and the blood flows a little, and the more enemies got through, the redder it gets, with pus.
class_name MapView
extends Node2D

const SLOT_FILL := Color("2a1722")
const SLOT_EDGE := Color("ffb3c7")

## The drawing is refreshed this many times per second: enough for slow motion, cheap on a phone.
const REDRAW_RATE := 12.0
const PUS_SPOTS := 14
## The tissue goes on this far past the edges of the map, so zooming out never shows an empty border.
const MARGIN := Vector2(320.0, 240.0)
const PUS_COLOR := Color(0.85, 0.85, 0.35)
const INFECTION_TINT := Color(0.75, 0.08, 0.1)

var _level: Level
var _time := 0.0
var _since_redraw := 0.0
## Tissue shapes: {"at": Vector2, "radius": float, "phase": float, "width": float}.
var _decor: Array[Dictionary] = []
var _pus: Array[Dictionary] = []


func setup(level: Level) -> void:
	_level = level
	_build_decor()
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	_since_redraw += delta
	if _since_redraw >= 1.0 / REDRAW_RATE:
		_since_redraw = 0.0
		queue_redraw()


## 0 while the body is untouched, 1 when it is about to fall.
func infection() -> float:
	if _level == null or _level.max_body_health <= 0:
		return 0.0
	return 1.0 - float(_level.body_health) / float(_level.max_body_health)


func _draw() -> void:
	if _level == null or _level.data == null:
		return
	var map_size := _level.data.map_size
	var level_data := _level.data
	draw_rect(Rect2(-MARGIN, map_size + MARGIN * 2.0), level_data.background_color)
	_draw_decor()
	_draw_infection(map_size)
	var points := _level.data.path_points
	var beat := sin(_time * 2.2)
	draw_polyline(points, level_data.path_edge_color, 40.0 + beat)
	draw_polyline(points, level_data.path_fill_color, 30.0 + beat)
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
func _build_decor() -> void:
	var map_size := _level.data.map_size
	var random := RandomNumberGenerator.new()
	random.seed = 6 + _level.data.number
	match _level.data.decor:
		"rings":
			for i in int(map_size.y / 30.0):
				var at := Vector2(random.randf_range(0.0, map_size.x), random.randf_range(0.0, map_size.y))
				_decor.append({"at": at, "radius": random.randf_range(14.0, 26.0), "phase": random.randf() * TAU, "width": 5.0})
		"stripes":
			var y := 0.0
			while y < map_size.y:
				var tilt := random.randf_range(-6.0, 6.0)
				_decor.append({"at": Vector2(0.0, y), "radius": tilt, "phase": random.randf() * TAU, "width": random.randf_range(5.0, 10.0)})
				y += random.randf_range(22.0, 36.0)
		_:
			for i in int(map_size.y / 45.0):
				var at := Vector2(random.randf_range(0.0, map_size.x), random.randf_range(0.0, map_size.y))
				_decor.append({"at": at, "radius": random.randf_range(18.0, 34.0), "phase": random.randf() * TAU, "width": 0.0})
	_build_margin_decor(map_size)
	var pus_random := RandomNumberGenerator.new()
	pus_random.seed = 77 + _level.data.number
	for i in PUS_SPOTS:
		_pus.append({"at": Vector2(pus_random.randf_range(10.0, map_size.x - 10.0), pus_random.randf_range(20.0, map_size.y - 20.0)),
			"radius": pus_random.randf_range(7.0, 14.0), "phase": pus_random.randf()})


## More tissue of the same kind around the map, from its own seed so the map itself keeps its look.
func _build_margin_decor(map_size: Vector2) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 1000 + _level.data.number
	var area := Rect2(-MARGIN, map_size + MARGIN * 2.0)
	match _level.data.decor:
		"stripes":
			var y := area.position.y
			while y < area.end.y:
				if y < 0.0 or y > map_size.y:
					_decor.append({"at": Vector2(0.0, y), "radius": random.randf_range(-6.0, 6.0), "phase": random.randf() * TAU, "width": random.randf_range(5.0, 10.0)})
				y += random.randf_range(22.0, 36.0)
		_:
			var count := int(area.get_area() / (map_size.x * 30.0) * 0.5) if _level.data.decor == "rings" else int(area.get_area() / (map_size.x * 45.0) * 0.5)
			for i in count:
				var at := Vector2(random.randf_range(area.position.x, area.end.x), random.randf_range(area.position.y, area.end.y))
				if Rect2(Vector2.ZERO, map_size).has_point(at):
					continue
				var radius := random.randf_range(14.0, 26.0) if _level.data.decor == "rings" else random.randf_range(18.0, 34.0)
				_decor.append({"at": at, "radius": radius, "phase": random.randf() * TAU, "width": 5.0 if _level.data.decor == "rings" else 0.0})


## Draws the tissue. Every shape drifts a few pixels and swells a little, each on its own rhythm.
func _draw_decor() -> void:
	var tissue := _level.data.tissue_color
	var map_width := _level.data.map_size.x
	for item in _decor:
		var phase: float = item["phase"]
		var sway := Vector2(cos(_time * 0.5 + phase), sin(_time * 0.4 + phase * 1.3)) * 3.0
		var swell := 1.0 + 0.07 * sin(_time * 0.9 + phase)
		match _level.data.decor:
			"rings":
				draw_arc(item["at"] + sway, float(item["radius"]) * swell, 0.0, TAU, 20, tissue, item["width"])
			"stripes":
				var from: Vector2 = item["at"] + Vector2(0.0, sway.y)
				draw_line(from + Vector2(-MARGIN.x, 0.0), from + Vector2(map_width + MARGIN.x, float(item["radius"]) + sway.x), tissue, item["width"])
			_:
				draw_circle(item["at"] + sway, float(item["radius"]) * swell, tissue)


## Red tint over the tissue, and pus oozing from spots, more of both as enemies get through.
func _draw_infection(map_size: Vector2) -> void:
	var level_of_infection := infection()
	if level_of_infection <= 0.0:
		return
	draw_rect(Rect2(-MARGIN, map_size + MARGIN * 2.0), Color(INFECTION_TINT, 0.32 * level_of_infection))
	var visible_spots := ceili(level_of_infection * PUS_SPOTS)
	for i in visible_spots:
		var spot: Dictionary = _pus[i]
		var at: Vector2 = spot["at"]
		var radius: float = spot["radius"] * (0.85 + 0.15 * sin(_time * 1.3 + float(spot["phase"]) * TAU))
		var drip := fposmod(_time * 0.12 + float(spot["phase"]), 1.0)
		draw_line(at, at + Vector2(0.0, radius * (1.0 + 4.0 * drip)), Color(PUS_COLOR, 0.45 * (1.0 - drip)), 4.0)
		draw_circle(at, radius, Color(PUS_COLOR, 0.5))
		draw_circle(at + Vector2(-radius * 0.25, -radius * 0.25), radius * 0.4, Color(1, 1, 0.8, 0.45))


func _draw_dashes(points: PackedVector2Array) -> void:
	for i in points.size() - 1:
		var from := points[i]
		var to := points[i + 1]
		var length := from.distance_to(to)
		var direction := (to - from) / length
		var at := fposmod(_time * 10.0, 16.0) - 16.0
		while at < length:
			draw_line(from + direction * maxf(at, 0.0), from + direction * minf(at + 6.0, length), _level.data.path_dash_color, 2.0)
			at += 16.0
