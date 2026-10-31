#!/usr/bin/env python3
"""Synthesises the sound of every level intro and of the ending into assets/audio/common/ (intro_level1.wav, intro_2.wav ... intro_10.wav, intro_end.wav).
Cue times match game/intro.gd and game/intro_stories.gd. Usage: python3 tools/generate_intro_sound.py [story ...]"""
import math, random, wave
import numpy as np

SR = 22050
DUR = 11.4
T = {"wind": 3.6, "choo": 4.8, "after": 5.7, "zoom": 6.3, "throat": 7.2}
rng = random.Random(7)
np_rng = np.random.default_rng(7)


def rnd(i):
	v = math.sin(i * 127.1 + 311.7) * 43758.5453
	return v - math.floor(v)


def syl(start, end, seed):
	out, t, i = [], start, seed
	while t < end - 0.12:
		d = 0.09 + rnd(i) * 0.07; i += 1
		r = rnd(i); i += 1
		out.append((t, d, r))
		t += d + 0.04 + rnd(i) * 0.12; i += 1
	return out


TALK = {"A": syl(0.3, 1.7, 1), "B": syl(1.9, 3.5, 100)}
out = np.zeros(int((DUR + 0.5) * SR))


def reset(duration):
	global out, DUR
	DUR = duration
	out = np.zeros(int((duration + 0.5) * SR))



def envelope(n, attack, peak, decay):
	t = np.arange(n) / SR
	g = np.full(n, 0.0001)
	a = t < attack
	g[a] = 0.0001 + (peak - 0.0001) * (t[a] / max(attack, 1e-6))
	d = (t >= attack) & (t < attack + decay)
	g[d] = peak * (0.0001 / peak) ** ((t[d] - attack) / decay)
	return g


def biquad(x, kind, f0, f1, q):
	"""Filter with a cutoff that sweeps exponentially from f0 to f1, in blocks of 64 samples."""
	n = len(x)
	y = np.zeros(n)
	x1 = x2 = y1 = y2 = 0.0
	for i in range(n):
		if i % 64 == 0:
			f = f0 * (f1 / f0) ** (i / max(n - 1, 1))
			w = 2 * math.pi * min(f, SR * 0.45) / SR
			al = math.sin(w) / (2 * q)
			cw = math.cos(w)
			if kind == "bandpass":
				b0, b1, b2 = al, 0.0, -al
			elif kind == "lowpass":
				b0, b1, b2 = (1 - cw) / 2, 1 - cw, (1 - cw) / 2
			else:
				b0, b1, b2 = (1 + cw) / 2, -(1 + cw), (1 + cw) / 2
			a0, a1, a2 = 1 + al, -2 * cw, 1 - al
			b0, b1, b2, a1, a2 = b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0
		v = b0 * x[i] + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2, x1, y2, y1 = x1, x[i], y1, v
		y[i] = v
	return y


def add(start, sig):
	i = int(start * SR)
	out[i:i + len(sig)] += sig[:len(out) - i]


def osc(kind, f0, f1, n):
	t = np.arange(n) / SR
	f = f0 * (f1 / f0) ** (t / (n / SR)) if f0 != f1 else np.full(n, f0)
	ph = np.cumsum(f) / SR
	if kind == "sine":
		return np.sin(2 * math.pi * ph)
	if kind == "triangle":
		return 2 * np.abs(2 * (ph % 1) - 1) - 1
	if kind == "square":
		return np.where((ph % 1) < 0.5, 1.0, -1.0)
	return 2 * (ph % 1) - 1


def tone(start, dur, f0, f1, kind, peak):
	n = int((dur + 0.1) * SR)
	add(start, osc(kind, f0, f1, n) * envelope(n, 0.01, peak, dur))


def noise(start, dur, kind, f0, f1, peak, attack=0.02):
	n = int((dur + 0.1) * SR)
	sig = biquad(np_rng.uniform(-1, 1, n), kind, f0, f1, 1.2 if kind == "bandpass" else 0.8)
	add(start, sig * envelope(n, attack, peak, dur))


def voice(start, dur, f0, f1, f2, peak):
	n = int((dur + 0.1) * SR)
	end = f0 * (0.9 + rng.random() * 0.25)
	src = osc("sawtooth", f0, end, n) if end != f0 else osc("sawtooth", f0, f0, n)
	body = (biquad(src, "bandpass", f1, f1, 6) + biquad(src, "bandpass", f2, f2, 6)) * 10.0
	add(start, body * envelope(n, 0.02, peak, dur))


VOW = [(700, 1200), (500, 1800), (350, 2300), (450, 800), (300, 700)]


def mumble(start, end, pitch, seed):
	for s in syl(start, end, seed):
		v = VOW[int(s[2] * 5) % 5]
		voice(s[0], s[1], pitch * (0.85 + s[2] * 0.5), v[0], v[1], 0.16)


def whoosh(s):
	noise(s, 0.95, "bandpass", 3500, 150, 0.55, 0.25)
	tone(s, 1.0, 420, 40, "sine", 0.35)


def thump(s):
	tone(s, 0.16, 80, 40, "sine", 0.7)
	tone(s + 0.17, 0.14, 70, 38, "sine", 0.5)


def heart(a, b):
	s = a
	while s < b:
		thump(s)
		s += 0.833


def inhale(s, d):
	noise(s, d, "bandpass", 500, 2200, 0.3, d * 0.5)
	tone(s, d, 260, 520, "triangle", 0.06)


def cough(s):
	noise(s, 0.16, "bandpass", 1200, 500, 0.6, 0.005)
	tone(s, 0.18, 180, 90, "sawtooth", 0.2)
	noise(s + 0.2, 0.14, "bandpass", 1200, 500, 0.5, 0.005)
	tone(s + 0.2, 0.16, 170, 80, "sawtooth", 0.18)


def gulp(s):
	tone(s, 0.14, 220, 70, "sine", 0.7)
	tone(s + 0.18, 0.12, 200, 60, "sine", 0.5)


def glug(s, n):
	for i in range(n):
		tone(s + i * 0.17, 0.1, 260 + (i % 2) * 90, 120, "sine", 0.5)


def crunch(s, n):
	for i in range(n):
		noise(s + i * 0.11, 0.06, "highpass", 2000, 6000, 0.5, 0.002)


def buzz(s, d):
	n = int(d * SR)
	t = np.arange(n) / SR
	ph = np.cumsum(330 + 60 * np.sin(2 * math.pi * 42 * t)) / SR
	g = np.interp(t, [0, 0.1, d - 0.1, d], [0.0, 0.08, 0.08, 0.0])
	add(s, (2 * (ph % 1) - 1) * g)


def crash(s):
	noise(s, 0.5, "lowpass", 8000, 300, 0.9, 0.003)
	tone(s, 0.3, 150, 40, "sine", 0.9)
	for i in range(4):
		tone(s + 0.05 + i * 0.06, 0.05, 900 + i * 200, 300, "square", 0.12)


def slap(s):
	noise(s, 0.12, "highpass", 1500, 5000, 0.8, 0.002)
	tone(s, 0.15, 200, 60, "sine", 0.7)


def boing(s):
	tone(s, 0.35, 200, 900, "sine", 0.35)


def thunder(s):
	noise(s, 1.6, "lowpass", 2000, 60, 1.0, 0.03)
	tone(s, 1.2, 70, 30, "sawtooth", 0.35)


def stomp(s):
	tone(s, 0.25, 70, 30, "sine", 0.9)
	noise(s, 0.2, "lowpass", 500, 80, 0.6, 0.003)


def note(s, d, f, kind="square", p=0.1):
	tone(s, d, f, f, kind, p)


def fanfare(s):
	for i, f in enumerate([523, 659, 784, 1047, 784, 1047]):
		note(s + i * 0.16, 0.8 if i == 5 else 0.15, f, "square", 0.12)
	for i, f in enumerate([262, 330, 392, 523]):
		note(s + i * 0.16, 0.15, f, "triangle", 0.15)


def cheer(s, d):
	noise(s, d, "bandpass", 900, 1800, 0.35, d * 0.3)
	for i in range(10):
		voice(s + i * d / 10, 0.3, 300 + rng.random() * 250, 700, 1400, 0.08)


def explode(s):
	noise(s, 0.9, "lowpass", 9000, 100, 1.0, 0.003)
	tone(s, 0.6, 120, 25, "sine", 0.9)


def drone(s, d, f, p):
	n = int(d * SR)
	t = np.arange(n) / SR
	g = np.interp(t, [0, 0.8, d - 0.8, d], [0.0, p, p, 0.0])
	for k in (1.0, 1.01):
		add(s, biquad(osc("sawtooth", f * k, f * k, n), "lowpass", 220, 220, 0.8) * g * 3)


def arrivals(s, n):
	for i in range(n):
		tone(s + 0.8 + i * 0.42, 0.12, 380, 140, "sine", 0.12)


def typing(s):
	for i in range(10):
		note(s + i * 0.07, 0.05, 500 + (i % 3) * 150, "square", 0.05)


def organ_part(tt, heart_to, drone_len, extra=()):
	heart(tt, heart_to)
	drone(tt, drone_len, 48, 0.2)
	arrivals(tt, 8)
	typing(tt + 3.0)


def save(name):
	global out
	sig = out[:int(DUR * SR)]
	sig = sig / max(1e-6, np.max(np.abs(sig))) * 0.85
	with wave.open("assets/audio/common/%s.wav" % name, "wb") as w:
		w.setnchannels(1)
		w.setsampwidth(2)
		w.setframerate(SR)
		w.writeframes((sig * 32767).astype(np.int16).tobytes())
	print("wrote", name, round(len(sig) / SR, 1), "s")


def story1():
	reset(11.4)
	for who, pitch in (("A", 150), ("B", 230)):
		for s in TALK[who]:
			v = VOW[int(s[2] * 5) % 5]
			voice(s[0], s[1], pitch * (0.85 + s[2] * 0.5), v[0], v[1], 0.16)
	for i in range(3):
		st = T["wind"] + i * 0.38
		noise(st, 0.34, "bandpass", 500 + i * 500, 1800 + i * 900, 0.2 + i * 0.07, 0.2)
		tone(st, 0.34, 260 + i * 90, 420 + i * 150, "triangle", 0.05 + i * 0.02)
	k = T["choo"]
	noise(k, 0.5, "lowpass", 9000, 300, 0.9, 0.005)
	noise(k, 0.18, "highpass", 1500, 5000, 0.5, 0.003)
	tone(k, 0.35, 140, 38, "sine", 0.9)
	tone(k + 0.03, 0.28, 1100, 260, "square", 0.12)
	tone(k + 0.35, 0.22, 700, 180, "sawtooth", 0.08)
	for i in range(7):
		noise(k + 0.25 + i * 0.07, 0.05, "bandpass", 2500, 1800, 0.18, 0.002)
	for i, f in enumerate([233, 220, 208, 196]):
		tone(T["after"] + 0.05 + i * 0.17, 0.5 if i == 3 else 0.2, f, f * (0.9 if i == 3 else 1), "sawtooth", 0.2)
	whoosh(T["zoom"])
	t0 = T["throat"]
	n = int((DUR - t0) * SR)
	t = np.arange(n) / SR
	gain = np.interp(t, [0, 0.8, 10.6 - t0, DUR - t0], [0.0, 0.3, 0.3, 0.0])
	add(t0, np.sin(2 * math.pi * np.cumsum(np.full(n, 48.0)) / SR) * gain)
	heart(t0, 10.8)
	arrivals(t0 + 0.85, 8)
	for i in range(10):
		f = 500 + (i % 3) * 150
		tone(9.0 + i * 0.07, 0.05, f, f, "square", 0.05)
	save("intro_level1")


def story(n, duration, tt, build):
	reset(duration)
	build()
	save("intro_%s" % n)


def s2():
	noise(1.0, 0.12, "highpass", 2000, 6000, 0.5, 0.002)
	noise(1.15, 0.1, "highpass", 2000, 6000, 0.4, 0.002)
	noise(1.8, 0.6, "lowpass", 3000, 200, 0.9, 0.005)
	tone(1.8, 0.3, 120, 40, "sine", 0.7)
	for i in range(3):
		inhale(2.6 + i * 0.55, 0.5)
	cough(4.2)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s3():
	for s in (1.0, 1.5, 2.0):
		cough(s)
	for i in range(4):
		s = 0.2 + i * 0.9
		noise(s, 0.4, "bandpass", 300, 600, 0.12, 0.2)
		tone(s, 0.45, 95, 70, "sawtooth", 0.05)
	inhale(3.4, 0.5)
	whoosh(4.6)
	organ_part(5.6, 10.4, 5)
	stomp(8.6)


def s4():
	mumble(0.2, 0.9, 200, 5)
	tone(1.0, 0.3, 500, 200, "sine", 0.2)
	noise(1.55, 0.14, "lowpass", 2500, 300, 0.6, 0.003)
	tone(1.55, 0.1, 150, 80, "sine", 0.6)
	note(1.9, 0.1, 1400, "sine", 0.1)
	buzz(0.3, 2.7)
	crunch(3.25, 4)
	gulp(3.9)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s5():
	mumble(0.2, 1.4, 230, 9)
	glug(2.8, 6)
	voice(4.0, 0.6, 250, 500, 1400, 0.2)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s6():
	mumble(0.2, 1.3, 200, 13)
	noise(1.5, 0.2, "bandpass", 1800, 600, 0.6, 0.003)
	tone(1.55, 0.15, 260, 140, "square", 0.1)
	for i in range(8):
		tone(1.8 + i * 0.22, 0.1, 220 - (i % 2) * 40, 120, "sine", 0.4)
	for i in range(14):
		tone(3.7 + i * 0.07, 0.1, 70 + (i % 3) * 8, 50, "sawtooth", 0.3)
	voice(3.9, 0.7, 300, 500, 1300, 0.14)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s7():
	for i in range(7):
		noise(0.1 + i * 0.18, 0.15, "bandpass", 800, 1200, 0.12, 0.03)
	boing(1.4)
	whoosh(1.9)
	crash(2.8)
	voice(3.0, 0.6, 260, 500, 1400, 0.2)
	whoosh(4.2)
	organ_part(5.2, 10.4, 5.2)
	stomp(8.4)


def s8():
	mumble(0.2, 1.3, 230, 21)
	noise(1.4, 0.3, "highpass", 3000, 6000, 0.3, 0.02)
	noise(2.4, 0.7, "bandpass", 600, 2500, 0.7, 0.1)
	tone(2.4, 0.7, 400, 900, "sine", 0.15)
	gulp(3.8)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s9():
	for i in range(14):
		note(0.2 + i * 0.35, 0.12, 3600 + (i % 3) * 300, "square", 0.025)
	buzz(0.5, 2.4)
	noise(2.9, 0.5, "bandpass", 2500, 2500, 0.04, 0.2)
	slap(3.5)
	voice(4.0, 0.5, 260, 500, 1400, 0.2)
	boing(3.6)
	whoosh(4.6)
	organ_part(5.6, 10.2, 5)


def s10():
	drone(0.0, 4.4, 55, 0.12)
	thunder(1.2)
	thunder(2.2)
	cough(3.6)
	voice(2.7, 0.7, 250, 500, 1400, 0.2)
	whoosh(4.4)
	organ_part(5.4, 10.4, 5.8)
	stomp(7.0)
	stomp(7.9)
	thunder(8.0)


def s11():
	for i in range(6):
		slap(0.2 + i * 0.28)
	explode(1.9)
	fanfare(2.5)
	cheer(3.0, 3.0)
	whoosh(3.6)
	for i, f in enumerate([392, 440, 494, 523]):
		note(4.8 + i * 0.3, 0.25, f, "triangle", 0.1)
	fanfare(6.6)
	cheer(7.0, 4)
	for i in range(10):
		note(10.4 + i * 0.15, 0.12, [523, 659, 784][i % 3], "square", 0.06)
	heart(4.6, 6.0)


STORIES = {"1": story1}
for number, (duration, build) in {"2": (10.6, s2), "3": (10.8, s3), "4": (10.6, s4), "5": (10.6, s5), "6": (10.6, s6), "7": (10.8, s7),
		"8": (10.6, s8), "9": (10.6, s9), "10": (11.6, s10), "end": (13.4, s11)}.items():
	STORIES[number] = (lambda n=number, d=duration, b=build: story(n, d, 0, b))
import sys
for key in (sys.argv[1:] or list(STORIES)):
	STORIES[key]()
