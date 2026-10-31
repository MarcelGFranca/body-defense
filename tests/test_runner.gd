## Runs every automated check. Exits with 1 when something fails.
## Usage: godot --headless --path . --fixed-fps 60 res://tests/test_runner.tscn
extends Node

var _checks := 0
var _done: Array = []
var _failures := 0
var _enemies: Dictionary
var _towers: Dictionary
var _table: DamageTable
var _level_data: LevelData


func _ready() -> void:
	await get_tree().process_frame
	_enemies = DataLoader.load_all("res://data/enemies")
	_towers = DataLoader.load_all("res://data/towers")
	_table = load("res://data/damage_table.tres")
	_level_data = load("res://data/levels/level_1.tres")
	_run()


func _run() -> void:
	Localization.apply("en")
	Session.last_seen_version = Session.current_version()
	test_enemy_roster()
	test_tower_roster()
	test_level_data()
	test_validator_catches_problems()
	test_damage_calculator()
	test_status_effects()
	test_wave_scheduler()
	test_economy()
	test_level_simulation()
	test_scrolling()
	await test_speed_and_pause()
	test_heartbeat()
	await test_revive()
	await test_hud()
	await test_audio()
	test_difficulty()
	test_stats()
	test_campaign_data()
	test_enemy_traits()
	await test_new_towers()
	test_session()
	await test_menu_and_results()
	await test_splash()
	test_localization()
	test_icon_safe_zone()
	await test_changelog_menu()
	test_changelog()
	test_campaign_simulation()
	for section in ["test_enemy_roster", "test_tower_roster", "test_level_data", "test_validator_catches_problems",
			"test_damage_calculator", "test_status_effects", "test_wave_scheduler", "test_economy",
			"test_level_simulation", "test_scrolling", "test_speed_and_pause", "test_hud", "test_audio",
			"test_difficulty", "test_stats", "test_campaign_data", "test_enemy_traits", "test_new_towers", "test_session", "test_menu_and_results",
			"test_splash", "test_localization", "test_changelog", "test_changelog_menu", "test_campaign_simulation"]:
		if not _done.has(section):
			_failures += 1
			printerr("FAIL: %s stopped before its end (a script error?)" % section)
	print("%d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


## Marks that a test section ran to its last line. A script error aborts a section silently otherwise.
func done(section: String) -> void:
	_done.append(section)


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("FAIL: %s" % message)


func approx(a: float, b: float, tolerance: float = 0.01) -> bool:
	return absf(a - b) <= tolerance


func new_level() -> Level:
	var level := Level.new()
	get_tree().root.add_child(level)
	return level


## A prototype level with `tower_id` built on slot 2, even when the prototype does not offer that tower.
func level_with_tower(tower_id: String) -> Level:
	var level := new_level()
	var prototype_towers: Array = level.data.tower_ids.duplicate()
	level.data.tower_ids.append(tower_id)
	level.build_tower(2, tower_id)
	level.data.tower_ids = prototype_towers
	return level


func mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	return event


func mouse_motion(position: Vector2, relative: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = relative
	return event


func mouse_wheel(button: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	return event


func free_node(node: Node) -> void:
	get_tree().root.remove_child(node)
	node.free()


# --- data -------------------------------------------------------------------

func test_enemy_roster() -> void:
	check(_enemies.size() == 13, "13 enemy files load")
	var files := 0
	for file in DirAccess.get_files_at("res://data/enemies"):
		if file.ends_with(".tres"):
			files += 1
	check(files == 13, "13 enemy files exist, ids are unique")
	var viruses := 0
	var bacteria := 0
	var bosses := 0
	for id in _enemies:
		var e: EnemyData = _enemies[id]
		if e.role == "boss":
			bosses += 1
		elif e.type == "virus":
			viruses += 1
		else:
			bacteria += 1
	check(viruses == 5 and bacteria == 5 and bosses == 3, "5 regular viruses, 5 regular bacteria, 3 bosses")
	check(DataValidator.validate_enemies(_enemies).is_empty(), "enemy roster validates")
	for id in ["rhinovirus", "influenza", "streptococcus-pyogenes"]:
		check(EnemySprites.frames_for(_enemies[id]).has_animation("walk"), "%s has a walk animation" % id)
	check(EnemySprites.frames_for(_enemies["hpv"]).has_animation("walk"), "placeholder enemy shows an image")
	done("test_enemy_roster")


func test_tower_roster() -> void:
	check(_towers.size() == 10, "10 tower files load")
	check(DataValidator.validate_towers(_towers).is_empty(), "tower roster validates")
	var proto: Array = []
	for id in _towers:
		if _towers[id].in_prototype:
			proto.append(id)
	proto.sort()
	check(proto == ["interferon", "macrophage", "mucus-cell"], "three prototype towers flagged")
	check(_towers["macrophage"].mobility == "fixed" and _towers["t-lymphocyte"].mobility == "mobile", "macrophage fixed, T lymphocyte mobile")
	check(_towers["b-lymphocyte"].mobility == "mobile", "B lymphocyte mobile")
	check(DataValidator.damage_warnings(_towers, _enemies, _table).is_empty(), "no damage value rounds to 0")
	for id in _towers:
		check(_towers[id].ability_description != "", "%s has an ability description" % id)
	var hud_texts := Hud.new(null)
	check(hud_texts._damage_text(_towers["mucus-cell"]) == "DAMAGE: NONE", "a tower without damage says so")
	check(hud_texts._damage_text(_towers["interferon"]) == "DAMAGE: 5/S (ANTIVIRAL)", "an area tower shows its damage per second")
	check(hud_texts._damage_text(_towers["hypothalamus"]) == "DAMAGE: 3/S (THERMAL)", "a damage over time tower shows its damage per second")
	hud_texts.free()
	done("test_tower_roster")


func test_level_data() -> void:
	check(_level_data.display_name == "Throat", "level 1 is called Throat")
	check(_level_data.slots.size() == 6, "level 1 has 6 slots")
	check(_level_data.starting_amino_acids == 150 and _level_data.body_health == 20, "level 1 starts with 150 amino acids and 20 health")
	check(_level_data.waves.size() == 3, "level 1 has 3 waves")
	check(approx(_level_data.waves[0].start_time, 5.0) and approx(_level_data.waves[1].start_time, 50.0) and approx(_level_data.waves[2].start_time, 150.0), "waves start at 5, 50 and 150 s")
	check(_level_data.tower_ids == ["macrophage", "mucus-cell", "interferon"], "level 1 offers the three prototype towers")
	check(_level_data.map_size.y > Level.VIEW_SIZE.y - Level.SAFE_TOP - Level.SAFE_BOTTOM, "the map is taller than the visible area")
	var longest := 0.0
	for point in _level_data.path_points:
		check(Rect2(Vector2.ZERO, _level_data.map_size).has_point(point), "path point %s is inside the map" % point)
		longest = maxf(longest, point.y)
	check(longest > Level.VIEW_SIZE.y - Level.SAFE_BOTTOM, "the path runs past the bottom of the screen")
	check(DataValidator.validate_level(_level_data, _towers, _enemies).is_empty(), "level data validates")
	var curve := Curve2D.new()
	for point in _level_data.path_points:
		curve.add_point(point)
	for slot in _level_data.slots:
		var distance := curve.get_closest_point(slot).distance_to(slot)
		check(distance > 24.0 + 20.0, "slot %s is outside the path and its tap area" % slot)
	done("test_level_data")


func test_validator_catches_problems() -> void:
	var broken := _enemies.duplicate()
	var copy: EnemyData = _enemies["hpv"].duplicate()
	copy.health = 0.0
	broken["hpv"] = copy
	var errors := DataValidator.validate_enemies(broken)
	check(errors.size() == 1 and errors[0].begins_with("hpv: health"), "validation names the enemy and the missing health")
	var weak_boss := _enemies.duplicate()
	var boss: EnemyData = _enemies["hiv"].duplicate()
	boss.health = 100.0
	weak_boss["hiv"] = boss
	check(not DataValidator.validate_enemies(weak_boss).is_empty(), "a weak boss fails validation")
	var broken_towers := _towers.duplicate()
	var tower: TowerData = _towers["lysozyme"].duplicate()
	tower.cost = 0
	broken_towers["lysozyme"] = tower
	var tower_errors := DataValidator.validate_towers(broken_towers)
	check(tower_errors.size() == 1 and tower_errors[0].begins_with("lysozyme: cost"), "validation names the tower and the missing cost")
	done("test_validator_catches_problems")


# --- damage -----------------------------------------------------------------

func test_damage_calculator() -> void:
	check(approx(_table.factor("chemical", "bacterium"), 1.5), "chemical vs bacterium is 1.5")
	check(approx(_table.factor("antiviral", "bacterium"), 0.0), "antiviral vs bacterium is 0")
	var resolve := func(amount: float, type: String, id: String, mark: float = 0.0) -> int:
		return DamageCalculator.resolve(amount, type, _enemies[id], _table, mark)
	check(resolve.call(6, "antiviral", "rhinovirus") == 9, "antiviral 6 on a virus deals 9")
	check(resolve.call(6, "antiviral", "e-coli") == 0, "antiviral on a bacterium deals 0")
	check(resolve.call(6, "chemical", "rhinovirus") == 3, "chemical 6 on a virus deals 3")
	check(resolve.call(6, "chemical", "e-coli") == 9, "chemical 6 on a bacterium deals 9")
	check(resolve.call(12, "physical", "hpv") == 8, "physical 12 on HPV (30% armor) deals 8")
	check(resolve.call(10, "chemical", "mycobacterium-tuberculosis") == 15, "armor does not reduce chemical damage")
	check(resolve.call(30, "immunological", "mycobacterium-tuberculosis") == 30, "immunological ignores armor")
	check(resolve.call(12, "physical", "mycobacterium-tuberculosis") == 8, "physical 12 on tuberculosis (30% armor) deals 8")
	check(resolve.call(4, "thermal", "clostridioides-difficile") == 2, "the spore takes half thermal damage")
	check(resolve.call(3, "thermal", "clostridioides-difficile") == 1, "a fever tick on the spore deals 1")
	check(resolve.call(12, "physical", "rhinovirus", 0.25) == 15, "a mark adds 25% damage")
	done("test_damage_calculator")


func test_status_effects() -> void:
	var rhino := EnemyStatus.new(_enemies["rhinovirus"])
	rhino.apply_slow("a", 40.0)
	check(approx(rhino.speed_multiplier(), 0.6), "a mucus slow leaves 60% speed")
	rhino.apply_slow("b", 40.0)
	rhino.apply_slow("c", 30.0)
	check(approx(rhino.speed_multiplier(), 0.6), "slows do not stack")
	rhino.advance(1.4)
	check(rhino.is_slowed(), "the slow lingers for 1.5 s")
	rhino.advance(0.2)
	check(not rhino.is_slowed() and approx(rhino.speed_multiplier(), 1.0), "the slow ends after the linger time")
	var boss := EnemyStatus.new(_enemies["mycobacterium-tuberculosis"])
	boss.apply_slow("a", 40.0)
	check(approx(boss.speed_multiplier(), 0.8), "a boss gets half the slow")
	var pylori := EnemyStatus.new(_enemies["helicobacter-pylori"])
	check(not pylori.apply_slow("a", 40.0) and approx(pylori.speed_multiplier(), 1.0), "slow-immune enemies are not slowed")

	var target := EnemyStatus.new(_enemies["rhinovirus"])
	check(target.apply_root("p", 1.2, 3.0) and target.is_rooted() and target.speed_multiplier() == 0.0, "a platelet roots an enemy")
	target.advance(1.3)
	check(not target.is_rooted(), "the root lasts 1.2 s")
	target.advance(2.5)
	check(not target.apply_root("p", 1.2, 3.0), "the same platelet cannot root again within 3 s")
	target.advance(0.6)
	check(target.apply_root("p", 1.2, 3.0), "the platelet can root again after the cooldown")
	var big := EnemyStatus.new(_enemies["mycobacterium-tuberculosis"])
	big.apply_root("p", 1.2, 3.0)
	big.advance(0.7)
	check(not big.is_rooted(), "a boss is rooted for half the time (0.6 s)")
	check(not EnemyStatus.new(_enemies["helicobacter-pylori"]).apply_root("p", 1.2, 3.0), "slow-immune enemies cannot be rooted")

	var fever := EnemyStatus.new(_enemies["rhinovirus"])
	fever.apply_dot(3.0, "thermal", 4.0)
	var ticks := 0
	var total := 0.0
	for i in 90:
		for tick in fever.advance(0.05):
			ticks += 1
			total += tick["damage"]
	check(ticks == 4 and approx(total, 12.0), "fever deals 3 per tick for 4 ticks")
	var refreshed := EnemyStatus.new(_enemies["rhinovirus"])
	refreshed.apply_dot(3.0, "thermal", 4.0)
	ticks = 0
	for i in 160:
		if i == 40:
			refreshed.apply_dot(3.0, "thermal", 4.0)
		for tick in refreshed.advance(0.05):
			ticks += 1
			check(approx(tick["damage"], 3.0), "a refreshed fever does not stack its damage")
	check(ticks == 6, "reapplying fever restarts the 4 s (6 ticks in total)")
	var marked := EnemyStatus.new(_enemies["rhinovirus"])
	marked.apply_mark(0.25, 5.0)
	check(approx(marked.mark_bonus(), 0.25), "a mark adds 25%")
	marked.advance(5.1)
	check(approx(marked.mark_bonus(), 0.0), "a mark ends after 5 s")
	var tinted := EnemyStatus.new(_enemies["rhinovirus"])
	check(tinted.mark_amount() == 0.0, "an unmarked enemy keeps its colors")
	tinted.apply_mark(0.35, 5.0, Color(0.78, 0.5, 0.9))
	check(tinted.mark_amount() == 1.0 and tinted.mark_color().is_equal_approx(Color(0.78, 0.5, 0.9)), "a marked enemy is dyed with the color of the lymphocyte")
	tinted.advance(4.7)
	check(tinted.mark_amount() > 0.0 and tinted.mark_amount() < 1.0, "the dye eases out as the mark runs out")
	tinted.advance(0.5)
	check(tinted.mark_amount() == 0.0, "the dye is gone when the mark ends")
	done("test_status_effects")


# --- waves ------------------------------------------------------------------

func collect_spawns(scheduler: WaveScheduler) -> Array:
	var spawns: Array = []
	scheduler.enemy_spawned.connect(func(id: String) -> void: spawns.append([scheduler.clock, id]))
	return spawns


func test_wave_scheduler() -> void:
	var scheduler := WaveScheduler.new(_level_data.waves)
	var spawns := collect_spawns(scheduler)
	var starts: Array = []
	scheduler.wave_started.connect(func(index: int) -> void: starts.append([index, scheduler.clock]))
	for i in int(160.0 / 0.05):
		scheduler.tick(0.05)
	check(starts.size() == 3, "three waves start")
	check(approx(starts[0][1], 5.0, 0.1) and approx(starts[1][1], 50.0, 0.1) and approx(starts[2][1], 150.0, 0.1), "waves start at 5, 50 and 150 s")
	check(spawns.size() == 8 + 14 + 10, "all enemies of the three waves spawn")
	check(approx(spawns[1][0] - spawns[0][0], 1.2, 0.1), "wave 1 enemies spawn 1.2 s apart")
	check(spawns[8][1] == "rhinovirus" and spawns[18][1] == "influenza", "wave 2 spawns rhinoviruses then influenza")
	check(scheduler.spawning_done() and scheduler.all_started(), "the scheduler finishes")

	var early := WaveScheduler.new(_level_data.waves)
	var early_starts: Array = []
	early.wave_started.connect(func(index: int) -> void: early_starts.append([index, early.clock]))
	for i in int(10.0 / 0.05):
		early.tick(0.05)
	check(early.call_next_wave(), "the next wave can be called")
	for i in int(150.0 / 0.05):
		early.tick(0.05)
	check(early_starts.size() == 3, "calling early does not start a wave twice")
	check(approx(early_starts[1][1], 10.0, 0.1), "calling at 10 s starts wave 2 at once")
	check(approx(early_starts[2][1], 150.0, 0.1), "wave 3 still starts at 150 s")
	check(not early.call_next_wave(), "no wave can be called when all have started")
	check(early.time_to_next_wave() == -1.0, "no countdown once every wave started")
	done("test_wave_scheduler")


# --- economy ----------------------------------------------------------------

func test_economy() -> void:
	Economy.reset(150)
	check(Economy.balance() == 150, "the level starts with its amino acids")
	check(not Economy.try_spend(200) and Economy.balance() == 150, "a spend larger than the balance is refused")
	check(Economy.try_spend(50) and Economy.balance() == 100, "an affordable spend works")
	Economy.add(5)
	check(Economy.balance() == 105, "adding amino acids raises the balance")
	check(Economy.refund_for(100) == 60 and Economy.refund_for(50) == 30, "selling refunds 60%")
	var original: float = Economy.config.refund_fraction
	Economy.config.refund_fraction = 0.5
	check(Economy.refund_for(100) == 50, "the refund fraction comes from data")
	Economy.config.refund_fraction = original
	var level_copy: LevelData = _level_data.duplicate()
	level_copy.starting_amino_acids = 77
	var level := Level.new(level_copy)
	get_tree().root.add_child(level)
	check(Economy.balance() == 77, "the starting amount comes from the level data")
	free_node(level)
	done("test_economy")


# --- level simulation -------------------------------------------------------

func run_level(level: Level, bot: AutoplayBot, seconds: float) -> void:
	for i in int(seconds / 0.05):
		level.step(0.05)
		if bot != null:
			bot.think()
		if level.state != "running":
			return


## Spawns an enemy and places it at `progress` map units along the path.
func spawn_at(level: Level, enemy_id: String, progress: float) -> Enemy:
	level._spawn_enemy(enemy_id)
	var enemy: Enemy = level.enemies[level.enemies.size() - 1]
	enemy.progress = progress
	enemy.step(0.0)
	return enemy


func test_level_simulation() -> void:
	var level := new_level()
	check(level.body_health == 20 and Economy.balance() == 150, "the level starts with 150 amino acids and 20 health")
	level._spawn_enemy("rhinovirus")
	var enemy: Enemy = level.enemies[0]
	var balance_before: int = Economy.balance()
	var length := level.curve.get_baked_length()
	var expected := length / enemy.data.speed
	var time := 0.0
	while not enemy.finished and time < 60.0:
		level.step(0.05)
		time += 0.05
	check(approx(time, expected, 0.2), "an enemy crosses the path in %.1f s" % expected)
	check(level.body_health == 19, "an enemy at the exit lowers the body health by its damage")
	check(Economy.balance() == balance_before, "an enemy that reaches the exit gives no amino acids")
	check(not level.enemies.has(enemy), "the enemy is removed at the exit")
	check(level._map.infection() > 0.0 and level._map.infection() < 1.0, "the tissue shows an infection once an enemy got through")
	check(level._map._decor.size() > 0, "the tissue has shapes that move")
	free_node(level)

	level = new_level()
	level._spawn_enemy("rhinovirus")
	var dying: Enemy = level.enemies[0]
	var before: int = Economy.balance()
	dying.take_damage(100.0, "physical")
	check(Economy.balance() == before + 2 and level.enemies.is_empty(), "a defeated enemy gives its amino acid reward")
	free_node(level)

	level = new_level()
	level.step(level.data.waves[0].start_time * level.difficulty.wave_time + 0.1)
	for enemy_left in level.enemies.duplicate():
		enemy_left.take_damage(100000.0, "physical")
	while level.scheduler.is_spawning():
		level.step(0.05)
		for enemy_left in level.enemies.duplicate():
			enemy_left.take_damage(100000.0, "physical")
	check(level.scheduler.time_to_next_wave() > Level.EMPTY_FIELD_WAIT + 0.1, "the next wave is still far away before the field empties")
	level.step(0.05)
	check(level.scheduler.time_to_next_wave() <= Level.EMPTY_FIELD_WAIT, "an empty field brings the next wave within 5 s")
	free_node(level)

	level = new_level()
	check(level.build_tower(1, "macrophage") and Economy.balance() == 100, "building charges the cost")
	check(not level.build_tower(1, "interferon"), "an occupied slot cannot be built on")
	check(not level.build_tower(2, "platelet"), "towers outside the level list cannot be built")
	Economy.reset(10)
	check(not level.build_tower(2, "interferon") and Economy.balance() == 10, "an unaffordable tower is refused and costs nothing")
	check(level.sell_tower(1) == 30 and Economy.balance() == 40, "selling a 50 amino acid tower returns 30")
	free_node(level)

	level = new_level()
	run_level(level, null, 400.0)
	check(level.state == "lost" and level.body_health == 0, "with no towers the body loses")
	free_node(level)

	level = new_level()
	var bot := AutoplayBot.new(level, false)
	run_level(level, bot, 400.0)
	check(level.state == "won" and level.body_health > 0, "the bot wins level 1 (health %d, time %.0f s)" % [level.body_health, level.scheduler.clock])
	bot.free()
	free_node(level)

	level = new_level()
	bot = AutoplayBot.new(level, true)
	run_level(level, bot, 400.0)
	check(level.state == "won" and level.scheduler.clock < 120.0, "calling waves early finishes sooner (%.0f s)" % level.scheduler.clock)
	bot.free()
	free_node(level)

	level = new_level()
	level.build_tower(1, "mucus-cell")
	var near := spawn_at(level, "rhinovirus", 440.0)
	var first := spawn_at(level, "rhinovirus", 480.0)
	var far := spawn_at(level, "rhinovirus", 10.0)
	level.step(0.05)
	check(level._globs.size() == 1 and not near.status.is_slowed(), "the mucus cell throws a glob instead of slowing at once")
	for i in 10:
		level.step(0.05)
	check(level.puddles.size() == 1, "the glob leaves a puddle where it lands")
	check(level.puddles[0].position.distance_to(first.position) < 30.0, "the mucus goes to the first enemy of the queue")
	check(first.status.is_slowed(), "an enemy on the puddle is slowed")
	check(not far.status.is_slowed(), "an enemy far from the puddle is not slowed")
	level.sell_tower(1)
	var walker := spawn_at(level, "rhinovirus", 400.0)
	var slowed_later := false
	for i in 60:
		level.step(0.05)
		slowed_later = slowed_later or walker.status.is_slowed()
	check(slowed_later, "an enemy that walks onto the puddle later is slowed")
	check(approx(level.puddles[0].remaining(), 6.0 - (3.55 - 0.35), 0.25), "the puddle stays on the ground for a few seconds")
	for i in 140:
		level.step(0.05)
	check(level.puddles.is_empty(), "the puddle disappears after 6 seconds")
	free_node(level)

	level = new_level()
	level.build_tower(2, "macrophage")
	var target := spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(target.health == 6.0, "a macrophage hits an enemy in range for 14")
	free_node(level)

	level = new_level()
	level.build_tower(2, "interferon")
	level.step(3.0)
	check(level.towers[2].mist_level() == 0.0, "interferon shows no mist while nothing is in range")
	var slowed_virus := spawn_at(level, "rhinovirus", 850.0)
	var spared_bacterium := spawn_at(level, "e-coli", 850.0)
	level.step(0.05)
	check(approx(slowed_virus.status.slow_percent(), 25.0), "interferon slows viruses by 25%")
	check(spared_bacterium.status.slow_percent() == 0.0, "interferon does not slow bacteria")
	check(level.towers[2].data.mist_color.a > 0.0, "interferon has a mist")
	level.step(0.05)
	check(level.towers[2].mist_level() > 0.0, "interferon releases its mist when it attacks")
	free_node(level)

	level = new_level()
	level.build_tower(1, "interferon")
	level.build_tower(0, "mucus-cell")
	var both := spawn_at(level, "rhinovirus", 460.0)
	for i in 14:
		level.step(0.05)
	check(approx(both.status.slow_percent(), 40.0), "with interferon and a mucus puddle the strongest slow counts (40%)")
	free_node(level)

	level = new_level()
	level.build_tower(2, "interferon")
	var virus := spawn_at(level, "rhinovirus", 850.0)
	var bacterium := spawn_at(level, "streptococcus-pyogenes", 850.0)
	level.step(0.05)
	check(virus.health == 13.0, "interferon hits a virus for 7")
	check(bacterium.health == 100.0, "interferon does not hurt a bacterium")
	free_node(level)

	for id in ["macrophage", "mucus-cell", "interferon"]:
		var frames := TowerSprites.frames_for(id)
		check(frames != null and frames.get_frame_count("idle") == 8 and frames.get_frame_count("attack") == 8,
			"%s has 8-frame idle and attack animations" % id)
		check(frames.get_animation_loop("idle") and not frames.get_animation_loop("attack"), "%s idles in a loop and attacks once" % id)
	check(TowerSprites.frames_for("no-such-tower") == null, "towers without art fall back to a still image")

	level = new_level()
	level.build_tower(2, "macrophage")
	check(level.towers[2].current_animation() == "idle", "a built tower idles")
	spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(level.towers[2].current_animation() == "attack", "the macrophage plays its attack animation when it hits")
	free_node(level)

	level = new_level()
	level.build_tower(2, "interferon")
	spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(level.towers[2].current_animation() == "attack", "the interferon plays its attack animation when it pulses")
	free_node(level)

	level = new_level()
	var tinted := spawn_at(level, "e-coli", 300.0)
	tinted.take_damage(1.0, "chemical", "test")
	check(tinted._sprite.self_modulate != Color.WHITE, "a chemical hit flashes its colour on the enemy")
	free_node(level)

	level = level_with_tower("hypothalamus")
	level.step(2.0)
	check(level.towers[2].current_animation() == "idle", "the hypothalamus idles while nothing is in range")
	var burning := spawn_at(level, "rhinovirus", 850.0)
	check(not burning._flames.visible, "an enemy that is not burning shows no flames")
	level.step(0.05)
	check(level.towers[2].current_animation() == "attack", "the hypothalamus plays its attack animation when it sets an enemy on fire")
	check(burning._flames.visible and level.towers[2]._pulse_seconds() == Tower.FEVER_WAVE_SECONDS, "a burning enemy shows flames and the fever wave runs")
	burning.speed = 0.0
	level.towers[2]._pulse_age = -1.0
	level.step(0.5)
	check(level.towers[2]._pulse_age < 0.0, "the hypothalamus waits between attacks")
	level.step(0.6)
	check(level.towers[2]._pulse_age >= 0.0, "the hypothalamus keeps attacking enemies that already burn")
	burning.status.advance(2.0)
	level.towers[2]._cooldown = 0.0
	level.step(0.05)
	check(burning.status.has_dot() and burning.status._dot_until >= burning.status.time + data_dot_seconds() - 0.1, "each fire attack brings the burn back to its full time")
	free_node(level)

	level = level_with_tower("t-lymphocyte")
	var caster: Tower = level.towers[2]
	check(caster.current_animation() == "idle", "the T lymphocyte starts out ready, idling")
	spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(caster.current_animation() == "attack" and caster._beam.is_active(), "the T lymphocyte fires a beam with an explosion")
	caster._after_attack()
	check(caster.current_animation() == "charge", "after firing the T lymphocyte charges")
	check(is_equal_approx(caster._sprite.speed_scale, 1.0 / (2.0 - 8.0 / 12.0)), "the charge lasts until the next shot")
	free_node(level)

	level = level_with_tower("platelet")
	spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(level.towers[2].current_animation() == "attack", "the platelet plays its attack animation when it roots an enemy")
	check(level.towers[2].holds().size() == 1, "the platelet holds the rooted enemy with tendrils")
	for i in 25:
		level.step(0.1)
	check(level.towers[2].holds().size() == 1, "the tendril stays for the whole 3 s of the hold")
	for i in 10:
		level.step(0.1)
	check(level.towers[2].holds().is_empty(), "the tendrils are gone once the enemy is free")
	free_node(level)

	level = level_with_tower("platelet")
	for i in 5:
		spawn_at(level, "rhinovirus", 850.0 + i * 3.0)
	level.step(0.05)
	check(level.towers[2].holds().size() == 3, "the platelet holds at most 3 enemies at once (one tendril each)")
	var furthest: Enemy = level.enemies[0]
	for candidate: Enemy in level.enemies:
		if candidate.progress > furthest.progress:
			furthest = candidate
	check(furthest.status.is_rooted(), "the platelet holds the enemy that has walked the furthest")
	GameAudio.record = true
	GameAudio.reset()
	level.step(0.05)
	check(GameAudio.play_log.is_empty(), "the platelet makes no sound while it only holds its enemies")
	GameAudio.record = false
	free_node(level)

	level = level_with_tower("lysozyme")
	spawn_at(level, "e-coli", 850.0)
	level.step(0.05)
	check(level.towers[2].current_animation() == "attack", "the lysozyme plays its attack animation when it dissolves")
	check(level.towers[2]._pulse_age >= 0.0, "an area attack sends a visible ring across the range")
	level.step(Tower.PULSE_SECONDS + 0.1)
	check(level.towers[2]._pulse_age < 0.0 or level.towers[2]._pulse_age < Tower.PULSE_SECONDS, "the ring ends or restarts with the next attack")
	free_node(level)

	level = new_level()
	level.build_tower(1, "mucus-cell")
	spawn_at(level, "rhinovirus", 460.0)
	level.step(0.05)
	check(level.towers[1].current_animation() == "attack", "the mucus cell plays its secreting animation when it slows")
	free_node(level)

	var tower := Tower.new()
	tower.setup(_towers["macrophage"], 0, null)
	tower.disable()
	check(tower.is_disabled(), "a disabled tower stops")
	var lymphocyte := Tower.new()
	lymphocyte.setup(_towers["t-lymphocyte"], 0, null)
	lymphocyte.disable()
	check(approx(lymphocyte._disabled_for, 6.0) and approx(tower._disabled_for, 3.0), "disabling lasts 3 s, or 6 s for a lymphocyte")
	tower.free()
	lymphocyte.free()
	done("test_level_simulation")


func test_scrolling() -> void:
	var level := new_level()
	var limits := level.scroll_limits()
	check(approx(level.scroll.y, -Level.SAFE_TOP) and level.scroll.x == 0.0, "the view starts at the entrance")
	level.scroll_by(Vector2(0.0, 100000.0))
	check(approx(level.scroll.y, limits.end.y) and approx(limits.end.y, 280.0), "the view stops at the bottom of the map")
	level.set_scroll(Vector2(0.0, 100.0))
	var focus := Vector2(300.0, 500.0)
	var world_focus := level.screen_to_world(focus)
	level.zoom_by(1.5, focus)
	check(approx(level.zoom, 1.5) and level.screen_to_world(focus).distance_to(world_focus) < 0.5, "zooming in keeps the point under the fingers in place")
	level.set_zoom(100.0)
	check(level.zoom == Level.ZOOM_MAX, "the zoom stops at its maximum")
	level.set_zoom(0.01)
	check(level.zoom == level.zoom_min(), "the zoom stops at its minimum")
	var zoomed_limits := level.scroll_limits()
	var visible_height := (Level.VIEW_SIZE.y - Level.SAFE_BOTTOM) / level.zoom
	check(zoomed_limits.end.y + visible_height >= _level_data.map_size.y - 0.01 and zoomed_limits.position.y <= -Level.SAFE_TOP / level.zoom + 0.01, "zoomed out, the whole map fits between the bars")
	check(level.tap_radius() > Level.TAP_RADIUS, "zoomed out, taps keep a usable size")
	level.set_zoom(1.0)
	level.set_scroll(Vector2(0.0, limits.end.y))
	level.scroll_by(Vector2(0.0, -100000.0))
	check(approx(level.scroll.y, limits.position.y), "the view stops at the top of the map")
	level.scroll_by(Vector2(5000.0, 0.0))
	check(level.scroll.x == 0.0, "a map as wide as the screen does not scroll sideways")
	level.set_scroll(Vector2(0.0, 200.0))
	var slot_screen := level.world_to_screen(_level_data.slots[3])
	check(approx(level.screen_to_world(slot_screen).distance_to(_level_data.slots[3]), 0.0), "screen and map positions convert back and forth")
	var tapped: Array = []
	level.slot_tapped.connect(func(i: int) -> void: tapped.append(i))
	level.handle_tap(slot_screen)
	check(tapped == [3], "a tap is placed using the scrolled position")
	level.set_scroll(Vector2(0.0, -Level.SAFE_TOP))
	level.handle_tap(slot_screen)
	check(tapped == [3], "the same screen spot hits nothing when the map is not scrolled there")
	level.set_scroll(Vector2(0.0, 200.0))
	level._spawn_enemy("rhinovirus")
	var enemy: Enemy = level.enemies[0]
	enemy.progress = 1200.0
	enemy.step(0.0)
	var tapped_enemies: Array = []
	level.enemy_tapped.connect(func(e: Enemy) -> void: tapped_enemies.append(e))
	level.handle_tap(level.world_to_screen(enemy.position))
	check(tapped_enemies == [enemy], "an enemy can be tapped on a scrolled map")
	free_node(level)
	done("test_scrolling")


func test_speed_and_pause() -> void:
	var level := new_level()
	await get_tree().process_frame
	var start := level.scheduler.clock
	for i in 60:
		await get_tree().process_frame
	var normal := level.scheduler.clock - start
	level.toggle_speed()
	check(Engine.time_scale == 2.0 and level.speed == 2, "the speed button switches to 2x")
	start = level.scheduler.clock
	for i in 60:
		await get_tree().process_frame
	var fast := level.scheduler.clock - start
	check(approx(normal, 1.0, 0.15) and approx(fast, 2.0, 0.25), "at 2x the level clock runs twice as fast (%.2f s vs %.2f s)" % [fast, normal])
	level.set_paused(true)
	check(not level.can_process(), "the level stops while paused")
	start = level.scheduler.clock
	for i in 20:
		await get_tree().process_frame
	check(level.scheduler.clock == start, "the clock does not advance while paused")
	level.set_paused(false)
	free_node(level)
	var next_level := new_level()
	check(Engine.time_scale == 1.0 and next_level.speed == 1, "a new level starts at 1x")
	free_node(next_level)
	done("test_speed_and_pause")


# --- HUD --------------------------------------------------------------------

func data_dot_seconds() -> float:
	return 4.0


func test_heartbeat() -> void:
	check(MapView.heartbeat(0.0) > 0.95 and MapView.heartbeat(0.5) > 0.5 and MapView.heartbeat(0.5) < MapView.heartbeat(0.0), "the path beats strong then weak, like a heart")
	check(MapView.heartbeat(1.6) < 0.01, "the path rests between beats")
	var smooth := true
	for i in 100:
		if absf(MapView.heartbeat((i + 1) * 0.083) - MapView.heartbeat(i * 0.083)) > 0.4:
			smooth = false
	check(smooth, "the beat changes gently from frame to frame")


func test_revive() -> void:
	var level := new_level()
	var spore := spawn_at(level, "clostridioides-difficile", 100.0)
	var max_health := spore.max_health
	spore.take_damage(max_health + 10.0, "physical")
	check(spore.is_reviving() and not spore.finished, "the first death of a C. difficile starts the revive animation")
	check(spore.current_animation() == "death", "a reviving C. difficile plays its death animation")
	check(spore.take_damage(5.0, "physical") == 0 and level.enemies_in_range(spore.position, 50.0).is_empty(), "a reviving enemy cannot be hurt or targeted")
	var at := spore.progress
	spore.step(1.0)
	check(spore.progress == at, "a reviving enemy does not move")
	spore.step(0.2)
	check(spore.is_reviving() and spore.current_animation() == "death", "the C. difficile lies still after dying")
	spore.step(0.6)
	check(spore.is_reviving(), "the C. difficile is getting up")
	spore.step(1.0)
	check(not spore.is_reviving() and spore.health == ceilf(max_health * spore.param("health", 0.25)), "the C. difficile gets up with a part of its health")
	check(spore.current_animation() == "walk", "the C. difficile walks again after getting up")
	spore.take_damage(max_health, "physical")
	check(spore.finished, "the second death is final")
	free_node(level)


func test_hud() -> void:
	var orb_level := new_level()
	var orb_hud := Hud.new(orb_level)
	get_tree().root.add_child(orb_hud)
	await get_tree().process_frame
	var built_signals: Array = []
	orb_level.tower_built.connect(func(tower: Tower) -> void: built_signals.append(tower.data.cost))
	orb_level.build_tower(1, "macrophage", false)
	check(built_signals == [50], "building a tower announces its cost so amino acids can flow to it")
	var pending: Tower = orb_level.towers[1]
	check(pending.under_construction and not pending.visible, "a tower is hidden while its amino acids are on the way")
	orb_level.handle_tap(orb_level.world_to_screen(pending.position))
	check(orb_level.tower_slot_at(orb_level.world_to_screen(pending.position)) == -1, "a tower under construction cannot be tapped")
	await get_tree().create_timer(0.3).timeout
	check(pending.under_construction, "the tower is still not built before the amino acids arrive")
	await get_tree().create_timer(1.0).timeout
	check(not pending.under_construction and pending.visible, "the tower appears when its amino acids arrive")
	Economy.reset(150)
	orb_level.orbs_requested.emit(Vector2(100, 100), 7)
	Economy.add(7)
	await get_tree().process_frame
	await get_tree().process_frame
	check(orb_hud._amino_label.text == "150", "earned amino acids are not counted while their orbs fly")
	await get_tree().create_timer(1.2).timeout
	check(orb_hud._amino_label.text == "157", "the bar counts the amino acids when the orbs arrive")
	free_node(orb_hud)
	free_node(orb_level)
	Economy.reset(150)

	var level := new_level()
	var hud := Hud.new(level)
	get_tree().root.add_child(hud)
	await get_tree().process_frame
	check(hud._health_label.text == "20/20" and hud._amino_label.text == "150", "the top bar shows health and amino acids")
	check(hud._wave_label.text == "WAVE 0/3", "the top bar shows the wave progress")
	check(hud._level_label.text == "THROAT", "the top bar shows the level name")
	check(hud.find_children("*", "", true, false).filter(func(n: Node) -> bool: return String(n.name).to_lower().contains("atp")).is_empty(), "no ATP element in the HUD")

	level.slot_tapped.emit(1)
	var menu := hud._popup.get_node_or_null("BuildMenu")
	check(menu != null and menu.get_child_count() == 3, "tapping a slot opens a menu with the three towers")
	menu.get_node("Card_macrophage").pressed.emit()
	check(level.towers.has(1) and Economy.balance() == 100, "choosing a tower builds it and charges the cost")

	Economy.reset(10)
	level.slot_tapped.emit(2)
	hud._popup.get_node("BuildMenu").get_node("Card_interferon").pressed.emit()
	check(not level.towers.has(2) and Economy.balance() == 10, "an unaffordable tower is not built")
	check(hud._toast.text == "NOT ENOUGH AMINO ACIDS" and hud._toast.modulate.a > 0.9, "the player gets feedback when amino acids are insufficient")
	var catcher: Control = hud._popup.get_node("PopupCatcher")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	catcher.gui_input.emit(click)
	check(hud._slot_for_menu == -1 and not level.towers.has(2), "tapping outside closes the menu without building")

	Economy.reset(0)
	level.tower_tapped.emit(1)
	var card := hud._popup.get_node("TowerCard")
	check(card.get_node("Name").text == "MACROPHAGE", "the tower card shows the tower name")
	check(card.get_node("Damage").text == "DAMAGE: 14/S (PHYSICAL)", "the tower card shows the damage")
	check(card.get_node("Ability").text == _towers["macrophage"].ability_description and card.get_node("Ability").text != "", "the tower card shows the ability")
	var ability_box: Label = card.get_node("Ability")
	check(ability_box.size.x <= card.size.x - 32.0 + 0.5, "the ability text wraps inside the card (%.0f px wide)" % ability_box.size.x)
	var saved_balance: int = Economy.balance()
	Economy.reset(1000)
	for id in ["macrophage", "mucus-cell", "interferon"]:
		level.build_tower(3, id)
		level.tower_tapped.emit(3)
		var each: Label = hud._popup.get_node("TowerCard").get_node("Ability")
		check(each.size.x <= 408.5 and each.get_line_count() <= 5, "the %s ability text fits its box (%d lines)" % [id, each.get_line_count()])
		hud._dismiss_all()
		level.sell_tower(3)
	Economy.reset(saved_balance)
	level.tower_tapped.emit(1)
	card = hud._popup.get_node("TowerCard")
	var sell: Button = card.get_node("SellButton")
	check(sell.position.y > card.get_node("Ability").position.y, "the sell button is below the ability")
	check(sell.text == "SELL +30", "the sell button shows the refund")
	sell.pressed.emit()
	check(not level.towers.has(1) and Economy.balance() == 30, "selling removes the tower and refunds 60%")

	hud._refresh_wave_info()
	check(hud._countdown_label.text == "NEXT WAVE IN 5S" and hud._call_button.visible, "the countdown and call button show before wave 1")
	check(hud._preview_box.get_child_count() == 1, "the next wave preview shows its enemy")
	hud._call_button.pressed.emit()
	check(level.scheduler.started_count() == 1, "the call button starts the next wave")

	level._spawn_enemy("streptococcus-pyogenes")
	level.enemy_tapped.emit(level.enemies[0])
	check(hud._enemy_card.visible and hud._card_lines.text.contains("IMMUNE: ANTIVIRAL"), "the enemy card of a bacterium lists antiviral as an immunity")
	check(hud._card_lines.text.contains("HP 100/100"), "the enemy card shows health")
	level.nothing_tapped.emit()
	check(not hud._enemy_card.visible, "the enemy card closes when the player taps elsewhere")

	hud._speed_button.pressed.emit()
	check(hud._speed_button.text == "2X", "the speed button shows 2X")
	hud._speed_button.pressed.emit()
	check(hud._speed_button.text == "1X", "the speed button shows 1X again")

	hud._pause_button.pressed.emit()
	check(get_tree().paused and hud._overlay.get_child_count() > 0 and hud.can_process(), "pausing shows the overlay and keeps the HUD working")
	var overlay_buttons := hud._overlay.find_children("*", "Button", true, false)
	check(overlay_buttons.size() == 3, "the pause overlay has resume, restart and menu")
	overlay_buttons[0].pressed.emit()
	check(not get_tree().paused, "resuming continues the game")

	hud.level.set_scroll(Vector2(0.0, -Level.SAFE_TOP))
	var empty_taps: Array = []
	level.nothing_tapped.connect(func() -> void: empty_taps.append(1))
	var slots_tapped: Array = []
	level.slot_tapped.connect(func(i: int) -> void: slots_tapped.append(i))
	hud._on_map_input(mouse_button(Vector2(360, 700), true))
	hud._on_map_input(mouse_motion(Vector2(360, 600), Vector2(0, -100)))
	hud._on_map_input(mouse_motion(Vector2(360, 500), Vector2(0, -100)))
	hud._on_map_input(mouse_button(Vector2(360, 500), false))
	check(approx(level.scroll.y, -Level.SAFE_TOP + 100.0), "dragging up scrolls the map down by the finger distance (%.0f)" % level.scroll.y)
	check(empty_taps.is_empty() and slots_tapped.is_empty(), "a drag does not count as a tap")
	hud._on_map_input(mouse_button(Vector2(360, 500), true))
	hud._on_map_input(mouse_motion(Vector2(362, 503), Vector2(2, 3)))
	hud._on_map_input(mouse_button(Vector2(362, 503), false))
	check(empty_taps.size() == 1 and approx(level.scroll.y, -Level.SAFE_TOP + 100.0), "a small movement is still a tap and does not scroll")
	level.slot_tapped.emit(1)
	check(hud._popup.get_node_or_null("BuildMenu") != null, "the build menu is open before scrolling")
	hud._on_map_input(mouse_button(Vector2(360, 600), true))
	hud._on_map_input(mouse_motion(Vector2(360, 560), Vector2(0, -40)))
	hud._on_map_input(mouse_button(Vector2(360, 560), false))
	check(hud._slot_for_menu == -1 and hud._popup.get_child_count() == 0, "scrolling closes the open menu")
	var before: float = level.scroll.y
	hud._on_map_input(mouse_wheel(MOUSE_BUTTON_WHEEL_DOWN))
	check(approx(level.scroll.y, before + Hud.WHEEL_STEP), "the mouse wheel scrolls the map")
	check(hud._scroll_track != null and hud._scroll_track.size.y > 0.0, "the HUD has a scroll indicator")
	level.set_scroll(Vector2(0.0, -Level.SAFE_TOP))

	var small := 0
	for node in get_tree().get_nodes_in_group("tap_target"):
		if node.is_inside_tree() and not node.is_queued_for_deletion() and (node.size.x < Hud.MIN_TAP or node.size.y < Hud.MIN_TAP):
			small += 1
			printerr("small tap target: %s %s" % [node.name, node.size])
	check(small == 0, "every tappable HUD control is at least 48 dp (96 px)")
	check(Level.TAP_RADIUS * 2.0 * Level.SHRINK >= Hud.MIN_TAP, "slots and enemies have a tap area of at least 48 dp")
	hud.level.set_paused(false)
	free_node(hud)
	free_node(level)

	level = new_level()
	hud = Hud.new(level)
	get_tree().root.add_child(hud)
	level.body_health = 1
	level._spawn_enemy("rhinovirus")
	level.enemies[0].progress = 2000.0
	level.step(0.05)
	check(level.state == "lost" and hud._overlay.get_node_or_null("OverlayPanel") != null, "the defeat overlay appears when the body is lost")
	free_node(hud)
	free_node(level)

	level = new_level()
	hud = Hud.new(level)
	get_tree().root.add_child(hud)
	var bot := AutoplayBot.new(level, true)
	run_level(level, bot, 400.0)
	check(level.state == "won" and hud._overlay.get_node_or_null("OverlayPanel") != null, "the victory overlay appears when the level is won")
	bot.free()
	free_node(hud)
	free_node(level)
	done("test_hud")


# --- audio ------------------------------------------------------------------

func test_audio() -> void:
	GameAudio.record = true
	GameAudio.reset()
	for id in _enemies:
		var e: EnemyData = _enemies[id]
		check(ResourceLoader.exists(e.sound_hit) and ResourceLoader.exists(e.sound_attack) and ResourceLoader.exists(e.sound_death),
			"%s has hit, attack and death sounds" % id)
		check(e.sound_hit != e.sound_attack and e.sound_attack != e.sound_death, "%s uses three different sounds" % id)
	for id in _towers:
		check(ResourceLoader.exists(_towers[id].sound_attack), "%s has an attack sound" % id)
	check(ResourceLoader.exists(GameAudio.config.blocked_sound), "the blocked sound exists")
	check(ResourceLoader.exists(_level_data.music), "level 1 has music")
	var deaths := {}
	for id in _enemies:
		var stream := load(_enemies[id].sound_death) as AudioStreamWAV
		deaths[id] = stream.get_length()
	check(deaths["hiv"] > 0.6 and deaths["mycobacterium-tuberculosis"] > 0.6 and deaths["neisseria-meningitidis"] > 0.6, "boss deaths last longer than 0.6 s")
	check(deaths["rhinovirus"] < 0.4 and deaths["e-coli"] < 0.4, "regular deaths are short")

	var broken := _enemies.duplicate()
	var copy: EnemyData = _enemies["hpv"].duplicate()
	copy.sound_death = "res://assets/audio/enemies/hpv/missing.wav"
	broken["hpv"] = copy
	var errors := DataValidator.validate_enemies(broken)
	check(errors.size() == 1 and errors[0].begins_with("hpv: sound_death"), "validation names the enemy and the missing sound")
	var silent := _towers.duplicate()
	var quiet: TowerData = _towers["lysozyme"].duplicate()
	quiet.sound_attack = ""
	silent["lysozyme"] = quiet
	var tower_errors := DataValidator.validate_towers(silent)
	check(tower_errors.size() == 1 and tower_errors[0].begins_with("lysozyme: sound_attack"), "validation names the tower with no sound")

	var path: String = _enemies["rhinovirus"].sound_hit
	GameAudio.reset()
	for i in 50:
		GameAudio.play_sfx(path)
	check(GameAudio.play_log.size() == 1, "fifty requests for one sound in one frame start it once")
	GameAudio.reset()
	var started := 0
	for id in _enemies:
		for sound in [_enemies[id].sound_hit, _enemies[id].sound_attack, _enemies[id].sound_death]:
			if GameAudio.play_sfx(sound):
				started += 1
	# Short sounds can finish while the loop loads the rest and free a voice, so more than 8 may start; never more than 8 at a time.
	check(started >= GameAudio.VOICES and GameAudio.voices_in_use() <= GameAudio.VOICES, "no more than 8 sounds play at once (%d started)" % started)

	var level := new_level()
	GameAudio.reset()
	var enemy := spawn_at(level, "rhinovirus", 100.0)
	enemy.take_damage(5.0, "physical")
	check(GameAudio.play_log == [enemy.data.sound_hit], "a hit plays the hit sound")
	GameAudio.reset()
	enemy.take_damage(100.0, "physical")
	check(GameAudio.play_log == [enemy.data.sound_death], "a defeated enemy plays its death sound")
	GameAudio.reset()
	var bacterium := spawn_at(level, "e-coli", 100.0)
	bacterium.take_damage(6.0, "antiviral")
	check(GameAudio.play_log == [GameAudio.config.blocked_sound], "an immune enemy plays the blocked sound, not its hit sound")
	GameAudio.reset()
	var runner := spawn_at(level, "influenza", 1699.0)
	runner.step(0.5)
	check(GameAudio.play_log == [runner.data.sound_attack], "an enemy at the exit plays its attack sound")
	free_node(level)

	for tower_id in ["macrophage", "mucus-cell", "interferon"]:
		level = new_level()
		var slot := 2 if tower_id != "mucus-cell" else 1
		level.build_tower(slot, tower_id)
		GameAudio.reset()
		spawn_at(level, "rhinovirus", 850.0 if slot == 2 else 460.0)
		level.step(0.05)
		check(GameAudio.play_log.has(_towers[tower_id].sound_attack), "the %s plays its own attack sound" % tower_id)
		free_node(level)

	GameAudio.reset()
	level = new_level()
	check(GameAudio.current_music == level.data.music and GameAudio.is_music_playing(), "the music starts with the level")
	check(GameAudio.music_stream().loop_mode == AudioStreamWAV.LOOP_FORWARD and GameAudio.music_stream().loop_begin == 0, "the music loops")
	var playing_stream := GameAudio.music_stream()
	check(playing_stream.loop_end == roundi(playing_stream.get_length() * playing_stream.mix_rate), "the loop covers the whole music, so there is no gap")
	check(playing_stream.get_length() >= 180.0, "the level music lasts at least three minutes")
	check(approx(GameAudio.music_volume_db(), GameAudio.config.music_volume_db) and GameAudio.config.music_volume_db < GameAudio.config.sfx_volume_db, "the music volume comes from data and is below the effects")
	level.set_paused(true)
	check(GameAudio.can_process() and GameAudio.is_music_playing(), "the music keeps playing while paused")
	level.set_paused(false)
	level.victory.emit()
	check(GameAudio.current_music == GameAudio.config.victory_music and GameAudio.is_music_playing(), "winning plays the victory tune")
	check(GameAudio.music_stream().loop_mode == AudioStreamWAV.LOOP_DISABLED and GameAudio.music_stream().get_length() < 15.0, "the victory tune is short and plays once")
	level.defeat.emit()
	check(GameAudio.current_music == GameAudio.config.defeat_music and ResourceLoader.exists(GameAudio.config.defeat_music), "losing plays the defeat tune")
	GameAudio.stop_music()
	check(GameAudio.music_fading, "the music fades out when asked")
	for i in 120:
		await get_tree().process_frame
	check(not GameAudio.is_music_playing(), "the music is silent after the fade")
	free_node(level)
	GameAudio.record = false
	GameAudio.reset()
	done("test_audio")



# --- the ten levels ---------------------------------------------------------

func campaign_level(number: int) -> Level:
	var level := Level.new(Session.load_level(number))
	get_tree().root.add_child(level)
	return level


func test_campaign_data() -> void:
	var levels: Array = []
	var music := {}
	var names := {}
	var used_enemies := {}
	for number in range(1, 11):
		var data: LevelData = Session.load_level(number)
		levels.append(data)
		check(data != null and data.number == number and data.id == "level_%d" % number, "level %d loads with its number and id" % number)
		check(DataValidator.validate_level(data, _towers, _enemies).is_empty(), "level %d validates: %s" % [number, DataValidator.validate_level(data, _towers, _enemies)])
		check(data.slots.size() >= 6 and data.waves.size() >= 3, "level %d has at least 6 slots and 3 waves" % number)
		check(data.description != "" and data.body_part != "", "level %d has a description and a body part" % number)
		check(ResourceLoader.exists(data.music), "level %d has music" % number)
		music[data.music] = true
		names[data.display_name] = true
		check(data.display_name.length() <= 13, "level %d name fits the top bar" % number)
		for wave in data.waves:
			for entry in wave.entries:
				used_enemies[entry["enemy"]] = true
	check(DataValidator.validate_campaign(levels).is_empty(), "the campaign validates: %s" % [DataValidator.validate_campaign(levels)])
	check(music.size() == 10 and names.size() == 10, "every level has its own name and music")
	check(used_enemies.size() == 13, "all 13 enemies appear somewhere in the campaign")
	for number in [3, 7, 10]:
		check(Session.load_level(number).boss_id != "", "level %d has a boss" % number)
	check(Session.load_level(3).boss_id == "mycobacterium-tuberculosis" and Session.load_level(7).boss_id == "neisseria-meningitidis"
		and Session.load_level(10).boss_id == "hiv", "the bosses are tuberculosis, meningitis and HIV")
	var tower_counts: Array = levels.map(func(d: LevelData) -> int: return d.tower_ids.size())
	check(tower_counts[0] == 3 and tower_counts[9] == 10, "towers are unlocked little by little, ending with all ten")
	check(Session.load_level(1).disabled_traits == ["chain"] and Session.load_level(2).disabled_traits.is_empty(), "the chain trait is off in level 1 only")

	var late: LevelData = Session.load_level(2).duplicate()
	late.boss_id = "hiv"
	check(not DataValidator.validate_campaign([late]).is_empty(), "the campaign validator catches a boss in the wrong level")
	var crowded: LevelData = Session.load_level(2).duplicate()
	crowded.slots = PackedVector2Array([crowded.path_points[1]])
	check(not DataValidator.validate_level(crowded, _towers, _enemies).is_empty(), "the validator catches a slot on the path")
	done("test_campaign_data")


# --- enemy traits -----------------------------------------------------------

func kill(enemy: Enemy) -> void:
	enemy.take_damage(100000.0, "physical")


func test_enemy_traits() -> void:
	var level := campaign_level(2)
	var balance: int = Economy.balance()
	var sars := spawn_at(level, "sars-cov-2", 100.0)
	kill(sars)
	check(level.enemies.size() == 2 and Economy.balance() == balance + 5, "SARS-CoV-2 releases two minions and pays its reward")
	for minion: Enemy in level.enemies:
		check(minion.data.id == "rhinovirus" and minion.is_copy and approx(minion.progress, 100.0, 30.0), "a minion is a small rhinovirus where the virus died")
	free_node(level)

	level = campaign_level(2)
	level._spawn_enemy("streptococcus-pyogenes")
	check(level.enemies.size() == 3, "a strep chain walks as three segments")
	check(level.enemies[0].health == 34.0 and level.enemies[0].reward == 2 and level.enemies[1].progress < level.enemies[0].progress,
		"each segment has a third of the health and reward, and they follow one another")
	balance = Economy.balance()
	for segment in level.enemies.duplicate():
		kill(segment)
	check(Economy.balance() == balance + 6, "killing the whole chain pays the full reward")
	free_node(level)
	level = new_level()
	level._spawn_enemy("streptococcus-pyogenes")
	check(level.enemies.size() == 1 and level.enemies[0].health == 100.0, "level 1 keeps the strep chain turned off")
	free_node(level)

	level = campaign_level(4)
	var herpes := spawn_at(level, "herpes-simplex", 50.0)
	herpes.status.advance(3.0)
	check(herpes.is_dormant() and herpes.take_damage(10.0, "physical") == 0 and herpes.health == 50.0, "dormant herpes ignores attacks")
	herpes.status.advance(1.5)
	check(not herpes.is_dormant() and herpes.take_damage(10.0, "physical") == 10, "herpes can be hurt when it is awake")
	var hpv := spawn_at(level, "hpv", 50.0)
	check(hpv.take_damage(10.0, "physical") == 7, "the HPV shell blocks 30% of physical damage")
	free_node(level)

	level = campaign_level(3)
	var staph := spawn_at(level, "staphylococcus-aureus", 0.0)
	check(staph.take_damage(10.0, "physical") == 10 and staph.resisted_type() == "", "staph takes full damage at first")
	staph.progress = level.curve.get_baked_length() * 0.5
	check(staph.take_damage(10.0, "physical") == 5 and staph.resisted_type() == "physical", "staph resists the damage type that hurt it most")
	check(staph.take_damage(10.0, "chemical") == 15, "staph is not resistant to other types")
	var tb := spawn_at(level, "mycobacterium-tuberculosis", 10.0)
	check(tb.take_damage(12.0, "physical") == 8, "tuberculosis armor takes 30% of a macrophage hit")
	check(tb.take_damage(30.0, "immunological") == 30, "armor does not stop immunological damage")
	free_node(level)

	level = campaign_level(6)
	balance = Economy.balance()
	var spore := spawn_at(level, "clostridioides-difficile", 100.0)
	kill(spore)
	check(not spore.finished and level.enemies.has(spore) and Economy.balance() == balance and spore.is_reviving(),
		"C. difficile lies down instead of dying the first time")
	spore.step(3.0)
	check(not spore.is_reviving() and spore.health == 9.0, "C. difficile comes back once with a fifth of its health")
	kill(spore)
	check(spore.finished and not level.enemies.has(spore) and Economy.balance() == balance + 5, "the second death is final and pays")
	free_node(level)

	level = campaign_level(7)
	balance = Economy.balance()
	var meningitis := spawn_at(level, "neisseria-meningitidis", 200.0)
	meningitis.take_damage(100.0, "physical")
	check(level.enemies.size() == 1 and level.enemies[0] == meningitis, "meningitis holds together above half health")
	meningitis.take_damage(60.0, "physical")
	check(level.enemies.size() == 2 and not level.enemies.has(meningitis), "meningitis splits in two at half health")
	for copy: Enemy in level.enemies:
		check(copy.is_copy and copy.health == 65.0 and copy.reward == 13 and approx(copy.progress, 200.0, 12.0), "a copy has half of what is left")
		copy.take_damage(40.0, "physical")
	check(level.enemies.size() == 2, "a copy does not split again")
	balance = Economy.balance()
	for copy in level.enemies.duplicate():
		kill(copy)
	check(Economy.balance() == balance + 26, "the copies pay the boss reward between them")
	free_node(level)

	level = campaign_level(10)
	Economy.reset(500)
	level.build_tower(0, "macrophage")
	var tower: Tower = level.towers[0]
	var hiv := spawn_at(level, "hiv", level.curve.get_closest_offset(tower.position))
	level.step(3.6)
	check(tower.is_disabled(), "HIV switches off the towers around it")
	hiv.progress = 0.0
	hiv.step(0.0)
	tower._disabled_for = 0.0
	level.step(3.6)
	check(not tower.is_disabled(), "a tower out of the aura keeps working")
	free_node(level)
	done("test_enemy_traits")


# --- the other seven towers -------------------------------------------------

func test_new_towers() -> void:
	var level := campaign_level(6)
	Economy.reset(1000)
	check(level.build_tower(0, "bone-marrow"), "level 6 lets the player build a Bone Marrow")
	level.step(0.1)
	check(level.blockers.size() == 1, "a Bone Marrow sends out its first neutrophil at once")
	var unit := level.blockers[0]
	var rhino := spawn_at(level, "rhinovirus", unit.offset - 10.0)
	var before := rhino.progress
	level.step(1.0)
	check(rhino.progress <= unit.offset + BlockerUnit.REACH and rhino.progress - before < 12.0, "a neutrophil holds the enemy back")
	check(unit.health < unit.max_health and rhino.health < rhino.max_health, "the neutrophil and the enemy hurt each other")
	check(unit.current_animation() == "attack", "the neutrophil plays its attack animation when it hits")
	rhino._on_done.call()  # the hit reaction ends (the tests do not run the animation clock)
	check(rhino.current_animation() == "attack", "an enemy held by a neutrophil plays its attack animation")
	check(unit.guard_radius == 60.0 and unit.speed == 80.0, "the neutrophil gets its radius and speed from the Bone Marrow data")
	var boss := spawn_at(level, "mycobacterium-tuberculosis", unit.offset - 10.0)
	var boss_before := boss.progress
	level.step(1.0)
	check(boss.progress - boss_before > 15.0, "a boss pushes through the blockers")
	for enemy in level.enemies.duplicate():
		enemy.queue_free()
	level.enemies.clear()
	# Only the tower is stepped, so no wave gets in the way of the count.
	for i in 500:
		level.towers[0].step(0.1)
	check(level.blockers.size() == 3, "a Bone Marrow keeps at most three neutrophils")
	var first := level.blockers[0]
	first.health = 0.0
	first.died.emit(first)
	first.queue_free()
	level.blockers.erase(first)
	# Let the dead neutrophil really be freed: a freed object once made the Bone Marrow stop creating for good.
	await get_tree().process_frame
	await get_tree().process_frame
	check(not is_instance_valid(first), "the dead neutrophil has been freed")
	var until_tick: float = level.towers[0]._cooldown
	level.towers[0].step(until_tick - 0.5)
	check(level.blockers.size() == 2, "a dead neutrophil is not replaced before the next 15 s tick")
	level.towers[0].step(1.0)
	check(level.blockers.size() == 3, "a dead neutrophil is replaced at the next 15 s tick")
	free_node(level)

	level = campaign_level(6)
	Economy.reset(1000)
	level.build_tower(0, "bone-marrow")
	level.step(0.1)
	var guard: BlockerUnit = level.blockers[0]
	var post := guard.position
	var wander_low := guard.position
	for i in 120:
		level.step(0.05)
		if guard.position.x < wander_low.x or guard.position.y > wander_low.y:
			wander_low = guard.position
	check(guard.position != post or wander_low != post, "a waiting neutrophil keeps moving around its post")
	check(absf(guard.offset - guard.home_offset) <= BlockerUnit.WANDER + 0.01, "a waiting neutrophil stays close to its post")
	guard.health = 10.0
	guard.step(5.0, [])
	check(is_equal_approx(guard.health, 10.0 + 2.0 * 5.0), "a neutrophil recovers 2 health per second")
	guard.step(60.0, [])
	check(is_equal_approx(guard.health, guard.max_health), "a neutrophil never recovers more than its full health")
	guard.offset = guard.home_offset
	var visitor := spawn_at(level, "rhinovirus", guard.home_offset - 40.0)
	var distance_before := absf(guard.offset - visitor.progress)
	level.step(0.3)
	check(absf(guard.offset - visitor.progress) < distance_before, "a neutrophil walks to an enemy inside its radius")
	var far := spawn_at(level, "rhinovirus", guard.home_offset - 400.0)
	check(guard.target_among([far]) == null, "a neutrophil ignores enemies outside its radius")
	var big := spawn_at(level, "mycobacterium-tuberculosis", guard.home_offset - 30.0)
	check(guard.target_among([big]) == null, "a neutrophil does not go to meet a boss")
	visitor.queue_free()
	level.enemies.erase(visitor)
	big.queue_free()
	level.enemies.erase(big)
	far.queue_free()
	level.enemies.erase(far)
	for i in 80:
		level.step(0.05)
	check(absf(guard.offset - guard.home_offset) <= BlockerUnit.WANDER + 0.01, "a neutrophil walks back to its post when the enemy is gone")
	level.sell_tower(0)
	check(level.blockers.is_empty() or level.blockers.all(func(u: BlockerUnit) -> bool: return u.is_queued_for_deletion()), "selling a Bone Marrow removes its neutrophils")
	free_node(level)

	level = campaign_level(5)
	Economy.reset(1000)
	level.build_tower(0, "b-lymphocyte")
	var slot := level.data.slots[0]
	var offset := level.curve.get_closest_offset(slot)
	var targets: Array[Enemy] = []
	for i in 5:
		targets.append(spawn_at(level, "rhinovirus", offset - 6.0 * i))
	level.step(0.1)
	var marked := targets.filter(func(e: Enemy) -> bool: return e.status.mark_bonus() > 0.0)
	check(marked.size() == 4 and marked.has(targets[0]) and not marked.has(targets[4]), "a B lymphocyte marks the four enemies that are furthest along")
	check(approx(targets[0].status.mark_bonus(), 0.35) and targets[0].health < 20.0, "a mark adds 35% and the antibodies hurt a little")
	free_node(level)

	level = campaign_level(4)
	Economy.reset(1000)
	check(level.build_tower(0, "t-lymphocyte") and level.build_tower(2, "macrophage"), "level 4 offers the T lymphocyte")
	var t_cell: Tower = level.towers[0]
	check(t_cell.data.mobility == "mobile" and level.towers[2].data.mobility == "fixed", "lymphocytes are mobile, macrophages are not")
	check(not level.move_tower(2, 3) and not level.move_tower(0, 2) and not level.move_tower(1, 3), "only a mobile tower can move, and only to an empty slot")
	check(level.move_tower(0, 1) and level.towers.has(1) and not level.towers.has(0) and t_cell.slot_index == 1, "a lymphocyte moves to another slot")
	check(t_cell.position == level.data.slots[1] and t_cell.is_settling(), "it stands on the new slot and needs a moment to settle")
	var victim := spawn_at(level, "hpv", level.curve.get_closest_offset(t_cell.position))
	victim.status.apply_root("test", 30.0, 0.0)
	for i in 10:
		level.step(0.1)
	check(victim.health == 85.0, "a lymphocyte does not attack while it settles")
	for i in 10:
		level.step(0.1)
	check(victim.health == 30.0, "and attacks again afterwards, ignoring armor")
	free_node(level)

	level = campaign_level(2)
	Economy.reset(1000)
	level.build_tower(0, "lysozyme")
	var coli := spawn_at(level, "e-coli", level.curve.get_closest_offset(level.data.slots[0]))
	level.step(0.1)
	check(coli.health == 34.0, "lysozyme hurts bacteria with 1.5 times its chemical damage")
	var virus := spawn_at(level, "influenza", level.curve.get_closest_offset(level.data.slots[0]))
	level.step(1.1)
	check(virus.health == 28.0, "and only half of it against viruses")
	free_node(level)
	# A neutrophil holds one enemy only; the others walk past it without being stopped or hurt.
	level = campaign_level(6)
	Economy.reset(1000)
	level.build_tower(0, "bone-marrow")
	level.step(0.1)
	var lone := level.blockers[0]
	var first_enemy := spawn_at(level, "rhinovirus", lone.offset - 10.0)
	var second_enemy := spawn_at(level, "rhinovirus", lone.offset - 6.0)
	level.step(1.0)
	var holding := [first_enemy, second_enemy].filter(func(e: Enemy) -> bool: return e.held_by() == lone)
	check(holding.size() == 1 and lone.held == holding[0], "a neutrophil holds exactly one enemy")
	var passer: Enemy = second_enemy if holding[0] == first_enemy else first_enemy
	check(passer.held_by() == null and passer.progress > lone.offset, "the other enemy walks past the neutrophil")
	check(passer.health == passer.max_health, "the neutrophil does not hurt the enemy that passes")
	check(holding[0].progress <= lone.offset + BlockerUnit.REACH, "the held enemy is stopped")
	free_node(level)

	# A held enemy that dies is freed; the platelet must let go of it without errors.
	level = level_with_tower("platelet")
	var caught := spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(level.towers[2].holds().size() == 1, "the platelet holds the enemy")
	caught.queue_free()
	level.enemies.erase(caught)
	await get_tree().process_frame
	await get_tree().process_frame
	level.towers[2].step(0.1)
	check(level.towers[2].holds().is_empty(), "the platelet lets go of an enemy that was freed")
	free_node(level)

	done("test_new_towers")


# --- progress and menu ------------------------------------------------------

func with_test_progress(body: Callable) -> void:
	var real_path: String = Session.save_path
	Session.save_path = "user://test_progress.cfg"
	Session.best_health.clear()
	body.call()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.save_path = real_path
	Session.load_progress()


func test_session() -> void:
	with_test_progress(func() -> void:
		check(Session.is_unlocked(1) and not Session.is_unlocked(2), "only level 1 is open at the start")
		check(Session.next_to_play() == 1, "the first level is next at the start")
		Session.record_victory(1, 12)
		check(Session.is_unlocked(2) and not Session.is_unlocked(3), "winning a level opens the next one")
		Session.record_victory(1, 5)
		check(Session.best_health[1] == 12, "the best result is kept")
		check(Session.next_to_play() == 2, "the next level to play follows the last win")
		Session.best_health.clear()
		Session.load_progress()
		check(Session.best_health.get(1, 0) == 12, "progress is saved on the device")
		check(not Session.has_next(10) and Session.has_next(9), "level 10 is the last one")
		Session.reset_progress()
		check(not Session.is_unlocked(2) and Session.best_health.is_empty(), "reset closes the levels again")
		Session.open_all_levels()
		check(Session.is_unlocked(10) and Session.best_health.is_empty(), "opening every level does not change the progress")
		Session.save_progress()
		Session.all_levels_open = false
		Session.load_progress()
		check(not Session.is_unlocked(2), "the open levels are not saved"))
	done("test_session")


## Names of microbes that keep their scientific name in every language.
const UNTRANSLATED := ["Clostridioides difficile", "E. coli", "HIV", "HPV", "Helicobacter pylori", "Mycobacterium tuberculosis",
	"Neisseria meningitidis", "SARS-CoV-2", "Staphylococcus aureus", "Streptococcus pyogenes", "Streptococcus pyogenes segment"]


func test_localization() -> void:
	var file := FileAccess.open("res://localization/translations.csv", FileAccess.READ)
	var header := file.get_csv_line()
	check(header.size() == 1 + Localization.LANGUAGES.size() and header[0] == "keys", "the translation table has one column per language")
	var keys := {}
	var complete := true
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < header.size():
			continue
		keys[row[0]] = true
		for column in row:
			complete = complete and column != ""
	check(complete, "every text has a translation in every language")
	var missing: Array[String] = []
	# every literal passed to tr() in the code
	var pattern := RegEx.create_from_string("tr\\(\"([^\"]+)\"\\)")
	for script_file in DirAccess.get_files_at("res://game"):
		if script_file.ends_with(".gd"):
			for hit in pattern.search_all(FileAccess.get_file_as_string("res://game/" + script_file)):
				if not keys.has(hit.get_string(1)):
					missing.append(hit.get_string(1))
	# the tutorial
	for page in TutorialPages.PAGES:
		for text in [page["title"]] + page["paragraphs"]:
			if not keys.has(text):
				missing.append(text)
	for entry in Changelog.ENTRIES:
		for item: String in entry["items"]:
			if not keys.has(item):
				missing.append(item)
	# the texts stored in data
	for dir in ["enemies", "towers", "levels", "difficulties"]:
		for data_file in DirAccess.get_files_at("res://data/" + dir):
			if not data_file.ends_with(".tres"):
				continue
			var resource := load("res://data/%s/%s" % [dir, data_file])
			for property in ["display_name", "role", "ability_description", "description", "body_part", "type", "mobility", "damage_type"]:
				if property in resource and String(resource.get(property)) != "" and String(resource.get(property)) != "none" \
						and not keys.has(String(resource.get(property))) and not UNTRANSLATED.has(String(resource.get(property))):
					missing.append(String(resource.get(property)))
	check(missing.is_empty(), "every text shown to the player has a translation: %s" % ", ".join(missing))
	TranslationServer.set_locale("pt_BR")
	check(TranslationServer.translate("PLAY") == "JOGAR", "the locale selects the translation")
	TranslationServer.set_locale("ja")
	check(TranslationServer.translate("PLAY") == "プレイ", "Japanese is available")
	TranslationServer.set_locale("en")
	check(TranslationServer.translate("PLAY") == "PLAY", "English keeps the source text")
	check(Localization.from_os() in Localization.codes(), "the phone language maps to a supported one")
	done("test_localization")


## The adaptive icon is masked by the launcher: its picture must stay inside the central circle Android guarantees.
func test_changelog_menu() -> void:
	var save := Session.save_path
	Session.save_path = "user://test_progress.cfg"
	Session.last_seen_version = "0.19.0"
	var menu: Control = load("res://game/menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	check(menu.find_child("Changelog", true, false) != null, "the menu opens the changelog the first time after an update")
	var labels: Array = menu.find_child("ChangelogScroll", true, false).find_children("*", "Label", true, false)
	check(labels.size() > Changelog.ENTRIES.size() * 2, "the changelog lists the versions and their changes")
	check(labels.any(func(label: Label) -> bool: return label.text == "V0.1"), "the changelog lists the oldest version too")
	menu.find_child("ChangelogClose", true, false).pressed.emit()
	await get_tree().process_frame
	check(menu.find_child("Changelog", true, false) == null and not Session.should_show_changelog(), "closing the changelog marks the version as seen")
	menu._open_settings()
	await get_tree().process_frame
	menu.find_child("ChangelogButton", true, false).pressed.emit()
	await get_tree().process_frame
	check(menu.find_child("Changelog", true, false) != null and menu.find_child("Settings", true, false) == null, "the settings open the changelog at any time")
	free_node(menu)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.save_path = save
	Session.load_progress()
	Session.last_seen_version = Session.current_version()
	done("test_changelog_menu")


func test_changelog() -> void:
	check(Changelog.ENTRIES[0]["version"] == Session.current_version(), "the changelog starts with the current version (add an entry for every release)")
	var versions: Array = Changelog.ENTRIES.map(func(entry: Dictionary) -> String: return entry["version"])
	check(versions.size() >= 12 and versions[versions.size() - 1] == "0.1", "the changelog covers every version since 0.1")
	check(versions.size() == Dictionary(versions.reduce(func(seen: Dictionary, v: String) -> Dictionary: seen[v] = true; return seen, {})).size(), "no version is listed twice")
	var save := Session.save_path
	Session.save_path = "user://test_progress.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.load_progress()
	check(not Session.should_show_changelog(), "a fresh install has nothing new to read")
	Session.last_seen_version = "0.19.0"
	Session.save_progress()
	Session.load_progress()
	check(Session.should_show_changelog(), "an update opens the changelog")
	Session.mark_changelog_seen()
	Session.load_progress()
	check(not Session.should_show_changelog(), "the changelog is seen once per version")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.save_path = save
	Session.load_progress()
	done("test_changelog")


func test_icon_safe_zone() -> void:
	var layer := Image.load_from_file(ProjectSettings.globalize_path("res://assets/icon/adaptive_foreground.png"))
	check(layer != null and layer.get_size() == Vector2i(432, 432), "the adaptive icon layer is 432 x 432")
	var centre := Vector2(215.5, 215.5)
	var farthest := 0.0
	for y in layer.get_height():
		for x in layer.get_width():
			if layer.get_pixel(x, y).a > 0.0:
				farthest = maxf(farthest, Vector2(x, y).distance_to(centre))
	check(farthest <= 144.0, "the icon picture stays inside the safe zone (farthest pixel %.0f px of 144)" % farthest)


func test_splash() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://game/splash.tscn", "the game starts on the splash screen")
	check(Splash.SECONDS == 5.0 and ResourceLoader.exists(Splash.LOGO_PATH), "the splash lasts 5 seconds and has the Apolo Software logo")
	var splash: Control = load("res://game/splash.tscn").instantiate()
	get_tree().root.add_child(splash)
	await get_tree().process_frame
	var texts: Array = splash.find_children("*", "Label", true, false).map(func(label: Label) -> String: return label.text)
	check(texts == ["APOLO", "SOFTWARE"], "the splash names the company")
	check(ResourceLoader.exists(GameAudio.config.splash_sound), "the splash has a glint sound")
	GameAudio.reset()
	GameAudio.record = true
	await get_tree().create_timer(Splash.SHINE_AT + 0.3).timeout
	check(GameAudio.play_log.has(GameAudio.config.splash_sound), "the glint rings a sound")
	check(splash.find_child("Sparkle", true, false).scale.x > 0.0, "a star flashes on the logo during the glint")
	GameAudio.record = false
	free_node(splash)
	done("test_splash")


func test_menu_and_results() -> void:
	var real_path: String = Session.save_path
	Session.save_path = "user://test_progress.cfg"
	Session.best_health.clear()
	var menu: Control = load("res://game/menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	var cards := menu.find_children("Level_*", "Button", true, false)
	check(cards.size() == 10, "the menu lists ten levels")
	var first: Button = menu.find_child("Level_1", true, false)
	var second: Button = menu.find_child("Level_2", true, false)
	check(first.modulate.a == 1.0 and second.modulate.a < 1.0, "locked levels look dimmed")
	second.pressed.emit()
	check(menu.find_child("Detail", true, false) == null, "a locked level does not open")
	# The secret tap code: enemy x3, tower x2, enemy x1.
	GameAudio.reset()
	GameAudio.record = true
	for kind in ["enemy", "enemy", "tower", "enemy", "enemy", "tower", "enemy"]:
		menu.tap_hero(kind)
	check(not Session.all_levels_open, "a wrong order of taps opens nothing")
	for kind in ["enemy", "enemy", "enemy", "tower", "tower", "enemy"]:
		menu.tap_hero(kind)
	check(Session.all_levels_open, "enemy three times, tower twice, enemy once opens every level")
	check(GameAudio.play_log == [GameAudio.config.unlock_sound], "the code plays its sound")
	check(ResourceLoader.exists(GameAudio.config.unlock_sound), "the unlock sound exists")
	await get_tree().process_frame
	check(menu.find_child("Level_2", true, false).modulate.a == 1.0, "every level looks open after the code")
	menu.find_child("Level_9", true, false).pressed.emit()
	check(menu.find_child("Detail", true, false) != null, "a level that was locked can be opened after the code")
	menu.call("_close_detail")
	Session.all_levels_open = false
	GameAudio.record = false
	GameAudio.reset()
	Session.progress_changed.emit()
	await get_tree().process_frame
	first = menu.find_child("Level_1", true, false)
	second = menu.find_child("Level_2", true, false)
	check(second.modulate.a < 1.0, "levels close again when the code is gone")
	first.pressed.emit()
	await get_tree().process_frame
	var detail := menu.find_child("Detail", true, false)
	check(detail != null and detail.find_child("PlayButton", true, false) != null, "an open level shows its page with a play button")
	var enemy_button: Button = detail.find_children("Enemy_*", "Button", true, false)[0]
	check(detail.find_child("EnemyCard", true, false) == null, "the enemy card is closed until an enemy is tapped")
	enemy_button.pressed.emit()
	var enemy_card := detail.find_child("EnemyCard", true, false)
	var card_text := ""
	for label: Label in enemy_card.find_children("*", "Label", true, false):
		card_text += label.text + "\n"
	check(enemy_card != null and card_text.contains("HP ") and card_text.contains("VIRUS"), "tapping an enemy on the level page opens its card with type and health")
	detail.find_child("CloseEnemyCard", true, false).pressed.emit()
	await get_tree().process_frame
	check(detail.find_child("EnemyCard", true, false) == null, "the enemy card closes")
	var settings_button: Button = menu.find_child("SettingsButton", true, false)
	check(settings_button != null and menu.find_child("Settings", true, false) == null, "the menu has a settings button")
	settings_button.pressed.emit()
	await get_tree().process_frame
	check(menu.find_child("Settings", true, false) != null and menu.find_children("Difficulty_*", "Button", true, false).size() == 3,
		"settings offer three difficulties")
	menu.find_child("Difficulty_hard", true, false).pressed.emit()
	await get_tree().process_frame
	check(Session.difficulty == "hard" and menu.find_child("Settings", true, false) != null, "tapping a difficulty chooses it")
	menu.find_child("Difficulty_medium", true, false).pressed.emit()
	await get_tree().process_frame
	var music_bar: VolumeBar = menu.find_child("MusicVolume", true, false)
	music_bar.set_from_x(music_bar.size.x * 0.5)
	check(approx(GameAudio.music_volume, 0.5), "the music bar sets the music volume")
	check(approx(GameAudio.sfx_volume, 1.0), "the music bar leaves the effects volume alone")
	music_bar.set_from_x(0.0)
	check(GameAudio.music_volume == 0.0 and GameAudio.music_volume_db() <= 0.0, "the lowest music setting is silent")
	menu.find_child("MuteButton", true, false).pressed.emit()
	await get_tree().process_frame
	check(GameAudio.muted and AudioServer.is_bus_mute(0), "the mute button silences the master bus")
	menu.find_child("MuteButton", true, false).pressed.emit()
	await get_tree().process_frame
	check(not GameAudio.muted and not AudioServer.is_bus_mute(0), "the mute button switches the sound back on")
	GameAudio.set_music_volume(1.0)
	Session.load_progress()
	menu.find_child("BackButton", true, false).pressed.emit()
	await get_tree().process_frame
	menu.find_child("TutorialButton", true, false).pressed.emit()
	await get_tree().process_frame
	check(menu.find_child("Tutorial", true, false) != null and menu.find_child("TutorialTitle", true, false).text == TutorialPages.PAGES[0]["title"], "the tutorial opens on its first page")
	check(menu.find_child("TutorialBack", true, false).disabled, "the first tutorial page has no back")
	menu.find_child("TutorialNext", true, false).pressed.emit()
	await get_tree().process_frame
	check(menu.find_child("TutorialCounter", true, false).text == "2/%d" % TutorialPages.PAGES.size(), "next shows the second page")
	for i in TutorialPages.PAGES.size() - 1:
		menu.find_child("TutorialNext", true, false).pressed.emit()
		await get_tree().process_frame
	check(menu.find_child("Tutorial", true, false) == null, "the last page closes the tutorial")
	var mentions_amino := false
	for page in TutorialPages.PAGES:
		mentions_amino = mentions_amino or " ".join(page["paragraphs"]).contains("Amino acids are the building blocks")
	check(mentions_amino, "the tutorial explains what amino acids are for")
	var scroll_before: int = menu._scroll.scroll_vertical
	menu._input(mouse_button(Vector2(360, 800), true))
	var drag := mouse_motion(Vector2(360, 700), Vector2(0, -100))
	drag.button_mask = MOUSE_BUTTON_MASK_LEFT
	menu._input(drag)
	check(menu._scroll.scroll_vertical == scroll_before + 100, "dragging on a level card scrolls the list")
	menu._on_card_pressed(Session.load_level(1))
	check(menu.find_child("Detail", true, false) == null, "the card under a dragging finger is not opened")
	menu._input(mouse_button(Vector2(360, 700), false))
	menu._input(mouse_button(Vector2(360, 800), true))
	menu._on_card_pressed(Session.load_level(1))
	check(menu.find_child("Detail", true, false) != null, "a plain tap on a card still opens it")
	menu._close_detail()
	var fps_label: FpsCounter = menu.find_child("FpsCounter", true, false)
	Session.all_levels_open = false
	fps_label._process(1.0)
	check(fps_label != null and not fps_label.visible, "the FPS readout is hidden until the secret code is entered")
	Session.all_levels_open = true
	fps_label._process(1.0)
	check(fps_label.visible and fps_label.text.begins_with("FPS "), "the secret code shows the FPS readout")
	Session.all_levels_open = false
	var version_label: Label = menu.find_child("VersionLabel", true, false)
	check(version_label != null and version_label.text == "V%s" % ProjectSettings.get_setting("application/config/version"), "the menu shows the game version")
	var boss_card: Button = menu.find_child("Level_3", true, false)
	check(boss_card.find_children("*", "TextureRect", true, false).size() == 1, "a boss level shows its boss")
	Session.record_victory(1, 10)
	await get_tree().process_frame
	await get_tree().process_frame
	second = menu.find_child("Level_2", true, false)
	check(second.modulate.a == 1.0, "winning level 1 opens the card of level 2")
	get_tree().root.remove_child(menu)
	menu.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.save_path = real_path
	Session.load_progress()

	# build menu with ten towers, mobile tower card and the result buttons
	var level := campaign_level(10)
	Economy.reset(1000)
	var hud := Hud.new(level)
	get_tree().root.add_child(hud)
	await get_tree().process_frame
	level.slot_tapped.emit(0)
	var build_menu := hud.find_child("BuildMenu", true, false)
	var tower_cards := build_menu.find_children("Card_*", "Button", true, false)
	var columns := {}
	for card: Button in tower_cards:
		columns[card.position.x] = true
	check(tower_cards.size() == 10 and columns.size() == 2, "ten towers are shown in two columns")
	var costs_in_order := true
	for i in range(1, tower_cards.size()):
		if level.tower_catalog[tower_cards[i].name.trim_prefix("Card_")].cost < level.tower_catalog[tower_cards[i - 1].name.trim_prefix("Card_")].cost:
			costs_in_order = false
	check(costs_in_order, "the build menu lists the towers from the cheapest to the dearest")
	check(build_menu.size.y < Hud.SCREEN.y - Hud.TOP_BAR_HEIGHT - Hud.BOTTOM_BAR_HEIGHT, "the build menu fits between the bars")
	var lysozyme_card: Button = build_menu.find_child("Card_lysozyme", true, false)
	lysozyme_card.button_down.emit()
	lysozyme_card.find_children("*", "Timer", false, false)[0].timeout.emit()
	var info := hud.find_child("TowerInfo", true, false)
	check(info != null, "holding a build card shows the tower attributes")
	var info_text := hud._tower_info_text(level.tower_catalog["lysozyme"])
	check(info_text.contains("GOOD AGAINST") and info_text.contains("CHEMICAL"), "the tower info says which enemies the tower is good against")
	lysozyme_card.pressed.emit()
	lysozyme_card.button_up.emit()
	await get_tree().process_frame
	check(hud.find_child("TowerInfo", true, false) == null and not level.towers.has(0), "releasing a held card hides the info and does not build")
	hud._dismiss_all()
	level.build_tower(0, "t-lymphocyte")
	level.build_tower(1, "macrophage")
	var held_at := level.world_to_screen(level.data.slots[1])
	hud._on_map_input(mouse_button(held_at, true))
	hud._map_hold.timeout.emit()
	check(hud.find_child("TowerInfo", true, false) != null, "holding a built tower shows its attributes")
	hud._on_map_input(mouse_button(held_at, false))
	check(hud.find_child("TowerInfo", true, false) == null and hud.find_child("TowerCard", true, false) == null, "releasing a held tower hides the info and does not open the sell card")
	level.tower_tapped.emit(0)
	check(hud.find_child("MoveButton", true, false) != null, "a lymphocyte card has a move button")
	hud.find_child("MoveButton", true, false).pressed.emit()
	level.slot_tapped.emit(2)
	check(level.towers.has(2) and not level.towers.has(0), "move, then tap an empty slot, moves the lymphocyte")
	level.tower_tapped.emit(1)
	check(hud.find_child("MoveButton", true, false) == null, "a macrophage card has no move button")
	hud._dismiss_all()
	hud._show_result(true)
	check(hud._overlay.find_children("*", "Button", true, false).size() == 2, "the last level has no next-level button after a win")
	hud._show_result(false)
	check(hud._overlay.find_children("*", "Button", true, false).size() == 2, "a defeat offers retry and menu")
	free_node(hud)
	free_node(level)
	level = campaign_level(3)
	hud = Hud.new(level)
	get_tree().root.add_child(hud)
	await get_tree().process_frame
	hud._show_result(true)
	check(hud._overlay.find_children("*", "Button", true, false).size() == 3, "a win offers next level, restart and menu")
	free_node(hud)
	free_node(level)
	done("test_menu_and_results")


# --- every level can be won, and not without towers -------------------------

func test_campaign_simulation() -> void:
	for number in range(1, 11):
		var level := campaign_level(number)
		var bot := AutoplayBot.new(level)
		run_level(level, bot, 900.0)
		check(level.state == "won" and level.body_health > 0, "the bot wins level %d (state %s, health %d)" % [number, level.state, level.body_health])
		free_node(level)
		level = campaign_level(number)
		run_level(level, null, 900.0)
		check(level.state == "lost", "level %d is lost without towers" % number)
		free_node(level)
	done("test_campaign_simulation")


# --- difficulty and stats ---------------------------------------------------

func test_difficulty() -> void:
	var easy: DifficultyData = Session.load_difficulty("easy")
	var medium: DifficultyData = Session.load_difficulty("medium")
	var hard: DifficultyData = Session.load_difficulty("hard")
	check(easy != null and medium != null and hard != null, "there are three difficulties")
	check(medium.start_amino == 1.0 and medium.body_health == 1.0 and medium.enemy_health == 1.0 and medium.enemy_speed == 1.0
		and medium.reward == 1.0 and medium.wave_time == 1.0, "medium changes nothing")
	check(easy.start_amino > 1.0 and easy.body_health > 1.0 and easy.enemy_health < 1.0 and easy.enemy_speed < 1.0
		and easy.reward > 1.0 and easy.wave_time > 1.0, "easy gives more and asks less")
	check(hard.start_amino < 1.0 and hard.body_health < 1.0 and hard.enemy_health > 1.0 and hard.enemy_speed > 1.0
		and hard.reward < 1.0 and hard.wave_time < 1.0, "hard gives less and asks more")
	check(easy.display_name == "Easy" and medium.display_name == "Medium" and hard.display_name == "Hard", "the three are called Easy, Medium and Hard")

	var base := Level.new(Session.load_level(1))
	get_tree().root.add_child(base)
	check(base.difficulty.id == "medium" and Economy.balance() == 150 and base.max_body_health == 20, "a level without a difficulty plays on medium")
	var rhino_base := spawn_at(base, "rhinovirus", 0.0)
	check(rhino_base.health == 20.0 and rhino_base.reward == 2 and rhino_base.speed == 45.0, "an enemy keeps its roster numbers on medium")
	free_node(base)

	var easy_level := Level.new(Session.load_level(1), easy)
	get_tree().root.add_child(easy_level)
	check(Economy.balance() == roundi(150 * easy.start_amino) and easy_level.max_body_health == roundi(20 * easy.body_health)
		and easy_level.body_health == easy_level.max_body_health, "easy starts with more amino acids and body health")
	var rhino_easy := spawn_at(easy_level, "rhinovirus", 0.0)
	check(rhino_easy.health == ceilf(20.0 * easy.enemy_health) and approx(rhino_easy.speed, 45.0 * easy.enemy_speed)
		and rhino_easy.reward == roundi(2 * easy.reward), "easy enemies are weaker, slower and drop a little more")
	check(approx(easy_level.scheduler.time_to_next_wave(), 5.0 * easy.wave_time), "easy waves start later")
	check(approx(easy_level.scheduler.time_scale, easy.wave_time), "the scheduler knows the wave time")
	free_node(easy_level)

	var hard_level := Level.new(Session.load_level(1), hard)
	get_tree().root.add_child(hard_level)
	check(Economy.balance() == roundi(150 * hard.start_amino) and hard_level.max_body_health == roundi(20 * hard.body_health), "hard starts with less")
	var rhino_hard := spawn_at(hard_level, "rhinovirus", 0.0)
	check(rhino_hard.health == ceilf(20.0 * hard.enemy_health) and approx(rhino_hard.speed, 45.0 * hard.enemy_speed), "hard enemies are tougher and faster")
	check(approx(hard_level.scheduler.time_to_next_wave(), 5.0 * hard.wave_time), "hard waves come sooner")
	free_node(hard_level)

	var hard_boss_level := Level.new(Session.load_level(7), hard)
	get_tree().root.add_child(hard_boss_level)
	var boss := spawn_at(hard_boss_level, "neisseria-meningitidis", 100.0)
	var boss_health := boss.health
	boss.take_damage(boss_health * 0.55, "immunological")
	check(hard_boss_level.enemies.size() == 2, "a boss still splits on hard")
	for copy: Enemy in hard_boss_level.enemies:
		check(absf(copy.health - ceilf((boss_health - ceilf(boss_health * 0.55)) / 2.0)) <= 1.0, "the copies of a split are not scaled twice")
	free_node(hard_boss_level)

	var real_path: String = Session.save_path
	Session.save_path = "user://test_progress.cfg"
	Session.best_health.clear()
	Session.set_difficulty("hard")
	Session.set_difficulty("nonsense")
	check(Session.difficulty == "hard" and Session.difficulty_data().id == "hard", "the difficulty is set, and a wrong name is ignored")
	Session.difficulty = "medium"
	Session.load_progress()
	check(Session.difficulty == "hard", "the difficulty is saved on the device")
	Session.reset_progress()
	check(Session.difficulty == "hard", "starting over keeps the difficulty")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_progress.cfg"))
	Session.save_path = real_path
	Session.load_progress()
	done("test_difficulty")


func test_stats() -> void:
	var level := new_level()
	Economy.reset(500)
	level.build_tower(2, "macrophage")
	var target := spawn_at(level, "rhinovirus", 850.0)
	level.step(0.05)
	check(level.stats.damage_by_source.get("macrophage", 0.0) == 14.0 or level.stats.damage_by_source.get("macrophage", 0.0) == 20.0,
		"the stats count the damage of a tower, without the overkill")
	level.step(1.05)
	check(level.stats.kills.get("rhinovirus", 0) == 1 and level.stats.kills_by_source.get("macrophage", 0) == 1, "the stats count the kill and who made it")
	check(level.stats.towers_built.get("macrophage", 0) == 1 and level.stats.amino_spent == 50, "the stats count what was built and spent")
	var runner := spawn_at(level, "influenza", level.curve.get_baked_length() - 1.0)
	level.step(0.1)
	check(level.stats.leaks.get("influenza", 0) == 1 and level.stats.first_leak_time > 0.0, "the stats count a leak and when it happened")
	check(target.finished and runner.finished, "both enemies are done")
	free_node(level)
	done("test_stats")
