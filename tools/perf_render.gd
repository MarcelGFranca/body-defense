## Measures what the renderer does while a crowded level runs with its HUD: draw calls, objects, frame time and memory.
## It needs a window, so run it on a virtual display (xvfb-run); software GL makes the times larger than on a phone,
## but draw calls and object counts are the same, and times are comparable between two runs on the same machine.
## Usage: xvfb-run -a godot --path . --fixed-fps 60 res://tools/perf_render.tscn -- [--level 9] [--frames 900] [--out file.json]
extends Node

var _level: Level
var _hud: Hud


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var number := int(_arg(args, "--level", "9"))
	var frames := int(_arg(args, "--frames", "900"))
	_level = Level.new(Session.load_level(number), load("res://data/difficulties/medium.tres"))
	add_child(_level)
	_level.max_body_health = 1000000000
	_level.body_health = _level.max_body_health
	Economy.add(1000000)
	_hud = Hud.new(_level)
	add_child(_hud)
	var ids: Array = _level.data.tower_ids
	for slot in _level.data.slots.size():
		_level.build_tower(slot, ids[slot % ids.size()])
	GameAudio.set_muted(true)
	# Step the simulation by hand until a crowd is on the field, so every run starts from the same state.
	for i in 6000:
		_level.step(1.0 / 60.0)
		if _level.enemies.size() >= 25:
			break
	await get_tree().process_frame
	# The engine can time the CPU work of rendering each viewport (building and sending the draw commands).
	var viewports: Array[RID] = [get_viewport().get_viewport_rid(), (_level.get("_camera") as Camera2D).get_viewport().get_viewport_rid()]
	for rid in viewports:
		RenderingServer.viewport_set_measure_render_time(rid, true)
	var render_cpu_ms := 0.0
	var render_gpu_ms := 0.0
	var draw_calls := 0.0
	var objects := 0.0
	var wall_usec := 0
	var enemy_sum := 0
	var peak_nodes := 0
	for i in frames:
		var t0 := Time.get_ticks_usec()
		await get_tree().process_frame
		wall_usec += Time.get_ticks_usec() - t0
		for rid in viewports:
			render_cpu_ms += RenderingServer.viewport_get_measured_render_time_cpu(rid)
			render_gpu_ms += RenderingServer.viewport_get_measured_render_time_gpu(rid)
		draw_calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		objects += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		enemy_sum += _level.enemies.size()
		peak_nodes = maxi(peak_nodes, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	var result := {
		"level": number, "frames": frames, "mean_enemies": float(enemy_sum) / frames,
		"draw_calls": draw_calls / frames, "objects": objects / frames, "render_cpu_ms": render_cpu_ms / frames, "render_gpu_ms": render_gpu_ms / frames,
		"wall_ms": float(wall_usec) / frames / 1000.0, "nodes": peak_nodes,
		"static_memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"video_memory_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"texture_memory_mb": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
	}
	# Where the cost comes from: hide the parts one after the other and see what each took away.
	_level.set_process(false)
	var mix := {}
	for enemy in _level.enemies:
		mix[enemy.data.id] = int(mix.get(enemy.data.id, 0)) + 1
		if enemy.status.has_dot():
			mix["(burning)"] = int(mix.get("(burning)", 0)) + 1
	result["enemy_mix"] = mix
	var parts := {}
	var previous := await _count(viewports)
	parts["total"] = previous
	for entry in [["hud", _hud], ["enemies", _level.get("_enemy_layer")], ["towers", _level.get("_tower_layer")],
			["ground", _level.get("_ground_layer")], ["air", _level.get("_air_layer")], ["map", _level.get("_map")]]:
		entry[1].visible = false
		var now := await _count(viewports)
		parts[entry[0]] = {"draws": previous["draws"] - now["draws"], "cpu_ms": previous["cpu_ms"] - now["cpu_ms"], "gpu_ms": previous["gpu_ms"] - now["gpu_ms"]}
		previous = now
	result["by_part"] = parts
	print(JSON.stringify(result, "  "))
	var out := String(_arg(args, "--out", ""))
	if out != "":
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify(result, "\t"))
	get_tree().quit()


func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	var at := args.find(name)
	return args[at + 1] if at >= 0 and at + 1 < args.size() else fallback


func _count(viewports: Array[RID]) -> Dictionary:
	var draws := 0.0
	var cpu := 0.0
	var gpu := 0.0
	for i in 30:
		await get_tree().process_frame
		draws += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		for rid in viewports:
			cpu += RenderingServer.viewport_get_measured_render_time_cpu(rid)
			gpu += RenderingServer.viewport_get_measured_render_time_gpu(rid)
	return {"draws": draws / 30.0, "cpu_ms": cpu / 30.0, "gpu_ms": gpu / 30.0}
