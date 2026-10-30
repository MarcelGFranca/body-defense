## The first screen: the Apolo Software logo, shown for 5 seconds before the menu.
## `-- --autoplay` skips it so the bots reach a level straight away.
class_name Splash
extends Control

const SCREEN := Vector2(720, 1280)
const SECONDS := 5.0
const FADE_IN := 1.0
const FADE_OUT := 0.8
const LOGO_PATH := "res://assets/ui/apolo_logo.png"
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const COLOR_BG := Color("1a0f24")
const COLOR_GOLD := Color("f4d35e")
const COLOR_DIM := Color("9b8aa6")

var _content: Control


func _ready() -> void:
	if "--autoplay" in OS.get_cmdline_user_args():
		call_deferred("_go_to_menu")
		return
	var backdrop := ColorRect.new()
	backdrop.color = COLOR_BG
	backdrop.size = SCREEN
	add_child(backdrop)
	_content = Control.new()
	_content.size = SCREEN
	_content.modulate.a = 0.0
	add_child(_content)
	var logo := TextureRect.new()
	logo.texture = load(LOGO_PATH)
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.size = Vector2(320, 320)
	logo.position = Vector2(200, 400)
	_content.add_child(logo)
	var font: Font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else null
	_content.add_child(_label("APOLO", 56, COLOR_GOLD, 740.0, font))
	_content.add_child(_label("SOFTWARE", 32, COLOR_DIM, 820.0, font))
	var tween := create_tween()
	tween.tween_property(_content, "modulate:a", 1.0, FADE_IN)
	tween.tween_interval(SECONDS - FADE_IN - FADE_OUT)
	tween.tween_property(_content, "modulate:a", 0.0, FADE_OUT)
	tween.tween_callback(_go_to_menu)


func _label(text: String, font_size: int, color: Color, y: float, font: Font) -> Label:
	var label := Label.new()
	label.text = text
	if font != null:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(0, y)
	label.size = Vector2(SCREEN.x, font_size + 8.0)
	return label


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(Session.MENU_SCENE)
