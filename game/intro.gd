## The story of a level in pixel art, played before the level starts (level 1: a sneeze in the street, the zoom
## into the throat and the invaders coming in). Drawn in a 180 x 320 grid scaled 4x. Driven by `step(delta)`, so tests can run it.
## SKIP (bottom) ends it at once. `finished` is emitted when it ends or is skipped.
class_name LevelIntro
extends Control

signal finished

const SCREEN := Vector2(720, 1280)
const U := 4.0
const DURATION := 11.4
## Cue times in seconds: the wind-up of the sneeze, the sneeze, the aftermath, the zoom and the throat.
const T_WIND := 3.6
const T_CHOO := 4.8
const T_AFTER := 5.7
const T_ZOOM := 6.3
const T_THROAT := 7.2
const SOUND := "res://assets/audio/common/intro_level1.wav"
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const INVADERS := ["rhinovirus", "streptococcus-pyogenes", "influenza", "staphylococcus-aureus", "rhinovirus", "sars-cov-2", "streptococcus-pyogenes", "rhinovirus"]
const WORDS := ["BLA BLA", "BLAH..", "YADA", "HMM..", "BLA!", "..."]
const VOWELS := 5

var clock := 0.0
var done := false
var _font: Font
var _talk := {"A": [], "B": []}
var _drops: Array[Dictionary] = []
var _cap := {"on": false, "done": false, "x": 0.0, "y": 0.0, "vx": 0.0, "vy": 0.0, "r": 0.0}
var _spawn_rest := 0.0
var _rng := RandomNumberGenerator.new()
var _textures: Dictionary = {}
var _player: AudioStreamPlayer
var _skip: Button
var _xf := Transform2D.IDENTITY


func _ready() -> void:
	_rng.seed = 11
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	_talk["A"] = _syllables(0.3, 1.7, 1)
	_talk["B"] = _syllables(1.9, 3.5, 100)
	for id: String in INVADERS:
		if not _textures.has(id):
			_textures[id] = load("res://assets/enemies/%s/%s_sprite.png" % [id, id])
	_player = AudioStreamPlayer.new()
	_player.stream = load(SOUND)
	_player.volume_db = GameAudio.sfx_volume_db()
	add_child(_player)
	_player.play()
	_skip = Button.new()
	_skip.name = "SkipButton"
	_skip.text = "SKIP"
	_skip.focus_mode = Control.FOCUS_NONE
	_skip.size = Vector2(220, 68)
	_skip.position = Vector2((SCREEN.x - _skip.size.x) / 2.0, 1170.0)
	if _font != null:
		_skip.add_theme_font_override("font", _font)
	_skip.add_theme_font_size_override("font_size", 22)
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.06, 0.14, 0.85) if state != "pressed" else Color("4a2f66")
		style.set_border_width_all(4)
		style.border_color = Color("ffb3c7")
		_skip.add_theme_stylebox_override(state, style)
	_skip.pressed.connect(skip)
	add_child(_skip)
	if get_tree().current_scene == self:
		finished.connect(func() -> void: get_tree().change_scene_to_file(Session.LEVEL_SCENE))


func _process(delta: float) -> void:
	step(delta)


## Moves the story forward; at the end it finishes by itself.
func step(delta: float) -> void:
	if done:
		return
	clock += delta
	_spray_step(delta)
	_cap_step(delta)
	queue_redraw()
	if clock >= DURATION + 0.2:
		_finish()


func skip() -> void:
	_finish()


func _finish() -> void:
	if done:
		return
	done = true
	if _player != null:
		_player.stop()
	finished.emit()


# --- shared timing ------------------------------------------------------------------------------

static func _rnd(i: float) -> float:
	return fposmod(sin(i * 127.1 + 311.7) * 43758.5453, 1.0)


## Talking syllables [start, length, variety] between two times: the same list drives the mouths and the sound generator.
static func _syllables(from: float, to: float, seed_value: int) -> Array:
	var list: Array = []
	var t := from
	var i := float(seed_value)
	while t < to - 0.12:
		var d := 0.09 + _rnd(i) * 0.07
		i += 1.0
		var variety := _rnd(i)
		i += 1.0
		list.append([t, d, variety])
		t += d + 0.04 + _rnd(i) * 0.12
		i += 1.0
	return list


## How wide the mouth is open (0 closed) while `who` is saying a syllable.
func talking(who: String, t: float) -> float:
	for s: Array in _talk[who]:
		if t >= float(s[0]) and t < float(s[0]) + float(s[1]):
			return 0.4 + float(s[2]) * 0.6
	return 0.0


# --- particles ----------------------------------------------------------------------------------

func _spray_step(delta: float) -> void:
	if clock >= T_CHOO and clock < T_CHOO + 0.35:
		_spawn_rest += 540.0 * delta
		while _spawn_rest >= 1.0:
			_spawn_rest -= 1.0
			_drops.append({
				"x": 116.0, "y": 216.0 + _rng.randf() * 10.0,
				"vx": -(90.0 + _rng.randf() * 190.0), "vy": -60.0 + _rng.randf() * 120.0,
				"s": 2.0 + _rng.randf() * 4.0, "c": Color.WHITE if _rng.randf() < 0.5 else Color("dff7c8")})
	for d in _drops:
		d["x"] = float(d["x"]) + float(d["vx"]) * delta
		d["y"] = float(d["y"]) + float(d["vy"]) * delta
		d["vy"] = float(d["vy"]) + 40.0 * 60.0 * delta
		d["vx"] = float(d["vx"]) * pow(0.985, 60.0 * delta)


func _cap_step(delta: float) -> void:
	if clock >= T_CHOO and not bool(_cap["done"]):
		_cap = {"on": true, "done": true, "x": 128.0, "y": 164.0, "vx": 30.0, "vy": -190.0, "r": 0.0}
	if bool(_cap["on"]):
		_cap["x"] = float(_cap["x"]) + float(_cap["vx"]) * delta
		_cap["y"] = float(_cap["y"]) + float(_cap["vy"]) * delta
		_cap["vy"] = float(_cap["vy"]) + 420.0 * delta
		_cap["r"] = float(_cap["r"]) + 12.0 * delta


# --- drawing helpers ----------------------------------------------------------------------------

func _use(xform: Transform2D) -> void:
	draw_set_transform_matrix(_xf * Transform2D(0.0, Vector2(U, U), 0.0, Vector2.ZERO) * xform)


func _r(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(roundf(x), roundf(y), w, h), color)


func _text(text: String, at: Vector2, size: float, color: Color, centered := false) -> void:
	if _font == null:
		return
	draw_set_transform_matrix(_xf)
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * U)).x
	var origin := at * U
	if centered:
		origin.x -= width / 2.0
	draw_string(_font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * U), color)


func _draw() -> void:
	var t := clock
	_xf = Transform2D.IDENTITY
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color.BLACK)
	if t < T_ZOOM:
		var shake := Vector2.ZERO
		if t >= T_CHOO and t < T_CHOO + 0.6:
			shake = Vector2(_rng.randf() - 0.5, _rng.randf() - 0.5) * 7.0 * U
		_xf = Transform2D(0.0, Vector2.ONE, 0.0, shake)
		_street(t)
		_spray(t)
		_xf = Transform2D.IDENTITY
		if t >= T_CHOO and t < T_CHOO + 0.08:
			draw_set_transform_matrix(Transform2D.IDENTITY)
			draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(1, 1, 1, 0.85))
	elif t < T_THROAT:
		var k := (t - T_ZOOM) / (T_THROAT - T_ZOOM)
		var e := k * k * (3.0 - 2.0 * k)
		var s := 1.0 + e * 22.0
		var p := Vector2(72.0, 218.0) * U
		_xf = Transform2D(0.0, Vector2(s, s), 0.0, p - p * s)
		_street(T_AFTER)
		_xf = Transform2D.IDENTITY
		_cover(Color(0.30, 0.08, 0.14, maxf(0.0, (k - 0.5) / 0.5)))
	else:
		_throat(t - T_THROAT)
		var k := minf(1.0, (t - T_THROAT) / 0.4)
		if k < 1.0:
			_cover(Color(0.30, 0.08, 0.14, 1.0 - k))
	# cinematic bars and captions
	_use(Transform2D.IDENTITY)
	_r(0, 0, 180, 14, Color.BLACK)
	_r(0, 306, 180, 14, Color.BLACK)
	if t < 2.2:
		_text("A NORMAL DAY...", Vector2(34, 24), 7.0, Color.WHITE)
	if t >= T_THROAT + 3.4:
		var message := "THE THROAT"
		var n := mini(message.length(), int((t - T_THROAT - 3.4) * 14.0))
		_text(message.substr(0, n), Vector2(33, 297), 12.0, Color("1a1020"))
		_text(message.substr(0, n), Vector2(32, 296), 12.0, Color("f4d35e"))
	if t >= T_THROAT + 3.9:
		_text("THEY ARE COMING IN", Vector2(40, 274), 6.0, Color("ffb3c7"))
	if t > 10.6:
		_cover(Color(0, 0, 0, minf(1.0, (t - 10.6) / 0.8)))


func _cover(color: Color) -> void:
	draw_set_transform_matrix(Transform2D.IDENTITY)
	draw_rect(Rect2(Vector2.ZERO, SCREEN), color)


# --- the street ---------------------------------------------------------------------------------

func _backdrop(t: float) -> void:
	_use(Transform2D.IDENTITY)
	var bands := ["6fb7e8", "80c2ec", "92cdf0", "a5d7f3", "b8e1f6", "cbebf9"]
	for i in bands.size():
		_r(0, i * 30, 180, 30, Color(bands[i]))
	for i in 3:
		var cx := fposmod(i * 80.0 + t * 3.0, 230.0) - 30.0
		var cy := 30.0 + i * 34.0
		_r(cx, cy, 26, 6, Color.WHITE)
		_r(cx + 4, cy - 4, 16, 4, Color.WHITE)
	var colors := ["8a7fa0", "9a8fb0", "7d7396"]
	for i in 9:
		var h := 60.0 + _rnd(i) * 50.0
		_r(i * 21 - 6, 240 - h, 22, h + 80, Color(colors[i % 3]))
		var wy := 0.0
		while wy < h - 8.0:
			var wx := 3.0
			while wx < 18.0:
				_r(i * 21 - 6 + wx, 240 - h + 6 + wy, 3, 4, Color("d9cf9a"))
				wx += 7.0
			wy += 10.0
	_r(0, 260, 180, 60, Color("6aa84f"))


func _street(t: float) -> void:
	_backdrop(t)
	var a := {"shirt": Color("e84a5f"), "hair": Color("4a2b1a")}
	var b := {"shirt": Color("4aa3e8"), "hair": Color("e8c84a"), "cap": true}
	var ma := talking("A", t)
	var mb := talking("B", t)
	a["mouth"] = ma
	b["mouth"] = mb
	a["rot"] = sin(t * 14.0) * 0.05 if ma > 0.0 else 0.0
	b["rot"] = sin(t * 14.0) * 0.05 if mb > 0.0 else 0.0
	if t >= T_WIND and t < T_CHOO:
		var k := (t - T_WIND) / (T_CHOO - T_WIND)
		b["rot"] = -0.15 - k * 0.5
		b["hy"] = -k * 2.0
		b["squeeze"] = k > 0.2
		b["flare"] = roundi(k * 3.0)
		b["red"] = k > 0.5
		b["mouth"] = 0.5 + k * 1.2
		b["shake"] = k * 1.8
		b["lean"] = k * 3.0
		a["rot"] = -0.05
		a["lean"] = -k * 3.0
		a["sweat"] = true
		a["mouth"] = 0.0
	if t >= T_CHOO and t < T_AFTER:
		var k := (t - T_CHOO) / (T_AFTER - T_CHOO)
		b["rot"] = 0.35
		b["mouth"] = 3.0
		b["squeeze"] = true
		b["red"] = true
		b["shake"] = 2.5 * (1.0 - k)
		b["lean"] = -6.0 * (1.0 - k)
		b["hy"] = 4.0
		a["rot"] = -0.4 * (1.0 - k * 0.3)
		a["blow"] = 1.0
		a["bulge"] = true
		a["mouth"] = 2.0
		a["lean"] = -6.0
		a["shake"] = 2.0 * (1.0 - k)
	if t >= T_AFTER:
		b["mouth"] = 0.5
		b["red"] = true
		a["bulge"] = true
		a["mouth"] = 2.2
		a["rot"] = -0.1
		a["blow"] = 0.4
	_bust(52.0, 306.0, 1.0, a, t)
	_bust(128.0, 306.0, -1.0, b, t)
	if bool(_cap["on"]):
		_use(Transform2D(float(_cap["r"]), Vector2.ONE, 0.0, Vector2(float(_cap["x"]), float(_cap["y"]))))
		_r(-17, -3, 34, 6, Color("e84a4a"))
		_r(8, 0, 22, 3, Color("b83030"))
	if t < T_WIND:
		if ma > 0.0:
			_bubble(48.0, 128.0, WORDS[int(t * 2.2) % WORDS.size()])
		if mb > 0.0:
			_bubble(132.0, 128.0, WORDS[(int(t * 2.2) + 3) % WORDS.size()])
	if t >= T_WIND and t < T_CHOO:
		var k := (t - T_WIND) / (T_CHOO - T_WIND)
		var stage := mini(2, int(k * 3.0))
		var text: String = ["AH...", "AHH...", "AAAHHH..."][stage]
		var scale := 1.0 + stage * 0.25
		_text(text, Vector2(112.0, 100.0 - stage * 2.0 + sin(t * 40.0) * 1.5), 8.0 * scale, Color.WHITE, true)


func _bubble(cx: float, cy: float, text: String) -> void:
	_use(Transform2D.IDENTITY)
	var w := text.length() * 6.0 + 8.0
	_r(cx - w / 2.0, cy, w, 12, Color.WHITE)
	_r(cx - w / 2.0 + 1, cy - 1, w - 2, 14, Color.WHITE)
	_r(cx - 2, cy + 13, 5, 3, Color.WHITE)
	_text(text, Vector2(cx - w / 2.0 + 4.0, cy + 9.0), 6.0, Color("333333"))


## A person from the belly up, seen from the side (face 1 looks right, -1 left). `o` holds the pose.
func _bust(cx: float, by: float, face: float, o: Dictionary, t: float) -> void:
	var skin := Color("e8806a") if o.get("red", false) else Color("f0c8a0")
	var shirt: Color = o["shirt"]
	var hair: Color = o["hair"]
	var shake := sin(t * 45.0) * float(o.get("shake", 0.0))
	var base := Transform2D(0.0, Vector2.ONE, 0.0, Vector2(cx + shake + float(o.get("lean", 0.0)), 0.0))
	_use(base)
	_r(-28, by - 72, 56, 80, shirt)
	_r(-28, by - 72, 56, 4, Color(1, 1, 1, 0.22))
	_r(-31, by - 66, 6, 60, shirt)
	_r(25, by - 66, 6, 60, shirt)
	_r(-6, by - 74, 12, 6, Color.WHITE)
	_r(-5, by - 84, 10, 13, skin)
	_r(-5, by - 76, 10, 3, Color(0, 0, 0, 0.12))
	_use(base * Transform2D(float(o.get("rot", 0.0)) * face, Vector2.ONE, 0.0, Vector2(0.0, by - 82.0)))
	var hy := -30.0 + float(o.get("hy", 0.0))
	_r(-15, hy, 30, 30, skin)
	if o.get("red", false):
		_r(-15, hy + 14, 30, 10, Color("f06a5a"))
	_r(-face * 15.0 - (3.0 if face > 0.0 else 0.0), hy + 12, 3, 7, skin)
	var blow := float(o.get("blow", 0.0))
	_r(-16, hy - 4, 32, 9, hair)
	_r(-face * 16.0, hy, 4, 14, hair)
	_r(-face * 16.0 - face * blow * 10.0, hy + 2, 4 + blow * 10.0, 6, hair)
	for i in int(blow * 3.0):
		_r(-face * 18.0 - face * i * 5.0, hy - 2 + i * 3, 6, 3, hair)
	var flare := float(o.get("flare", 0.0))
	var nose_x := face * 15.0 - (5.0 + flare if face < 0.0 else 0.0)
	_r(nose_x, hy + 13, 5 + flare, 6 + flare, skin)
	_r(nose_x, hy + 17 + flare, 5 + flare, 1, Color(0, 0, 0, 0.25))
	var ex := face * 7.0 - (5.0 if face < 0.0 else 0.0)
	if o.get("squeeze", false):
		_r(ex - 1, hy + 11, 7, 2, Color("222222"))
		_r(ex - 1, hy + 7, 8, 2, hair)
	elif o.get("bulge", false):
		_r(ex - 1, hy + 7, 8, 10, Color.WHITE)
		_r(ex + (3.0 if face > 0.0 else 1.0), hy + 10, 3, 5, Color("222222"))
		_r(ex - 1, hy + 4, 8, 2, hair)
	else:
		_r(ex, hy + 9, 5, 6, Color.WHITE)
		_r(ex + (2.0 if face > 0.0 else 0.0), hy + 10, 3, 4, Color("222222"))
		_r(ex - 1, hy + 6, 7, 2, hair)
	var m := float(o.get("mouth", 0.0))
	var mx := face * 5.0 - (10.0 if face < 0.0 else 0.0) + face
	if m > 1.0:
		var h := 8.0 + roundf(m * 5.0)
		_r(mx - 1, hy + 20, 12, h, Color("7a1f2b"))
		_r(mx + 1, hy + 20, 8, 3, Color.WHITE)
		_r(mx + 2, hy + 20 + h - 4, 7, 4, Color("e8546a"))
	elif m > 0.0:
		_r(mx, hy + 21, 9, 2 + roundf(m * 5.0), Color("7a1f2b"))
	else:
		_r(mx, hy + 22, 8, 2, Color("9a5a4a"))
	if o.get("cap", false) and not bool(_cap["on"]):
		_r(-17, hy - 8, 34, 6, Color("e84a4a"))
		_r(4.0 if face > 0.0 else -26.0, hy - 3, 24, 3, Color("b83030"))
	if o.get("sweat", false):
		_r(face * -12.0, hy - 6 + (int(t * 8.0) % 4) * 2, 3, 5, Color("8fd3ff"))


func _spray(t: float) -> void:
	if t < T_CHOO or t > T_ZOOM:
		return
	var k := t - T_CHOO
	_use(Transform2D.IDENTITY)
	for d in _drops:
		_r(float(d["x"]), float(d["y"]), float(d["s"]), float(d["s"]), d["c"])
		_r(float(d["x"]) + 1, float(d["y"]) + 1, 1, 1, Color(0.6, 0.86, 1.0, 0.9))
	var radius := minf(1.0, k / 0.5) * 46.0
	for i in 10:
		var ang := i * 0.62
		var tint := Color(1, 1, 1, 0.7) if i % 2 == 1 else Color(0.87, 0.97, 0.78, 0.65)
		_r(114.0 - cos(ang * 0.8) * radius * 1.2 - 6.0, 216.0 + sin(ang) * radius * 0.5 - 6.0, 12 + (i % 3) * 4, 10 + (i % 2) * 4, tint)
	for i in 8:
		_r(112.0 - cos(-0.5 + i * 0.14) * (14.0 + k * 140.0), 216.0 + sin(-0.5 + i * 0.14) * (10.0 + k * 50.0), 10, 2, Color.WHITE)
	if k < 0.9:
		var grow := 1.0 + minf(1.0, k * 5.0) * 0.8
		var jitter := Vector2(_rng.randf() - 0.5, _rng.randf() - 0.5) * 4.0
		for layer in [[Vector2(2, 2), Color("7a1f2b")], [Vector2.ZERO, Color("ffe14a")], [Vector2(-1, -1), Color("e84a5f")]]:
			_text("ACHOOO!", Vector2(90.0, 92.0) + jitter + (layer[0] as Vector2), 14.0 * grow, layer[1], true)
	if t > T_CHOO + 0.4:
		for i in 8:
			_r(48.0 + _rnd(i) * 26.0, 176.0 + _rnd(i + 9.0) * 30.0 + (t - T_CHOO) * (2.0 + _rnd(i) * 3.0), 3, 3.0 + _rnd(i + 3.0) * 3.0, Color(0.87, 0.97, 0.78, 0.85))


# --- inside the throat --------------------------------------------------------------------------

func _throat(t: float) -> void:
	_use(Transform2D.IDENTITY)
	_r(0, 0, 180, 320, Color("4d1523"))
	for i in 130:
		var sx := _rnd(i) * 180.0
		var sy := fposmod(_rnd(i + 90.0) * 320.0 + t * 12.0 * (0.3 + _rnd(i + 5.0)), 320.0)
		_r(sx, sy, 2, 2, Color("6a1d30") if i % 3 != 0 else Color("7d2539"))
	var beat := pow(maxf(0.0, sin(t * 2.4)), 4.0) * 3.0
	var y := 0
	while y < 320:
		var wob := sin(y * 0.09 + t * 1.5) * 3.0
		var lw := 22.0 + wob + beat
		var rw := 22.0 - wob + beat
		_r(0, y, lw, 2, Color("c4586f"))
		_r(lw - 3, y, 3, 2, Color("e48a9c"))
		_r(lw - 8, y, 5, 2, Color("a63e56"))
		_r(180 - rw, y, rw, 2, Color("c4586f"))
		_r(180 - rw, y, 3, 2, Color("e48a9c"))
		_r(180 - rw + 3, y, 5, 2, Color("a63e56"))
		y += 2
	for i in 30:
		_r(0, 290 + i, 180, 1, Color(0.08, 0.02, 0.05, i / 45.0))
	for i in 5:
		var mx := 44.0 + i * 22.0
		var my := fposmod(_rnd(i + 40.0) * 320.0 + t * 18.0, 340.0) - 10.0
		_r(mx, my, 2, 6, Color(1, 0.78, 0.84, 0.55))
		_r(mx - 1, my + 6, 4, 3, Color(1, 0.78, 0.84, 0.55))
	for i in INVADERS.size():
		var k := t - (0.6 + i * 0.42)
		if k < 0.0:
			continue
		var px := 44.0 + float((i * 37) % 80) + sin(k * 2.0 + i) * 6.0
		var py := -40.0 + k * 58.0
		if py > 330.0:
			continue
		var squash := 1.0 + sin(k * 8.0 + i) * 0.07
		_use(Transform2D(0.0, Vector2(squash, 1.0 / squash), 0.0, Vector2(px + 16.0, py + 16.0)))
		draw_texture_rect(_textures[INVADERS[i]], Rect2(-16, -16, 32, 32), false)
