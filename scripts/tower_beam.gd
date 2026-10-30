## The thick beam of a tower and the explosion where it lands. Drawn above the enemies.
class_name TowerBeam
extends Node2D

const BEAM_SECONDS := 0.28
const EXPLOSION_SECONDS := 0.5
const SPARKS := 10
const OUTER := Color("5fd8ff")
const CORE := Color("ffffff")
const FLASH := Color("fff2a8")

var _width := 0.0
var _target := Vector2.ZERO
var _age := -1.0


func setup(beam_width: float) -> void:
	_width = beam_width
	z_index = 2


## Fires at `target`, given relative to the tower.
func fire(target: Vector2) -> void:
	_target = target
	_age = 0.0
	queue_redraw()


func is_active() -> bool:
	return _age >= 0.0


func _process(delta: float) -> void:
	if _age < 0.0:
		return
	_age += delta
	if _age >= EXPLOSION_SECONDS:
		_age = -1.0
	queue_redraw()


func _draw() -> void:
	if _age < 0.0:
		return
	if _age < BEAM_SECONDS:
		var fraction := _age / BEAM_SECONDS
		var width := _width * (1.0 - 0.7 * fraction)
		draw_line(Vector2.ZERO, _target, Color(OUTER, 0.55 * (1.0 - fraction * 0.6)), width * 1.5)
		draw_line(Vector2.ZERO, _target, Color(OUTER, 0.9), width)
		draw_line(Vector2.ZERO, _target, CORE, width * 0.45)
	var burst := _age / EXPLOSION_SECONDS
	var radius := _width * (0.4 + 1.8 * burst)
	draw_circle(_target, radius, Color(FLASH, 0.85 * (1.0 - burst)))
	draw_circle(_target, radius * 0.55, Color(CORE, 1.0 - burst))
	draw_arc(_target, radius * 1.3, 0.0, TAU, 32, Color(OUTER, 1.0 - burst), 3.0)
	for i in SPARKS:
		var angle := TAU * i / SPARKS + 0.3
		var from := _target + Vector2(cos(angle), sin(angle)) * radius * 0.9
		var to := _target + Vector2(cos(angle), sin(angle)) * radius * (1.5 + 0.8 * burst)
		draw_line(from, to, Color(CORE, 1.0 - burst), 2.0)
