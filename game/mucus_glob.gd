## A glob of mucus thrown by a Mucus Cell. It flies to the enemy and leaves a puddle where it lands.
class_name MucusGlob
extends Node2D

signal landed(world_position: Vector2)

const FLIGHT_SECONDS := 0.35
const ARC_HEIGHT := 18.0

var _from: Vector2
var _target: Enemy
var _last_known: Vector2
var _elapsed := 0.0


func setup(from: Vector2, target: Enemy) -> void:
	_from = from
	_target = target
	_last_known = target.position
	position = from


## Advanced by the level every frame, so tests can step the simulation by hand.
func step(delta: float) -> void:
	_elapsed += delta
	if is_instance_valid(_target) and not _target.finished:
		_last_known = _target.position
	var t := clampf(_elapsed / FLIGHT_SECONDS, 0.0, 1.0)
	position = _from.lerp(_last_known, t) + Vector2(0.0, -sin(PI * t) * ARC_HEIGHT)
	queue_redraw()
	if t >= 1.0:
		landed.emit(_last_known)
		queue_free()


func _draw() -> void:
	CanvasShapes.disc(self, Vector2.ZERO, 5.0, Color("a89430"))
	CanvasShapes.disc(self, Vector2.ZERO, 4.0, Color("d6c448"))
	CanvasShapes.disc(self, Vector2(-1.5, -1.5), 1.5, Color("f5eb8c"))
