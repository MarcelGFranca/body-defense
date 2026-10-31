## The scenes of the level stories 2 to 10 and of the ending (how the germs got in, drawn before the zoom into the organ).
## Each one is drawn on a `LevelIntro` canvas in its 180 x 320 grid. Level 1 lives in intro.gd.
class_name IntroStories
extends RefCounted

const SKY := ["6fb7e8", "80c2ec", "92cdf0", "a5d7f3", "b8e1f6", "cbebf9"]
const CITY := ["8a7fa0", "9a8fb0", "7d7396"]
const RED := {"shirt": Color("e84a5f"), "hair": Color("4a2b1a")}
const BLUE := {"shirt": Color("4aa3e8"), "hair": Color("e8c84a")}
const GREEN := {"shirt": Color("5ab86a"), "hair": Color("222222")}


static func act(c: LevelIntro, story: int, t: float) -> void:
	match story:
		2: trachea(c, t)
		3: lungs(c, t)
		4: esophagus(c, t)
		5: stomach(c, t)
		6: intestines(c, t)
		7: bloodstream(c, t)
		8: liver(c, t)
		9: spleen(c, t)
		10: lymph(c, t)
		_: ending(c, t)


static func _fill(c: LevelIntro, color: String, rect: Rect2) -> void:
	c._use(Transform2D.IDENTITY)
	c._r(rect.position.x, rect.position.y, rect.size.x, rect.size.y, Color(color))


static func trachea(c: LevelIntro, t: float) -> void:
	_fill(c, "6b4a35", Rect2(0, 0, 180, 320))
	var books := ["a83a3a", "3a6aa8", "5a9a4a", "d8b040", "7a4a9a"]
	for r in 3:
		c._r(0, 60 + r * 70, 180, 5, Color("3d2a1d"))
		for i in 14:
			var h := 24.0 + LevelIntro._rnd(i + r * 20) * 18.0
			c._r(i * 13 + 2, 60 + r * 70 - h, 10, h, Color(books[(i + r) % 5]))
	c._r(0, 262, 180, 60, Color("4a3220"))
	var o := RED.duplicate()
	o["mouth"] = 0.0
	o["rot"] = 0.0
	if t >= 1.8 and t < 2.6:
		o["bulge"] = true
		o["rot"] = 0.1
		o["mouth"] = 1.0
	if t >= 2.6:
		var k := minf(1.0, (t - 2.6) / 1.8)
		o["flare"] = roundi(k * 3.0)
		o["rot"] = -0.2 - k * 0.2
		o["squeeze"] = k > 0.4
		o["shake"] = k * 1.2
		o["mouth"] = 0.4
	if t < 1.6:
		o["look"] = 1.0
	c._bust(92.0, 300.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	c._r(104, 226, 34, 22, Color("7a5a3a"))
	c._r(104, 226, 34, 3, Color("a98050"))
	if t < 1.8:
		c._r(106, 229, 30, 16, Color("9a7a52"))
	else:
		c._r(106, 229, 14, 16, Color("e8dcc0"))
		c._r(122, 229, 14, 16, Color("e8dcc0"))
	c._r(100, 244, 9, 6, Color("f0c8a0"))
	c._r(134, 244, 9, 6, Color("f0c8a0"))
	if t >= 1.8:
		var k := t - 1.8
		var r := minf(1.0, k / 0.9) * 60.0
		for i in 16:
			var a := i * 0.8
			var rr := r * (0.4 + LevelIntro._rnd(i) * 0.7)
			c._disc(122.0 + cos(a) * rr * 1.4, 226.0 - absf(sin(a)) * rr * 0.9, 5 + int(LevelIntro._rnd(i + 5.0) * 6.0), Color(0.78, 0.75, 0.67, maxf(0.0, 0.85 - k * 0.18)))
		if k < 1.1:
			c._big("POOF!", 90, 100, 14, 1.0 + minf(1.0, k * 4.0) * 0.7)
	if t >= 2.6 and t < 4.5:
		for i in 14:
			var u := fposmod(t * 0.8 + i * 0.17, 1.0)
			c._r(122.0 - 22.0 * u + sin(i) * 8.0 * (1.0 - u), 226.0 - 20.0 * u, 2, 2, Color(0.78, 0.75, 0.67, 0.9))


static func lungs(c: LevelIntro, t: float) -> void:
	_fill(c, "1d2347", Rect2(0, 0, 180, 320))
	for i in 26:
		c._r(LevelIntro._rnd(i) * 180.0, LevelIntro._rnd(i + 9.0) * 120.0, 2, 2, Color.WHITE)
	c._disc(30, 44, 14, Color("f4efd0"))
	c._disc(36, 40, 11, Color("1d2347"))
	c._r(0, 200, 180, 120, Color("2a2f5a"))
	c._r(8, 24, 60, 64, Color("0a0f2a"))
	c._r(10, 26, 56, 60, Color("16204a"))
	c._r(88, 196, 92, 124, Color("7a4a6a"))
	c._r(88, 196, 92, 10, Color("9a6a8a"))
	c._r(100, 226, 60, 50, Color("e8e0d0"))
	var kid := GREEN.duplicate()
	kid["sleep"] = true
	kid["mouth"] = 0.0
	var rise := sin(t * 3.0) * 1.2
	var adult := RED.duplicate()
	adult["mouth"] = 0.0
	var coughing := (t > 1.0 and t < 1.3) or (t > 1.5 and t < 1.8) or (t > 2.0 and t < 2.3)
	if coughing:
		adult["mouth"] = 2.0
		adult["rot"] = 0.12
		adult["squeeze"] = true
		adult["shake"] = 1.5
	if t >= 3.6:
		kid["sleep"] = false
		kid["bulge"] = true
		kid["mouth"] = 1.4
		kid["rot"] = 0.1
	c._bust(40.0, 306.0, 1.0, adult, t)
	c._bust(136.0, 300.0 + rise, -1.0, kid, t)
	c._use(Transform2D.IDENTITY)
	c._r(104, 248 + rise, 70, 80, Color("6a8ac8"))
	c._r(104, 248 + rise, 70, 3, Color("9ab6e8"))
	if t < 3.5:
		c._text("Zzz", Vector2(140.0 + sin(t * 2.0) * 3.0, 200.0 - t * 5.0), 8.0, Color("cfe0ff"))
	if coughing:
		c._big("COF!", 70, 150, 12, 1.1)
	if t >= 1.0:
		var u := minf(1.0, (t - 1.0) / 2.6)
		for i in 22:
			var a := i * 1.1
			var alpha := maxf(0.0, 0.6 - (t - 3.6) * 0.7) if t > 3.6 else 0.55
			c._disc(56.0 + u * 78.0 + cos(a) * (4.0 + u * 8.0), 222.0 - u * 6.0 + sin(a * 1.3) * (3.0 + u * 6.0), 3 + int(LevelIntro._rnd(i) * 4.0), Color(0.59, 0.82, 0.35, alpha))


static func esophagus(c: LevelIntro, t: float) -> void:
	c._sky(t, SKY)
	c._city(220, CITY)
	c._r(0, 250, 180, 70, Color("6aa84f"))
	c._r(0, 250, 180, 3, Color("85c25f"))
	c._r(10, 282, 160, 30, Color("d84a4a"))
	for i in 8:
		for j in 2:
			c._r(10 + i * 20 + j * 10, 282 + j * 15, 10, 15, Color.WHITE)
	var o := BLUE.duplicate()
	o["smile"] = t < 1.0
	var sx := 124.0
	var sy := 210.0
	if t < 1.0:
		pass
	elif t < 1.7:
		var k := t - 1.0
		sy = 210.0 + k * k * 120.0
		o["bulge"] = t > 1.3
	elif t < 2.5:
		sy = 300.0
		o["look"] = 1.0
	elif t < 3.3:
		var k := (t - 2.5) / 0.8
		sx = 124.0 - k * 30.0
		sy = 300.0 - k * 110.0
		o["mouth"] = 0.6
	else:
		sx = 94.0
		sy = 188.0
		o["mouth"] = 3.0
	if t >= 3.3 and t < 4.4:
		o["puff"] = true
	c._bust(70.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	var left := 1.0 if t < 3.5 else maxf(0.0, 1.0 - (t - 3.5) * 0.9)
	if left > 0.0:
		c._r(sx - 12, sy, 26, 6, Color("d8a84a"))
		c._r(sx - 12, sy + 6, 26, 3, Color("5aa04a"))
		c._r(sx - 12, sy + 9, 26, 5, Color("d8504a"))
		c._r(sx - 12, sy + 14, 26, 5, Color("d8a84a"))
	if t >= 1.7 and t < 2.5:
		for i in 4:
			c._r(116 + i * 8, 296 + (i % 2) * 2, 2, 2, Color("6a4a2a"))
		c._big("5 SECOND RULE!", 90, 110, 9, 1.0)
	if t >= 1.8 and t < 3.4:
		for i in 4:
			c._spr(["e-coli", "staphylococcus-aureus"][i % 2], 118.0 + i * 7.0 + sin(t * 6.0 + i) * 2.0, 278.0 - absf(sin(t * 5.0 + i)) * 3.0 - (maxf(0.0, t - 2.6) * 60.0), 12.0)
	if t < 3.0:
		c._use(Transform2D.IDENTITY)
		var fx := 60.0 + cos(t * 4.0) * 50.0 + t * 6.0
		var fy := 120.0 + sin(t * 9.0) * 18.0
		c._r(fx, fy, 3, 3, Color("111111"))
		c._r(fx - 2, fy - 2, 2, 2, Color(1, 1, 1, 0.7))
		c._r(fx + 3, fy - 2, 2, 2, Color(1, 1, 1, 0.7))
	if t >= 3.8 and t < 4.6:
		c._disc(70, 224.0 + (t - 3.8) / 0.8 * 34.0, 5, Color("e8b090"))


static func stomach(c: LevelIntro, t: float) -> void:
	c._use(Transform2D.IDENTITY)
	var bands := ["f4c842", "f6d062", "f8d884", "f8e0a4", "f8e8c4", "faf0d8"]
	for i in bands.size():
		c._r(0, i * 30, 180, 30, Color(bands[i]))
	c._r(0, 180, 180, 80, Color("faf0d8"))
	c._disc(150, 50, 18, Color("fff4a0"))
	for i in 8:
		c._r(150.0 + cos(i * 0.78) * 26.0, 50.0 + sin(i * 0.78) * 26.0, 4, 4, Color("fff4a0"))
	c._r(0, 250, 180, 70, Color("d8b868"))
	c._r(0, 250, 180, 3, Color("e8cc88"))
	var o := RED.duplicate()
	o["sweat"] = true
	var gx := 134.0
	var gy := 214.0
	if t < 1.6:
		o["mouth"] = 0.0
	elif t < 2.6:
		gx = 134.0 - (t - 1.6) * 50.0
		gy = 214.0 - (t - 1.6) * 18.0
	else:
		gx = 84.0
		gy = 196.0
		o["rot"] = -0.1
		o["mouth"] = 0.4
		o["shake"] = 0.6
	var level := 18.0 if t < 2.6 else maxf(2.0, 18.0 - (t - 2.6) * 9.0)
	if t >= 4.0:
		o["mouth"] = 3.0
		o["rot"] = 0.0
		o["sweat"] = false
	c._bust(60.0, 306.0, 1.0, o, t)
	var tilt := 0.0
	if t > 2.8 and t < 4.0:
		tilt = -0.25 - (t - 2.8) * 0.25
	c._use(Transform2D(tilt, Vector2.ONE, 0.0, Vector2(gx, gy)))
	c._r(-9, 0, 18, 26, Color(0.7, 0.86, 0.94, 0.6))
	c._r(-9, 26 - level, 18, level, Color("8a6a3a"))
	c._r(-9, 0, 2, 26, Color.WHITE)
	for i in 3:
		c._spr("helicobacter-pylori", -7.0 + i * 5.0, 26.0 - level + 2.0 + sin(t * 5.0 + i) * 2.0, 10.0)
	c._use(Transform2D.IDENTITY)
	if t < 1.6:
		c._r(120, 190, 6, 70, Color("6a6a7a"))
		c._r(112, 186, 22, 6, Color("6a6a7a"))
		for i in 5:
			c._r(120, 196.0 + fposmod(t * 90.0 + i * 14.0, 60.0), 3, 6, Color("8a6a3a"))
	if t >= 2.8 and t < 4.0:
		c._text("GLUG", Vector2(100, 150), 8.0, Color.WHITE)
	if t >= 4.0 and t < 4.6:
		c._big("AAH!", 90, 150, 10, 1.0)


static func intestines(c: LevelIntro, t: float) -> void:
	_fill(c, "3a2a4a", Rect2(0, 0, 180, 320))
	c._r(0, 200, 180, 120, Color("c8b090"))
	for i in 10:
		for j in 4:
			if (i + j) % 2 == 1:
				c._r(i * 18, 230 + j * 22, 18, 22, Color("8a6a50"))
	c._r(20, 40, 140, 26, Color("1a1030"))
	c._text("BURGER", Vector2(90, 59), 14.0, Color("ff4a8a") if int(t * 3.0) % 2 == 1 else Color("4af0ff"), true)
	var o := RED.duplicate()
	o["hair"] = Color("222222")
	var bite := t >= 1.5
	if t < 1.5:
		o["mouth"] = 0.2
	elif t < 3.6:
		o["mouth"] = 1.0 if int(t * 6.0) % 2 == 1 else 0.0
		o["puff"] = true
	else:
		o["bulge"] = true
		o["mouth"] = 0.0
		o["sweat"] = true
		o["rot"] = 0.08
	c._bust(78.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	var bh := maxf(10.0, 28.0 - (t - 1.5) * 8.0) if bite else 28.0
	c._r(98, 200 + (28 - bh), 44, 6, Color("d8a050"))
	c._r(98, 206 + (28 - bh), 44, 6, Color("6a9a3a"))
	if bh > 12.0:
		c._r(98, 212 + (28 - bh), 44, minf(8.0, bh - 10.0), Color("e07a8a"))
	c._r(98, 220 + (28 - bh), 44, 6, Color("d8a050"))
	for i in 3:
		c._spr("e-coli", 100.0 + i * 12.0 + sin(t * 4.0 + i) * 2.0, 191.0 + (28 - bh) - absf(sin(t * 5.0 + i)) * 3.0, 10.0)
	if t >= 3.6:
		var k := t - 3.6
		var sx := sin(t * 50.0) * 1.5
		for i in 4:
			c._r(52.0 + i * 18.0 + sx, 250.0 - absf(sin(t * 6.0 + i)) * 6.0, 2, 8, Color("8ac84a"))
		if k < 1.0:
			c._big("GRRRR...", 90, 150, 11, 1.0 + sin(t * 30.0) * 0.05)
	if t >= 1.5 and t < 3.5:
		c._text("NOM!", Vector2(104, 170), 9.0, Color("ffe14a"))


static func bloodstream(c: LevelIntro, t: float) -> void:
	c._sky(t, SKY)
	c._city(210, CITY)
	c._r(0, 250, 180, 70, Color("9a9aa4"))
	c._r(0, 250, 180, 3, Color("c8c8d4"))
	c._r(70, 232, 60, 18, Color("7a7a88"))
	var px := 20.0
	var py := 250.0
	var rot := 0.0
	var lying := false
	if t < 1.4:
		px = 14.0 + t * 60.0
	elif t < 2.4:
		var k := t - 1.4
		px = 98.0 + k * 20.0
		py = 250.0 - sin(k * PI) * 58.0
		rot = k * TAU
	elif t < 3.0:
		var k := (t - 2.4) / 0.6
		px = 118.0 + k * 10.0
		py = 250.0 - sin(minf(1.0, k) * 3.0) * 14.0 * (1.0 - k)
	else:
		lying = true
	c._use(Transform2D.IDENTITY)
	if t < 2.4:
		c._r(px - 12, py, 24, 3, Color("4a2a1a"))
		c._disc(px - 8, py + 4, 2, Color("222222"))
		c._disc(px + 8, py + 4, 2, Color("222222"))
	if not lying:
		c._body(px, py - 2.0, 1.0, {"shirt": RED["shirt"], "hair": RED["hair"], "helmet": true, "rot": rot})
	else:
		c._body(130.0, 250.0, 1.0, {"shirt": RED["shirt"], "hair": RED["hair"], "helmet": true, "rot": -1.4})
		c._use(Transform2D.IDENTITY)
		c._r(110, 244, 4, 3, Color("c02030"))
		c._r(100, 252, 24, 3, Color("4a2a1a"))
	c._use(Transform2D.IDENTITY)
	if t >= 2.4 and t < 3.0:
		for i in 6:
			c._r(118 + i * 3, 248.0 - i * 2 + (t - 2.4) * 20.0, 2, 2, Color("ffe14a"))
	if t >= 2.8 and t < 3.9:
		c._big("CRASH!", 90, 130, 14, 1.1)
	if t >= 3.0 and t < 4.2:
		c._text("OUCH!", Vector2(84, 170), 9.0, Color.WHITE)
	if t >= 3.3:
		for i in 5:
			c._spr(["neisseria-meningitidis", "e-coli", "staphylococcus-aureus"][i % 3], 104.0 + i * 5.0, 236.0 - sin(t * 3.0 + i) * 3.0, 10.0)


static func liver(c: LevelIntro, t: float) -> void:
	_fill(c, "2a1a2e", Rect2(0, 0, 180, 320))
	c._r(0, 190, 180, 130, Color("5a3a2a"))
	c._r(0, 190, 180, 4, Color("8a6040"))
	for i in 5:
		c._r(16 + i * 36, 40, 18, 60, Color(1, 0.86, 0.55, 0.12))
	c._disc(150, 170, 5, Color("ffcf60"))
	c._r(149, 176, 2, 20, Color("e8d8b8"))
	c._r(148, 160 + sin(t * 12.0) * 2.0, 4, 4, Color("ff8a2a"))
	c._r(0, 262, 180, 60, Color("e8e0d0"))
	var o := BLUE.duplicate()
	o["hair"] = Color("222222")
	var ox := 104.0
	var oy := 240.0
	if t < 1.4:
		o["smile"] = true
	elif t < 2.0:
		o["brow"] = -2.0
		o["bulge"] = true
	elif t < 3.2:
		var k := (t - 2.0) / 1.2
		ox = 104.0 - k * 28.0
		oy = 240.0 - k * 40.0
		o["mouth"] = 0.6
		o["rot"] = -0.2
		o["squeeze"] = true
	else:
		o["puff"] = true
		o["squeeze"] = true
	c._bust(60.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	c._r(90, 256, 60, 8, Color("c8c8d0"))
	for i in 3:
		c._disc(100 + i * 18, 252, 7, Color("8a8a96"))
		c._disc(100 + i * 18, 251, 5, Color("b8b8a8"))
	c._r(138, 246, 14, 8, Color("ffe14a"))
	if t < 3.2:
		c._disc(ox, oy, 7, Color("8a8a96"))
		c._disc(ox, oy - 1.0, 5, Color("c8c0a8"))
		for i in 2:
			c._spr("e-coli", ox - 6.0 + i * 7.0, oy - 12.0 - absf(sin(t * 5.0 + i)) * 2.0, 10.0)
	if t >= 1.4 and t < 2.0:
		for i in 6:
			c._r(138.0 + sin(i) * 4.0, 226 + i * 3, 1, 3, Color("ffe14a"))
	if t >= 3.0 and t < 4.2:
		c._big("SLURP!", 100, 120, 12, 1.0)
	if t >= 3.8 and t < 4.6:
		c._disc(60, 224.0 + (t - 3.8) / 0.8 * 34.0, 5, Color("c8b090"))


static func spleen(c: LevelIntro, t: float) -> void:
	c._use(Transform2D.IDENTITY)
	var bands := ["2a2a5a", "4a3a7a", "8a4a7a", "d8647a", "f08a5a", "f8b46a"]
	for i in bands.size():
		c._r(0, i * 30, 180, 30, Color(bands[i]))
	c._r(0, 180, 180, 60, Color("f8b46a"))
	c._r(0, 230, 180, 90, Color("2a4a2a"))
	c._r(0, 230, 180, 3, Color("4a7a3a"))
	for i in 10:
		c._r(LevelIntro._rnd(i) * 180.0 + sin(t + i) * 6.0, 200.0 + LevelIntro._rnd(i + 5.0) * 80.0 + cos(t * 1.3 + i) * 6.0, 2, 2, Color("ffe96a") if int(t * 3.0 + i) % 2 == 1 else Color("8a8a40"))
	c._r(0, 288, 180, 32, Color("8a5a3a"))
	c._r(110, 250, 70, 10, Color("8a5a3a"))
	var o := BLUE.duplicate()
	o["sleep"] = t < 3.3
	if t < 3.3:
		o["rot"] = 0.05
	elif t < 4.4:
		o["bulge"] = true
		o["mouth"] = 2.0
		o["rot"] = -0.1
	else:
		o["squeeze"] = true
		o["mouth"] = 1.0
	c._bust(60.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	c._r(80, 262, 100, 16, Color("4aa3e8"))
	c._r(160, 258, 22, 12, Color("f0c8a0"))
	var mx := 0.0
	var my := 0.0
	if t < 2.6:
		mx = -10.0 + t * 50.0 + sin(t * 6.0) * 8.0
		my = 90.0 + sin(t * 4.0) * 30.0 + t * 20.0
	elif t < 3.4:
		mx = 130.0
		my = 250.0
	else:
		mx = 130.0 + (t - 3.4) * 60.0
		my = 250.0 - (t - 3.4) * 120.0
	if mx < 190.0:
		var fl := int(t * 40.0) % 2
		c._use(Transform2D(0.0, Vector2.ONE, 0.0, Vector2(mx, my)))
		c._r(-4, -1, 9, 4, Color("222222"))
		c._r(-9, -1, 5, 2, Color("222222"))
		c._r(-2, -5 - fl * 2, 4, 4, Color(1, 1, 1, 0.7))
		c._r(2, -5 + fl * 2, 3, 4, Color(1, 1, 1, 0.7))
		c._r(5, 1, 6, 1, Color("222222"))
		if t >= 2.8:
			c._r(-3, 0, 6, 3, Color("c02030"))
	c._use(Transform2D.IDENTITY)
	if t >= 3.3 and t < 4.2:
		c._r(130, 252, 2, 2, Color("c02030"))
	if t >= 3.5 and t < 4.5:
		c._big("SLAP!", 100, 150, 12, 1.0)
		if t > 3.6 and t < 4.0:
			for i in 6:
				c._r(150.0 + cos(i) * 10.0, 250.0 + sin(i) * 10.0, 3, 3, Color("ffe14a"))
	if t >= 4.2:
		c._disc(168, 264, 5, Color("e85a5a"))
	if t < 3.3:
		c._text("ZZZ", Vector2(60, 150), 8.0, Color("cfe0ff"))
	if t >= 4.0 and t < 4.6:
		c._text("OUCH!", Vector2(60, 150), 9.0, Color.WHITE)


static func lymph(c: LevelIntro, t: float) -> void:
	_fill(c, "1c1830", Rect2(0, 0, 180, 320))
	c._r(8, 28, 64, 80, Color("0a0818"))
	c._r(10, 30, 60, 76, Color("2a3060"))
	if (t > 1.2 and t < 1.35) or (t > 2.2 and t < 2.28) or (t > 3.4 and t < 3.5):
		c._r(10, 30, 60, 76, Color.WHITE)
	c._r(0, 230, 180, 90, Color("4a3a5a"))
	c._r(96, 224, 84, 100, Color("7a6a9a"))
	var o := RED.duplicate()
	o["hair"] = Color("6a4a2a")
	o["sweat"] = true
	o["red"] = true
	o["mouth"] = 0.0
	if t >= 1.2 and t < 3.0:
		o["bulge"] = true
	if t >= 3.0:
		o["squeeze"] = true
		o["mouth"] = 2.0
	c._bust(60.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	c._r(94, 232, 10, 24, Color("d04030"))
	c._r(96, 222, 6, 12, Color("e8e0d0"))
	c._r(55, 232, 34, 3, Color.WHITE)
	var k := clampf((t - 1.6) / 1.4, 0.0, 1.0)
	c._disc(56, 228, roundi(2.0 + k * 5.0), Color("e89878"))
	c._disc(66, 230, roundi(2.0 + k * 4.0), Color("e89878"))
	c._r(76, 214 - (2 if t > 1.6 else 0), 12, 12, Color("f0c8a0"))
	if t >= 2.6 and t < 4.4:
		c._big("OUCH!", 90, 130, 12, 1.0)
	if t >= 3.8:
		c._text("...", Vector2(84, 100), 10.0, Color("ffcf60"))


static func ending(c: LevelIntro, t: float) -> void:
	c._organ("lymph", t, [], {})
	var towers := ["macrophage", "neutrophil", "t-lymphocyte", "b-lymphocyte", "interferon", "lysozyme", "platelet", "bone-marrow", "mucus-cell", "hypothalamus"]
	for i in towers.size():
		var a := i / 10.0 * TAU
		var bx := 90.0 + cos(a) * 62.0
		var by := 170.0 + sin(a) * 92.0
		c._spr("tower_" + towers[i], bx - 16.0, by - 16.0 - absf(sin(t * 6.0 + i)) * (6.0 if t > 1.9 else 2.0), 32.0)
	c._use(Transform2D.IDENTITY)
	if t < 1.9:
		var sq := 1.0 + sin(t * 20.0) * 0.06
		var hit := int(t * 8.0) % 2
		c._use(Transform2D(0.0, Vector2(sq, 1.0 / sq), 0.0, Vector2(90, 170)))
		c.draw_texture_rect(c._tex("hiv"), Rect2(-40, -40, 80, 80), false, Color(1, 1, 1, 0.55 if hit == 1 else 1.0))
		c._use(Transform2D.IDENTITY)
		c._r(70, 118, 40, 5, Color("ffd23a"))
	elif t < 2.9:
		var k := (t - 1.9) / 1.0
		c._r(0, 0, 180, 320, Color(1, 1, 1, maxf(0.0, 1.0 - k * 1.4)))
		for i in 30:
			var a := i * 0.9
			var r := k * (30.0 + LevelIntro._rnd(i) * 120.0)
			c._r(90.0 + cos(a) * r, 170.0 + sin(a) * r, 4, 4, [Color("ffe14a"), Color("e84a5f"), Color.WHITE][i % 3])
		if k < 0.8:
			c._big("VICTORY!", 90, 80, 13, 1.0 + k * 0.5)


## The morning after: the person wakes up healthy and the cells cheer. `t` is the time since the zoom ended.
static func morning(c: LevelIntro, t: float) -> void:
	c._use(Transform2D.IDENTITY)
	var k := minf(1.0, t / 2.0)
	var bands := ["ffd89a", "ffe2ae", "ffecc6", "fff2d4", "fff8e6", "fffbf0"]
	for i in bands.size():
		c._r(0, i * 30, 180, 30, Color(bands[i]))
	c._r(0, 180, 180, 60, Color("fffbf0"))
	c._disc(90, 120.0 - k * 40.0, roundi(14.0 + k * 4.0), Color("fff0a0"))
	for i in 12:
		var a := i / 12.0 * TAU + t * 0.4
		c._r(90.0 + cos(a) * (26.0 + k * 10.0), 80.0 + sin(a) * (26.0 + k * 10.0), 4, 4, Color("ffe880"))
	c._r(0, 236, 180, 84, Color("7ab0e8"))
	c._r(0, 236, 180, 4, Color("a8d0f8"))
	c._r(40, 260, 100, 60, Color("f4f0ea"))
	var o := RED.duplicate()
	o["hair"] = Color("6a4a2a")
	o["smile"] = true
	if t < 1.6:
		o["sleep"] = true
		o["mouth"] = 0.0
		o["smile"] = false
	elif t < 3.4:
		var q := (t - 1.6) / 1.8
		o["mouth"] = 2.0
		o["rot"] = -0.15
		o["squeeze"] = true
		o["hy"] = -q * 2.0
	else:
		o["mouth"] = 0.0
	c._bust(90.0, 306.0, 1.0, o, t)
	c._use(Transform2D.IDENTITY)
	c._r(46, 264, 88, 50, Color("8ac8e8"))
	c._r(46, 264, 88, 3, Color("b0e0f8"))
	if t >= 1.6 and t < 3.4:
		var q := sin((t - 1.6) / 1.8 * 3.14) * 18.0
		c._r(52, 236 - q, 6, 28, Color("f0c8a0"))
		c._r(122, 236 - q, 6, 28, Color("f0c8a0"))
		c._big("AAAH!", 90, 120, 11, 1.0)
	if t < 1.6:
		c._text("Zzz", Vector2(108, 210.0 - t * 8.0), 8.0, Color("8a98c8"))
	if t > 3.4:
		var confetti := [Color("ff5a5a"), Color("ffe14a"), Color("5ac8ff"), Color("7aff7a")]
		for i in 60:
			c._r(LevelIntro._rnd(i) * 180.0, fposmod(LevelIntro._rnd(i + 8.0) * 340.0 + t * 50.0 * (0.5 + LevelIntro._rnd(i + 3.0)), 340.0) - 10.0, 3, 3, confetti[i % 4])
	if t >= 4.2:
		var friends := ["macrophage", "neutrophil", "t-lymphocyte", "b-lymphocyte", "interferon", "lysozyme"]
		for i in friends.size():
			c._spr("tower_" + friends[i], 6.0 + i * 28.0, 262.0 - absf(sin(t * 5.0 + i)) * 10.0, 26.0)
