## Filled circles and arcs that the renderer can send to the GPU in one batch.
## `draw_circle` costs one draw call each, however many are drawn in a row, while textured rectangles of the same texture
## are merged into one call. A disc is a rectangle of a white disc texture tinted by the colour. Rings are not done this way:
## measured on a GPU, drawing a ring as many separate line segments costs more CPU than the single `draw_arc` call it replaces.
class_name CanvasShapes
extends RefCounted

## A white disc with a one pixel soft edge (`tools/generate_disc.py`). Sampled by point like the rest of the pixel art, so
## a disc has the hard edge a `draw_circle` has.
const DISC: Texture2D = preload("res://assets/ui/disc.png")


## A filled circle.
static func disc(item: CanvasItem, center: Vector2, radius: float, color: Color) -> void:
	item.draw_texture_rect(DISC, Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, color)


## The straight pieces of an arc as pairs of points for `draw_multiline`. Several arcs of one colour and width are
## joined with `append_array` and drawn with one call.
static func arc_segments(center: Vector2, radius: float, from: float, to: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var previous := center + Vector2.from_angle(from) * radius
	for i in range(1, segments + 1):
		var next := center + Vector2.from_angle(lerpf(from, to, float(i) / segments)) * radius
		points.append(previous)
		points.append(next)
		previous = next
	return points
