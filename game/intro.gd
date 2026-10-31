## The story of a level in pixel art, played before the level starts (a scene about how the germs got in, the zoom into
## the organ and the invaders coming in), and the ending after the last boss (story 11). Drawn in a 180 x 320 grid scaled 4x.
## Level 1 is drawn here; the other stories are in `IntroStories`. Driven by `step(delta)`, so tests can run it.
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
const ENDING := 11
## Per story: zoom start and organ start (seconds), length, zoom point and strength, caption, title, invaders, organ, boss, sound.
const STORIES := {
	1: {"tz": 6.3, "tt": 7.2, "dur": 11.4, "zoom": Vector2(72, 218), "scale": 22.0, "cap": "A NORMAL DAY...", "title": "THE THROAT",
		"inv": ["rhinovirus", "streptococcus-pyogenes", "influenza", "staphylococcus-aureus", "rhinovirus", "sars-cov-2", "streptococcus-pyogenes", "rhinovirus"],
		"organ": "throat", "sound": "intro_level1"},
	2: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(96, 214), "cap": "A BREATH TOO DEEP...", "title": "THE TRACHEA", "organ": "trachea",
		"inv": ["influenza", "rhinovirus", "sars-cov-2", "influenza", "rhinovirus", "sars-cov-2", "influenza", "rhinovirus"], "sound": "intro_2"},
	3: {"tz": 4.6, "tt": 5.6, "dur": 10.8, "zoom": Vector2(128, 226), "cap": "A COUGH IN THE NIGHT...", "title": "THE LUNGS", "organ": "lungs",
		"inv": ["rhinovirus", "streptococcus-pyogenes", "influenza", "rhinovirus", "sars-cov-2", "influenza", "rhinovirus", "streptococcus-pyogenes"],
		"boss": {"id": "mycobacterium-tuberculosis", "at": 3.2, "size": 64.0}, "sound": "intro_3"},
	4: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(92, 226), "cap": "THE 5 SECOND RULE...", "title": "THE ESOPHAGUS", "organ": "esophagus",
		"inv": ["e-coli", "staphylococcus-aureus", "e-coli", "clostridioides-difficile", "e-coli", "staphylococcus-aureus", "clostridioides-difficile", "e-coli"], "sound": "intro_4"},
	5: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(98, 226), "cap": "DIRTY WATER...", "title": "THE STOMACH", "organ": "stomach",
		"inv": ["helicobacter-pylori", "helicobacter-pylori", "e-coli", "helicobacter-pylori", "staphylococcus-aureus", "helicobacter-pylori", "e-coli", "helicobacter-pylori"], "sound": "intro_5"},
	6: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(90, 262), "cap": "A RAW BURGER...", "title": "THE INTESTINES", "organ": "intestines",
		"inv": ["e-coli", "clostridioides-difficile", "e-coli", "e-coli", "clostridioides-difficile", "staphylococcus-aureus", "e-coli", "clostridioides-difficile"], "sound": "intro_6"},
	7: {"tz": 4.2, "tt": 5.2, "dur": 10.8, "zoom": Vector2(118, 262), "cap": "A NASTY FALL...", "title": "THE BLOODSTREAM", "organ": "blood",
		"inv": ["neisseria-meningitidis", "staphylococcus-aureus", "streptococcus-pyogenes", "e-coli", "neisseria-meningitidis", "staphylococcus-aureus", "streptococcus-pyogenes", "e-coli"],
		"boss": {"id": "neisseria-meningitidis", "at": 3.0, "size": 64.0}, "sound": "intro_7"},
	8: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(96, 226), "cap": "RAW OYSTERS...", "title": "THE LIVER", "organ": "liver",
		"inv": ["e-coli", "staphylococcus-aureus", "e-coli", "clostridioides-difficile", "e-coli", "staphylococcus-aureus", "e-coli", "clostridioides-difficile"], "sound": "intro_8"},
	9: {"tz": 4.6, "tt": 5.6, "dur": 10.6, "zoom": Vector2(134, 250), "cap": "A MOSQUITO BITE...", "title": "THE SPLEEN", "organ": "spleen",
		"inv": ["sars-cov-2", "influenza", "hpv", "herpes-simplex", "sars-cov-2", "hpv", "influenza", "herpes-simplex"], "sound": "intro_9"},
	10: {"tz": 4.4, "tt": 5.4, "dur": 11.6, "zoom": Vector2(90, 226), "cap": "SWOLLEN GLANDS...", "title": "THE LYMPH NODES", "organ": "lymph",
		"inv": ["rhinovirus", "influenza", "sars-cov-2", "e-coli", "staphylococcus-aureus", "hpv", "herpes-simplex", "neisseria-meningitidis"],
		"boss": {"id": "hiv", "at": 4.2, "size": 80.0, "crown": true}, "sound": "intro_10"},
	11: {"tz": 3.6, "tt": 4.6, "dur": 13.4, "zoom": Vector2(90, 160), "scale": 4.0, "cap": "THE LAST BATTLE...", "title": "BODY SAVED!", "organ": "morning",
		"inv": [], "ending": true, "sound": "intro_end"},
}
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"
const INVADERS := ["rhinovirus", "streptococcus-pyogenes", "influenza", "staphylococcus-aureus", "rhinovirus", "sars-cov-2", "streptococcus-pyogenes", "rhinovirus"]
const WORDS := ["BLA BLA", "BLAH..", "YADA", "HMM..", "BLA!", "..."]
const VOWELS := 5

var clock := 0.0
var done := false
var story := 1
var info: Dictionary = {}
var duration := DURATION
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
	story = Session.intro_story if Session.intro_story in STORIES else 1
	info = STORIES[story]
	duration = float(info["dur"])
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
	_talk["A"] = _syllables(0.3, 1.7, 1)
	_talk["B"] = _syllables(1.9, 3.5, 100)
	_player = AudioStreamPlayer.new()
	_player.stream = load("res://assets/audio/common/%s.wav" % info["sound"])
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
		finished.connect(_go_on)


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
	if clock >= duration + 0.2:
		_finish()


## After the story: the level starts, or the menu opens after the ending.
func _go_on() -> void:
	if story == ENDING:
		Session.open_menu()
	else:
		get_tree().change_scene_to_file(Session.LEVEL_SCENE)


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
	var tz := float(info["tz"])
	var tt := float(info["tt"])
	var ending: bool = info.get("ending", false)
	var cover := Color.WHITE if ending else Color(0.30, 0.08, 0.14)
	_xf = Transform2D.IDENTITY
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color.BLACK)
	if t < tz:
		var shake := Vector2.ZERO
		if story == 1 and t >= T_CHOO and t < T_CHOO + 0.6:
			shake = Vector2(_rng.randf() - 0.5, _rng.randf() - 0.5) * 7.0 * U
		_xf = Transform2D(0.0, Vector2.ONE, 0.0, shake)
		_act(t)
		_xf = Transform2D.IDENTITY
		if story == 1 and t >= T_CHOO and t < T_CHOO + 0.08:
			_cover(Color(1, 1, 1, 0.85))
	elif t < tt:
		var k := (t - tz) / (tt - tz)
		var e := k * k * (3.0 - 2.0 * k)
		var s := 1.0 + e * float(info.get("scale", 18.0))
		var p: Vector2 = (info["zoom"] as Vector2) * U
		_xf = Transform2D(0.0, Vector2(s, s), 0.0, p - p * s)
		_act(tz if story != 1 else T_AFTER)
		_xf = Transform2D.IDENTITY
		_cover(Color(cover, maxf(0.0, (k - (0.4 if ending else 0.5)) / (0.6 if ending else 0.5))))
	else:
		var u := t - tt
		if story == 1:
			_throat(u)
		elif ending:
			IntroStories.morning(self, u)
		else:
			_organ(String(info["organ"]), u, info["inv"], info.get("boss", {}))
		var k := minf(1.0, u / 0.4)
		if k < 1.0:
			_cover(Color(cover, 1.0 - k))
	# cinematic bars and captions
	_use(Transform2D.IDENTITY)
	_r(0, 0, 180, 14, Color.BLACK)
	_r(0, 306, 180, 14, Color.BLACK)
	if t < 2.4:
		_text(String(info["cap"]), Vector2(90, 24), 6.0, Color.WHITE, true)
	var title_at := tt + (5.0 if ending else 3.0)
	if t >= title_at:
		var message := String(info["title"])
		var n := mini(message.length(), int((t - title_at) * 20.0))
		_text(message.substr(0, n), Vector2(91, 297), 12.0, Color("1a1020"), true)
		_text(message.substr(0, n), Vector2(90, 296), 12.0, Color("c0392b") if ending else Color("f4d35e"), true)
	if ending:
		if t >= tt + 7.4:
			_text("THANK YOU FOR PLAYING", Vector2(90, 274), 6.0, Color("7a5a3a"), true)
		if t >= tt + 8.6:
			_text("APOLO SOFTWARE", Vector2(90, 262), 7.0, Color("c0392b"), true)
	elif t >= tt + 3.9:
		_text("THEY ARE COMING IN", Vector2(90, 274), 6.0, Color("ffb3c7"), true)
	if t > duration - 0.8:
		_cover(Color(0, 0, 0, minf(1.0, (t - (duration - 0.8)) / 0.8)))


## The scene before the zoom, by story.
func _act(t: float) -> void:
	if story == 1:
		_street(t)
		_spray(t)
	else:
		IntroStories.act(self, story, t)


func _tex(id: String) -> Texture2D:
	var key := id.replace("_", "-") if not id.begins_with("tower_") else id
	if not _textures.has(key):
		var path := "res://assets/towers/%s.png" % key.trim_prefix("tower_") if key.begins_with("tower_") else "res://assets/enemies/%s/%s_sprite.png" % [key, key]
		_textures[key] = load(path)
	return _textures[key]


func _disc(cx: float, cy: float, r: int, color: Color) -> void:
	for dy in range(-r, r + 1):
		var w := floorf(sqrt(float(r * r - dy * dy)))
		_r(roundf(cx) - w, roundf(cy) + dy, 2.0 * w + 1.0, 1, color)


## A sprite from a given top-left corner; opts: flip, rot, sx, sy, a.
func _spr(id: String, x: float, y: float, size: float, opts := {}) -> void:
	var half := size / 2.0
	_use(Transform2D(float(opts.get("rot", 0.0)), Vector2((-1.0 if opts.get("flip", false) else 1.0) * float(opts.get("sx", 1.0)), float(opts.get("sy", 1.0))), 0.0, Vector2(x + half, y + half)))
	draw_texture_rect(_tex(id), Rect2(-half, -half, size, size), false, Color(1, 1, 1, float(opts.get("a", 1.0))))


## Big comic lettering (shadow, yellow, red edge), centred.
func _big(text: String, x: float, y: float, size: float, k := 1.0) -> void:
	var jitter := Vector2(_rng.randf() - 0.5, _rng.randf() - 0.5) * 3.0
	for layer in [[Vector2(2, 2), Color("7a1f2b")], [Vector2.ZERO, Color("ffe14a")], [Vector2(-1, -1), Color("e84a5f")]]:
		_text(text, Vector2(x, y) + jitter + (layer[0] as Vector2), size * k, layer[1], true)


func _sky(t: float, bands: Array) -> void:
	_use(Transform2D.IDENTITY)
	for i in bands.size():
		_r(0, i * 30, 180, 30, Color(bands[i]))
	for i in 3:
		var cx := fposmod(i * 80.0 + t * 3.0, 230.0) - 30.0
		var cy := 30.0 + i * 34.0
		_r(cx, cy, 26, 6, Color.WHITE)
		_r(cx + 4, cy - 4, 16, 4, Color.WHITE)


func _city(top: float, colors: Array) -> void:
	_use(Transform2D.IDENTITY)
	for i in 9:
		var h := 60.0 + _rnd(i) * 50.0
		_r(i * 21 - 6, top - h, 22, h + 80, Color(colors[i % 3]))
		var wy := 0.0
		while wy < h - 8.0:
			var wx := 3.0
			while wx < 18.0:
				_r(i * 21 - 6 + wx, top - h + 6 + wy, 3, 4, Color("d9cf9a"))
				wx += 7.0
			wy += 10.0


## A small full-body person standing at (px, py); `o` has shirt, hair, helmet, rot.
func _body(px: float, py: float, face: float, o: Dictionary) -> void:
	_use(Transform2D(float(o.get("rot", 0.0)), Vector2.ONE, 0.0, Vector2(px, py)))
	_r(-5, -12, 4, 12, Color("3b3f6b"))
	_r(1, -12, 4, 12, Color("3b3f6b"))
	_r(-6, -2, 6, 2, Color("222222"))
	_r(0, -2, 6, 2, Color("222222"))
	_r(-7, -28, 14, 17, o["shirt"])
	_r(-10, -27, 3, 12, o["shirt"])
	_r(7, -27, 3, 12, o["shirt"])
	_r(-5, -41, 10, 10, Color("f0c8a0"))
	_r(-6, -43, 12, 4, o["hair"])
	_r(face * 3.0 - 1.0, -37, 2, 2, Color("222222"))
	_r(face * 3.0, -33, 3, 1, Color("9a5a4a"))
	if o.get("helmet", false):
		_r(-7, -45, 14, 5, Color("e8c84a"))


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
	var skin := Color("e8806a") if o.get("red", false) else Color("c9d6a8") if o.get("pale", false) else Color("f0c8a0")
	var shirt: Color = o["shirt"]
	var hair: Color = o["hair"]
	var shake := sin(t * 45.0) * float(o.get("shake", 0.0))
	var base := Transform2D(0.0, Vector2.ONE, 0.0, Vector2(cx + shake + float(o.get("lean", 0.0)), 0.0))
	_use(base)
	if not o.get("nobody", false):
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
	if o.get("puff", false):
		_r(face * 13.0 - (6.0 if face < 0.0 else 0.0), hy + 14, 6, 9, skin)
		_r(-15, hy + 19, 30, 1, Color(0, 0, 0, 0.1))
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
	if o.get("sleep", false) or o.get("squeeze", false):
		_r(ex - 1, hy + 11, 7, 2, Color("222222"))
		if o.get("squeeze", false):
			_r(ex - 1, hy + 7, 8, 2, hair)
	elif o.get("bulge", false):
		_r(ex - 1, hy + 7, 8, 10, Color.WHITE)
		_r(ex + (3.0 if face > 0.0 else 1.0), hy + 10, 3, 5, Color("222222"))
		_r(ex - 1, hy + 4, 8, 2, hair)
	else:
		_r(ex, hy + 9, 5, 6, Color.WHITE)
		_r(ex + (2.0 if face > 0.0 else 0.0) + float(o.get("look", 0.0)), hy + 10, 3, 4, Color("222222"))
		_r(ex - 1, hy + 6 + float(o.get("brow", 0.0)), 7, 2, hair)
	var m := float(o.get("mouth", 0.0))
	var mx := face * 5.0 - (10.0 if face < 0.0 else 0.0) + face
	if m > 1.0:
		var h := 8.0 + roundf(m * 5.0)
		_r(mx - 1, hy + 20, 12, h, Color("7a1f2b"))
		_r(mx + 1, hy + 20, 8, 3, Color.WHITE)
		_r(mx + 2, hy + 20 + h - 4, 7, 4, Color("e8546a"))
	elif m > 0.0:
		_r(mx, hy + 21, 9, 2 + roundf(m * 5.0), Color("7a1f2b"))
	elif o.get("smile", false):
		_r(mx, hy + 21, 9, 2, Color("7a1f2b"))
		_r(mx - 1, hy + 20, 1, 2, Color("7a1f2b"))
		_r(mx + 9, hy + 20, 1, 2, Color("7a1f2b"))
	else:
		_r(mx, hy + 22, 8, 2, Color("9a5a4a"))
	if o.get("cap", false) and not bool(_cap["on"]):
		_r(-17, hy - 8, 34, 6, Color("e84a4a"))
		_r(4.0 if face > 0.0 else -26.0, hy - 3, 24, 3, Color("b83030"))
	if o.get("sweat", false):
		_r(face * -12.0, hy - 6 + (int(t * 8.0) % 4) * 2, 3, 5, Color("8fd3ff"))
		_r(face * 12.0, hy + 2 + (int(t * 6.0) % 4) * 2, 2, 4, Color("8fd3ff"))


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
		draw_texture_rect(_tex(INVADERS[i]), Rect2(-16, -16, 32, 32), false)


# --- inside the other organs --------------------------------------------------------------------

const ORGAN_BACK := {"trachea": "2c1a2c", "lungs": "6a2a3a", "esophagus": "4d1a28", "stomach": "4e5216", "intestines": "6a2e20",
	"blood": "5a0e18", "liver": "3d0f16", "spleen": "3a1736", "lymph": "0e2c3b"}


func _pinch(y: float, t: float, power: float) -> float:
	return power * exp(-pow((y - (fposmod(t * 60.0, 380.0) - 30.0)) / 20.0, 2.0))


func _organ(kind: String, t: float, invaders: Array, boss: Dictionary) -> void:
	_use(Transform2D.IDENTITY)
	_r(0, 0, 180, 320, Color(ORGAN_BACK[kind]))
	for i in 110:
		_r(_rnd(i) * 180.0, fposmod(_rnd(i + 90.0) * 320.0 + t * 12.0 * (0.3 + _rnd(i + 5.0)), 320.0), 2, 2, Color(1, 1, 1, 0.06))
	var beat := pow(maxf(0.0, sin(t * 2.4)), 4.0) * 3.0
	match kind:
		"trachea", "esophagus", "intestines":
			_organ_tube(kind, t, beat)
		"lungs":
			for gy in 9:
				for gx in 6:
					var cx := gx * 34.0 + (gy % 2) * 17.0 - 4.0
					var cy := gy * 38.0 + fposmod(t * 14.0, 38.0) - 30.0
					var r := roundi(15.0 + sin(t * 2.0 + gx + gy) * 2.0)
					_disc(cx, cy, r + 2, Color("e89aa8"))
					_disc(cx, cy, r, Color("a8455c"))
					_disc(cx - 4.0, cy - 4.0, 3, Color("c8708a"))
		"stomach":
			for y in range(0, 320, 2):
				var wob := sin(y * 0.12 + t * 1.2) * 5.0
				_r(0, y, 26 + wob, 2, Color("d98a96"))
				_r(20 + wob, y, 4, 2, Color("b0586a"))
				_r(154 + wob, y, 26 - wob, 2, Color("d98a96"))
				_r(150 + wob, y, 4, 2, Color("b0586a"))
			_r(26, 236, 128, 84, Color("b7d02e"))
			for xx in range(26, 154, 2):
				_r(xx, 234 + sin(xx * 0.2 + t * 3.0) * 2.0, 2, 4, Color("dcf060"))
			for i in 14:
				var by := fposmod(fposmod(300.0 - (t * (14.0 + _rnd(i + 3.0) * 20.0) + _rnd(i + 7.0) * 200.0), 240.0) + 240.0, 240.0) + 60.0
				_disc(34.0 + _rnd(i) * 112.0, by, 2 + int(_rnd(i + 9.0) * 3.0), Color(0.86, 0.94, 0.47, 0.7))
		"blood":
			for y in range(0, 320, 2):
				var wob := sin(y * 0.07 + t) * 2.0
				_r(0, y, 16 + wob + beat, 2, Color("8a2a3a"))
				_r(12 + wob + beat, y, 3, 2, Color("c45a6a"))
				_r(164 + wob - beat, y, 16 - wob + beat, 2, Color("8a2a3a"))
				_r(164 + wob - beat, y, 3, 2, Color("c45a6a"))
			for i in 16:
				var cx := 26.0 + _rnd(i) * 128.0 + sin(t * 2.0 + i) * 3.0
				var cy := fposmod(_rnd(i + 20.0) * 340.0 + t * (36.0 + _rnd(i + 4.0) * 30.0), 360.0) - 20.0
				_disc(cx, cy, 6, Color("d02838"))
				_disc(cx, cy, 2, Color("8a1626"))
			var w := fposmod(t * 50.0, 360.0) - 20.0
			_disc(30.0 + sin(t * 2.0) * 4.0, w, 6, Color("f4f0f0"))
			_disc(30.0 + sin(t * 2.0) * 4.0, w, 2, Color("c8c8e0"))
		"liver":
			for gy in range(-1, 9):
				for gx in range(-1, 5):
					var cx := gx * 52.0 + (gy % 2) * 26.0
					var cy := gy * 46.0 + fposmod(t * 10.0, 46.0)
					for a in 6:
						var a0 := a * PI / 3.0 + 0.5
						for k in range(0, 15, 2):
							_r(cx + cos(a0) * k * 1.5, cy + sin(a0) * k * 1.5, 2, 2, Color("6a2028"))
					_disc(cx, cy, 4, Color("8a3a40"))
			for i in 24:
				_r(_rnd(i) * 180.0, fposmod(_rnd(i + 30.0) * 320.0 + t * 20.0, 320.0), 3, 3, Color("9aa820"))
			for i in 6:
				_disc(20.0 + _rnd(i) * 140.0, fposmod(_rnd(i + 60.0) * 320.0 + t * 40.0, 340.0) - 10.0, 4, Color("c02030"))
		"spleen":
			for i in 9:
				var cx := 20.0 + _rnd(i) * 140.0
				var cy := 20.0 + _rnd(i + 11.0) * 280.0
				_disc(cx, cy, 14, Color("6a3a62"))
				_disc(cx, cy, 11, Color("e8b0c8"))
				_disc(cx, cy, 4, Color("f8e0ec"))
			for i in 34:
				_disc(_rnd(i + 70.0) * 180.0 + sin(t * 2.0 + i) * 3.0, fposmod(_rnd(i + 90.0) * 340.0 + t * (18.0 + _rnd(i) * 20.0), 350.0) - 10.0, 3, Color("b02a44"))
		_:
			for i in 70:
				var cx := _rnd(i) * 180.0
				var cy := _rnd(i + 30.0) * 320.0 + sin(t + i) * 2.0
				_disc(cx, cy, 8, Color("2a6a88"))
				_disc(cx, cy, 6, Color("a8d8e8"))
				_disc(cx + 1.0, cy, 3, Color("4a7a98"))
			for i in 14:
				var y0 := _rnd(i + 300.0) * 320.0
				for xx in range(0, 180, 6):
					_r(xx, y0 + sin(xx * 0.05 + i) * 8.0, 2, 1, Color(0.59, 0.86, 1.0, 0.15))
	for i in 30:
		_r(0, 290 + i, 180, 1, Color(0.04, 0.01, 0.02, i / 45.0))
	for i in invaders.size():
		var k := t - (0.5 + i * 0.4)
		if k < 0.0:
			continue
		var px := 44.0 + float((i * 37) % 80) + sin(k * 2.0 + i) * 6.0
		var py := -40.0 + k * 58.0
		if py > 330.0:
			continue
		var squash := 1.0 + sin(k * 8.0 + i) * 0.07
		_use(Transform2D(0.0, Vector2(squash, 1.0 / squash), 0.0, Vector2(px + 16.0, py + 16.0)))
		draw_texture_rect(_tex(String(invaders[i])), Rect2(-16, -16, 32, 32), false)
	if not boss.is_empty():
		var k := t - float(boss["at"])
		if k > 0.0:
			var size := float(boss.get("size", 72.0))
			var py := minf(-size + k * 34.0, 150.0)
			var squash := 1.0 + sin(k * 5.0) * 0.04
			_use(Transform2D(0.0, Vector2(squash, 1.0 / squash), 0.0, Vector2(90.0, py + size / 2.0)))
			draw_texture_rect(_tex(String(boss["id"])), Rect2(-size / 2.0, -size / 2.0, size, size), false)
			if boss.get("crown", false):
				_use(Transform2D.IDENTITY)
				_r(76, py - 4, 28, 5, Color("ffd23a"))


func _organ_tube(kind: String, t: float, beat: float) -> void:
	var w := 34.0 if kind == "esophagus" else 26.0 if kind == "trachea" else 20.0
	var c_a := Color("d9a0a8") if kind == "trachea" else Color("e8895a") if kind == "intestines" else Color("c4586f")
	var c_b := Color("f4d0cc") if kind == "trachea" else Color("ffc08a") if kind == "intestines" else Color("e48a9c")
	var c_c := Color("a56a78") if kind == "trachea" else Color("b85c3a") if kind == "intestines" else Color("a63e56")
	for y in range(0, 320, 2):
		var wob := sin(y * 0.09 + t * 1.5) * 3.0
		var lw := w + wob + beat
		var rw := w - wob + beat
		if kind == "esophagus":
			var p := _pinch(y, t, 16.0)
			lw += p
			rw += p
		_r(0, y, lw, 2, c_a)
		_r(lw - 3, y, 3, 2, c_b)
		_r(lw - 8, y, 5, 2, c_c)
		_r(180 - rw, y, rw, 2, c_a)
		_r(180 - rw, y, 3, 2, c_b)
		_r(180 - rw + 3, y, 5, 2, c_c)
		if kind == "trachea" and y % 16 < 4:
			_r(0, y, lw - 8, 2, Color("f4ead8"))
			_r(180 - rw + 8, y, rw - 8, 2, Color("f4ead8"))
		if kind == "intestines" and y % 8 == 0:
			var l := 6.0 + sin(t * 3.0 + y) * 2.0
			_r(lw, y, l, 3, Color("ffa060"))
			_r(180 - rw - l, y, l, 3, Color("ffa060"))
			_r(lw + l, y + 1, 2, 1, Color("ffd0a0"))
			_r(180 - rw - l - 2, y + 1, 2, 1, Color("ffd0a0"))
		if kind == "trachea" and y % 6 == 0:
			var s := sin(t * 7.0 + y) * 1.5
			_r(lw + s, y, 1, 4, Color("ffb0c4"))
			_r(180 - rw + s - 1, y, 1, 4, Color("ffb0c4"))
