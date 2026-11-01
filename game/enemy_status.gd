## Slows, roots, damage over time and marks that affect one enemy.
class_name EnemyStatus
extends RefCounted

const SLOW_LINGER := 1.5
const MARK_FADE_SECONDS := 0.6
const BOSS_ROLE := "boss"
const SLOW_IMMUNE_ROLE := "slow-immune"

## Returned by `advance` when no damage-over-time tick is due, so a calm frame allocates nothing.
const NO_TICKS: Array = []

var time := 0.0

var _data: EnemyData
## Slows by source. Two flat dictionaries instead of one dictionary of dictionaries: a tower renews its slow on
## every enemy every frame, and this way renewing allocates nothing.
var _slow_percents: Dictionary = {}  # source -> percent
var _slow_untils: Dictionary = {}  # source -> time when the slow ends
var _root_until := 0.0
var _root_ready_at: Dictionary = {}  # source -> time when it may root again
var _dot_active := false
var _dot_damage := 0.0
var _dot_type := "thermal"
var _dot_source := ""
var _dot_until := 0.0
var _dot_next_tick := 0.0
var _mark_bonus := 0.0
var _mark_until := 0.0
var _mark_color := Color.WHITE


func _init(enemy_data: EnemyData) -> void:
	_data = enemy_data


## Moves the clock forward and returns the damage-over-time ticks that are due.
func advance(delta: float) -> Array:
	time += delta
	if not _dot_active:
		return NO_TICKS
	var ticks: Array = []
	while _dot_active and time >= _dot_next_tick and _dot_next_tick <= _dot_until + 0.000001:
		ticks.append({"damage": _dot_damage, "type": _dot_type, "source": _dot_source})
		_dot_next_tick += 1.0
	if _dot_active and time >= _dot_until:
		_dot_active = false
	return ticks


## Slows do not stack: the strongest one counts. Bosses get half, slow-immune enemies none.
func apply_slow(source: String, percent: float) -> bool:
	if _data.role == SLOW_IMMUNE_ROLE:
		return false
	if _data.role == BOSS_ROLE:
		percent *= 0.5
	var was_slowed := is_slowed()
	_slow_percents[source] = percent
	_slow_untils[source] = time + SLOW_LINGER
	return not was_slowed


func slow_percent() -> float:
	var best := 0.0
	for source in _slow_percents:
		if time < float(_slow_untils[source]):
			best = maxf(best, float(_slow_percents[source]))
	return best


func is_slowed() -> bool:
	return slow_percent() > 0.0


## Returns whether the root was applied. Bosses are rooted for half the time.
func apply_root(source: String, seconds: float, cooldown: float) -> bool:
	if _data.role == SLOW_IMMUNE_ROLE or is_rooted():
		return false
	if time < float(_root_ready_at.get(source, -1.0)):
		return false
	if _data.role == BOSS_ROLE:
		seconds *= 0.5
	_root_until = time + seconds
	_root_ready_at[source] = _root_until + cooldown
	return true


func root_remaining() -> float:
	return maxf(0.0, _root_until - time)


func is_rooted() -> bool:
	return time < _root_until


func speed_multiplier() -> float:
	if is_rooted():
		return 0.0
	return 1.0 - slow_percent() / 100.0


## Damage over time does not stack: a new application only refreshes the duration.
func apply_dot(damage_per_tick: float, damage_type: String, seconds: float, source: String = "") -> void:
	if not _dot_active:
		_dot_active = true
		_dot_next_tick = time + 1.0
	_dot_damage = damage_per_tick
	_dot_type = damage_type
	_dot_source = source
	_dot_until = time + seconds


func has_dot() -> bool:
	return _dot_active


## Marks do not stack: a new mark only refreshes the duration.
func apply_mark(bonus: float, seconds: float, color: Color = Color.WHITE) -> void:
	_mark_bonus = bonus
	_mark_color = color
	_mark_until = time + seconds


## How strongly the enemy is dyed by the mark, from 0 to 1: full while the mark lasts, easing out at the end.
func mark_amount() -> float:
	return clampf((_mark_until - time) / MARK_FADE_SECONDS, 0.0, 1.0)


func mark_color() -> Color:
	return _mark_color


func mark_bonus() -> float:
	return _mark_bonus if time < _mark_until else 0.0
