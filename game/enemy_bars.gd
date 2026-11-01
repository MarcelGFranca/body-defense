## Draws the health bars of every hurt enemy in one canvas item, above all the sprites.
## Rectangles of the same kind are sent to the GPU as one batch, but only when nothing else is drawn in
## between: a bar drawn by each enemy sat between two sprites and cut the batch in pieces.
class_name EnemyBars
extends Node2D

const BAR_SIZE := Vector2(20, 3)
const BAR_OFFSET := Vector2(-BAR_SIZE.x / 2.0, -22.0)
const BACK := Color("2b1b3a")
const GOOD := Color("6ad4a0")
const MEDIUM := Color("f4d35e")
const LOW := Color("e84a5f")

var _level: Level


func setup(level: Level) -> void:
	_level = level
	z_index = 1


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for enemy in _level.enemies:
		if enemy.finished or enemy.health >= enemy.max_health:
			continue
		var origin := enemy.position + BAR_OFFSET
		var fraction := clampf(enemy.health / enemy.max_health, 0.0, 1.0)
		draw_rect(Rect2(origin - Vector2.ONE, BAR_SIZE + Vector2(2, 2)), BACK)
		draw_rect(Rect2(origin, Vector2(BAR_SIZE.x * fraction, BAR_SIZE.y)), GOOD if fraction > 0.5 else MEDIUM if fraction > 0.25 else LOW)
