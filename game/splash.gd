## The first screen: the Apolo Software logo, shown for 5 seconds before the menu.
## `-- --autoplay` skips it so the bots reach a level straight away.
class_name Splash
extends Control

const SCREEN := Vector2(720, 1280)
const SECONDS := 5.0
const FADE_IN := 1.0
const FADE_OUT := 0.8
const SHINE_SHADER := "res://assets/shaders/shine.gdshader"
## When the glint starts, in seconds after the splash opens (the logo has faded in by then).
const SHINE_AT := 1.3
const SHINE_SECONDS := 0.9
## Where the spark flies off: the bright spot inside the globe of the logo.
const GLINT_AT := Vector2(332.0, 526.0)
const LOGO_PATH := "res://assets/ui/apolo_logo.png"
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const COLOR_BG := Color("1a0f24")
const COLOR_GOLD := Color("f4d35e")
const COLOR_DIM := Color("9b8aa6")

var _content: Control
var _sparkle: Control
var _sparks: CPUParticles2D


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
	var shine := ShaderMaterial.new()
	shine.shader = load(SHINE_SHADER)
	logo.material = shine
	_sparkle = Control.new()
	_sparkle.name = "Sparkle"
	_sparkle.position = GLINT_AT
	_sparkle.scale = Vector2.ZERO
	_sparkle.draw.connect(_draw_sparkle)
	_content.add_child(_sparkle)
	_sparks = CPUParticles2D.new()
	_sparks.position = GLINT_AT
	_sparks.emitting = false
	_sparks.one_shot = true
	_sparks.explosiveness = 0.9
	_sparks.amount = 16
	_sparks.lifetime = 0.8
	_sparks.direction = Vector2(-0.6, -1.0)
	_sparks.spread = 80.0
	_sparks.initial_velocity_min = 90.0
	_sparks.initial_velocity_max = 220.0
	_sparks.gravity = Vector2(0.0, 160.0)
	_sparks.scale_amount_min = 3.0
	_sparks.scale_amount_max = 6.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 1.0, 0.85, 1.0))
	fade.set_color(1, Color(1.0, 0.7, 0.2, 0.0))
	_sparks.color_ramp = fade
	_content.add_child(_sparks)
	var font: Font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else null
	_content.add_child(_label("APOLO", 56, COLOR_GOLD, 740.0, font))
	_content.add_child(_label("SOFTWARE", 32, COLOR_DIM, 820.0, font))
	var glint := create_tween()
	glint.tween_interval(SHINE_AT)
	glint.tween_callback(_start_glint.bind(shine))
	var tween := create_tween()
	tween.tween_property(_content, "modulate:a", 1.0, FADE_IN)
	tween.tween_interval(SECONDS - FADE_IN - FADE_OUT)
	tween.tween_property(_content, "modulate:a", 0.0, FADE_OUT)
	tween.tween_callback(_go_to_menu)


## The logo glints: a band of light sweeps over the globe, a star flashes inside it and throws sparks, and a chime rings.
func _start_glint(shine: ShaderMaterial) -> void:
	GameAudio.play_sfx(GameAudio.config.splash_sound)
	_sparks.emitting = true
	var sweep := create_tween()
	sweep.tween_method(func(value: float) -> void: shine.set_shader_parameter("progress", value), -0.4, 1.4, SHINE_SECONDS)
	var star := create_tween().set_parallel()
	star.tween_property(_sparkle, "scale", Vector2.ONE, SHINE_SECONDS * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	star.tween_property(_sparkle, "rotation", 0.8, SHINE_SECONDS * 1.4)
	star.chain().tween_property(_sparkle, "scale", Vector2.ZERO, SHINE_SECONDS * 0.6)


## A four-pointed star: two thin diamonds crossed, with a bright centre.
func _draw_sparkle() -> void:
	var long := 44.0
	var thin := 7.0
	var white := Color(1, 1, 0.9)
	_sparkle.draw_colored_polygon(PackedVector2Array([Vector2(0, -long), Vector2(thin, 0), Vector2(0, long), Vector2(-thin, 0)]), white)
	_sparkle.draw_colored_polygon(PackedVector2Array([Vector2(-long, 0), Vector2(0, thin), Vector2(long, 0), Vector2(0, -thin)]), white)
	_sparkle.draw_circle(Vector2.ZERO, 9.0, Color(1, 1, 1, 0.9))


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
