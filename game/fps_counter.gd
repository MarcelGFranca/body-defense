## Small frames-per-second readout for debugging. It shows only while the debug mode is on (see `Session.debug_mode`).
class_name FpsCounter
extends Label

const REFRESH_SECONDS := 0.25
const WIDTH := 140.0
## Gap to the right edge of the screen.
const MARGIN := 12.0

var _since := REFRESH_SECONDS


func _init() -> void:
	name = "FpsCounter"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(WIDTH, 20)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_theme_font_size_override("font_size", 14)
	add_theme_color_override("font_color", Color("6ad4a0"))
	add_theme_color_override("font_outline_color", Color("2b1b3a"))
	add_theme_constant_override("outline_size", 4)
	visible = false


## Puts the readout at the top right of a screen that is `screen_width` wide, `top` pixels from the top.
func place_top_right(screen_width: float, top: float) -> void:
	position = Vector2(screen_width - WIDTH - MARGIN, top)


func _process(delta: float) -> void:
	visible = Session.debug_mode
	if not visible:
		return
	_since += delta
	if _since >= REFRESH_SECONDS:
		_since = 0.0
		text = "FPS %d" % Engine.get_frames_per_second()
