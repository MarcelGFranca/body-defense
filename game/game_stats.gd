## What happened during one game, for the playtest reports: damage and kills by tower, leaks and
## kills by enemy, how every wave went. Cheap enough to keep on all the time.
class_name GameStats
extends RefCounted

var damage_by_source: Dictionary = {}  # tower id -> damage that took health away
var kills_by_source: Dictionary = {}  # tower id -> enemies it finished off
var kills: Dictionary = {}  # enemy id -> count
var leaks: Dictionary = {}  # enemy id -> count that got out
var towers_built: Dictionary = {}  # tower id -> count
var amino_spent := 0
var first_leak_time := -1.0
var waves: Dictionary = {}  # wave index -> {"kills", "leaks", "first_spawn", "last_end"}


func record_damage(source: String, amount: float) -> void:
	if amount <= 0.0:
		return
	damage_by_source[source] = float(damage_by_source.get(source, 0.0)) + amount


func record_kill(enemy_id: String, source: String, wave: int, time: float) -> void:
	kills[enemy_id] = int(kills.get(enemy_id, 0)) + 1
	kills_by_source[source] = int(kills_by_source.get(source, 0)) + 1
	var entry := _wave(wave)
	entry["kills"] += 1
	entry["last_end"] = time


func record_leak(enemy_id: String, wave: int, time: float) -> void:
	leaks[enemy_id] = int(leaks.get(enemy_id, 0)) + 1
	if first_leak_time < 0.0:
		first_leak_time = time
	var entry := _wave(wave)
	entry["leaks"] += 1
	entry["last_end"] = time


func record_spawn(wave: int, time: float) -> void:
	var entry := _wave(wave)
	if entry["first_spawn"] < 0.0:
		entry["first_spawn"] = time


func record_build(tower_id: String, cost: int) -> void:
	towers_built[tower_id] = int(towers_built.get(tower_id, 0)) + 1
	amino_spent += cost


func _wave(index: int) -> Dictionary:
	if not waves.has(index):
		waves[index] = {"kills": 0, "leaks": 0, "first_spawn": -1.0, "last_end": -1.0}
	return waves[index]
