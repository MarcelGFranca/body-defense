## Runs the level clock and starts waves at their scheduled times.
class_name WaveScheduler
extends RefCounted

signal wave_started(index: int)
signal enemy_spawned(enemy_id: String)

enum State { WAITING, SPAWNING, DONE }

var clock := 0.0
## Index of the wave that released the enemy being spawned right now (readable in `enemy_spawned` handlers).
var spawning_wave := -1
## Multiplies start times and spawn intervals (the difficulty).
var time_scale := 1.0

var _waves: Array[WaveData]
var _states: Array[int] = []
var _queues: Array = []
var _timers: Array[float] = []


func _init(wave_list: Array[WaveData], wave_time_scale: float = 1.0) -> void:
	_waves = wave_list
	time_scale = wave_time_scale
	for wave in _waves:
		_states.append(State.WAITING)
		_timers.append(0.0)
		var queue: Array = []
		for entry in wave.entries:
			for i in int(entry["count"]):
				queue.append(String(entry["enemy"]))
		_queues.append(queue)


func tick(delta: float) -> void:
	clock += delta
	for i in _waves.size():
		if _states[i] == State.WAITING and clock >= _waves[i].start_time * time_scale:
			_start(i)
	for i in _waves.size():
		if _states[i] == State.SPAWNING:
			_spawn_step(i, delta)


## Starts the next wave that has not started yet. Other waves keep their start times.
func call_next_wave() -> bool:
	for i in _waves.size():
		if _states[i] == State.WAITING:
			_start(i)
			return true
	return false


func wave_count() -> int:
	return _waves.size()


func started_count() -> int:
	var count := 0
	for state in _states:
		if state != State.WAITING:
			count += 1
	return count


func all_started() -> bool:
	return started_count() == _waves.size()


## True once every wave has started and released all of its enemies.
func spawning_done() -> bool:
	for state in _states:
		if state != State.DONE:
			return false
	return true


## Index of the next wave that has not started, or -1.
func next_wave_index() -> int:
	for i in _waves.size():
		if _states[i] == State.WAITING:
			return i
	return -1


## Level seconds until the next scheduled wave, or -1 when every wave has started.
func time_to_next_wave() -> float:
	var i := next_wave_index()
	if i == -1:
		return -1.0
	return maxf(0.0, _waves[i].start_time * time_scale - clock)


func enemy_ids_of(index: int) -> Array:
	var ids: Array = []
	for entry in _waves[index].entries:
		if not ids.has(entry["enemy"]):
			ids.append(entry["enemy"])
	return ids


func _start(index: int) -> void:
	_states[index] = State.SPAWNING
	_timers[index] = 0.0
	wave_started.emit(index)


func _spawn_step(index: int, delta: float) -> void:
	var queue: Array = _queues[index]
	while not queue.is_empty() and _timers[index] <= 0.0:
		spawning_wave = index
		enemy_spawned.emit(queue.pop_front())
		_timers[index] += _waves[index].spawn_interval * time_scale
	if queue.is_empty():
		_states[index] = State.DONE
	else:
		_timers[index] -= delta
