## Stylised flames, drawn in code: a flickering group over a burning enemy and single tongues for the fever wave.
class_name BurnFlames
extends Node2D

const OUTER := Color("ff5a1f")
const INNER := Color("ffd23f")
const TONGUES := 3

var _time := randf() * 10.0


func _ready() -> void:
	z_index = 1
	set_process(visible)


## Starts or stops the fire. Nothing is drawn or updated while it is out.
func set_burning(on: bool) -> void:
	if visible == on:
		return
	visible = on
	set_process(on)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for i in TONGUES:
		var phase := _time * 9.0 + i * 2.1
		var height := 15.0 + 5.0 * sin(phase)
		var at := Vector2((i - 1) * 7.0, 8.0 - absf(i - 1) * 3.0)
		draw_flame(self, at, height, 9.0, 3.0 * sin(phase * 0.7))


## Draws one flame tongue: a red teardrop with a yellow core. `base` is its foot, `sway` bends the tip sideways.
static func draw_flame(canvas: CanvasItem, base: Vector2, height: float, width: float, sway: float, alpha := 1.0) -> void:
	canvas.draw_colored_polygon(_tongue(base, height, width, sway), Color(OUTER, alpha))
	canvas.draw_colored_polygon(_tongue(base, height * 0.6, width * 0.5, sway * 0.6), Color(INNER, alpha))


static func _tongue(base: Vector2, height: float, width: float, sway: float) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for step in 7:
		var t := step / 6.0
		var half := width * 0.5 * sin(PI * pow(t, 0.7)) * (1.0 - 0.15 * t)
		var centre := base + Vector2(sway * t * t, -height * t)
		left.append(centre + Vector2(-half, 0.0))
		right.append(centre + Vector2(half, 0.0))
	right.reverse()
	left.append_array(right)
	return left
