## Entry scene of a level: creates the level and its HUD. `-- --autoplay [--level N]` runs a bot that plays it.
extends Node

var level: Level
var hud: Hud


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--level" in args:
		var at := args.find("--level")
		if at + 1 < args.size():
			Session.current_level = int(args[at + 1])
	if "--difficulty" in args and args.find("--difficulty") + 1 < args.size():
		Session.difficulty = args[args.find("--difficulty") + 1]
	level = Level.new(Session.load_level(Session.current_level), Session.difficulty_data())
	add_child(level)
	level.victory.connect(func() -> void: Session.record_victory(level.data.number, level.body_health))
	hud = Hud.new(level)
	add_child(hud)
	if "--autoplay" in args:
		var bot := AutoplayBot.new(level, "--call-waves" in args)
		add_child(bot)
