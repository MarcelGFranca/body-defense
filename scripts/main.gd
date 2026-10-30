## Entry scene: creates the level and its HUD. `-- --autoplay` runs a bot that plays the level.
extends Node

var level: Level
var hud: Hud


func _ready() -> void:
	level = Level.new()
	add_child(level)
	hud = Hud.new(level)
	add_child(hud)
	if "--autoplay" in OS.get_cmdline_user_args():
		var bot := AutoplayBot.new(level, "--call-waves" in OS.get_cmdline_user_args())
		add_child(bot)
