## Mucus lying on the ground. It slows the enemies standing on it, then disappears.
class_name MucusPuddle
extends Node2D

signal expired(puddle: MucusPuddle)

const FADE_SECONDS := 1.2
const GOO := Color("d6c448")
const GOO_LIGHT := Color("f5eb8c")
const GOO_DARK := Color("a89430")

var radius := 24.0
var slow_percent := 40.0
var lifetime := 6.0

var _level: Level
var _age := 0.0
var _seed := 0.0
var _source_key := ""


func setup(level: Level, puddle_radius: float, percent: float, seconds: float) -> void:
	_level = level
	_source_key = str(get_instance_id())
	radius = puddle_radius
	slow_percent = percent
	lifetime = seconds
	_seed = randf() * 10.0


## Advanced by the level every frame, so tests can step the simulation by hand.
func step(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		expired.emit(self)
		queue_free()
		return
	for enemy: Enemy in _level.enemies_in_range(position, radius):
		if enemy.status.apply_slow(_source_key, slow_percent):
			enemy.notify_slowed()
	queue_redraw()


func remaining() -> float:
	return maxf(0.0, lifetime - _age)


func _draw() -> void:
	var fade := clampf(remaining() / FADE_SECONDS, 0.0, 1.0)
	var grow := clampf(_age / 0.25, 0.3, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.62))
	CanvasShapes.disc(self, Vector2.ZERO, radius * grow, Color(GOO_DARK, 0.75 * fade))
	CanvasShapes.disc(self, Vector2.ZERO, radius * grow * 0.86, Color(GOO, 0.85 * fade))
	for i in 5:
		var angle := _seed + i * 1.26
		CanvasShapes.disc(self, Vector2(cos(angle), sin(angle)) * radius * 0.45 * grow, 2.5 + (i % 2), Color(GOO_LIGHT, 0.9 * fade))
