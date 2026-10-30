## A touch-friendly volume control: tap or drag along the bar to set a value from 0 to 1 in steps of 0.1.
class_name VolumeBar
extends Control

signal value_changed(value: float)

const STEPS := 10
const COLOR_EMPTY := Color("3a2552")
const COLOR_FILL := Color("ffb3c7")
const COLOR_BORDER := Color("ffb3c7")

var value := 1.0:
	set(new_value):
		value = clampf(roundf(new_value * STEPS) / STEPS, 0.0, 1.0)
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var touched := false
	if event is InputEventMouseButton:
		touched = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventMouseMotion:
		touched = (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if touched:
		set_from_x(event.position.x)
		accept_event()


func set_from_x(x: float) -> void:
	var before := value
	value = x / size.x
	if value != before:
		value_changed.emit(value)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_EMPTY)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * value, size.y)), COLOR_FILL)
	for i in range(1, STEPS):
		var x := size.x * i / STEPS
		draw_line(Vector2(x, 0), Vector2(x, size.y), COLOR_EMPTY, 2.0)
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BORDER, false, 4.0)
