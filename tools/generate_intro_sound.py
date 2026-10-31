#!/usr/bin/env python3
"""Synthesises the sound of the level 1 intro (talk mumble, sneeze, zoom, throat) into assets/audio/common/intro_level1.wav.
Timing matches game/intro.gd (same talk schedule, same cue times). Usage: python3 tools/generate_intro_sound.py"""
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
noise(T["zoom"], 0.95, "bandpass", 3500, 150, 0.55, 0.25)
tone(T["zoom"], 1.0, 420, 40, "sine", 0.35)
t0 = T["throat"]
n = int((DUR - t0) * SR)
t = np.arange(n) / SR
gain = np.interp(t, [0, 0.8, 10.6 - t0, DUR - t0], [0.0, 0.3, 0.3, 0.0])
add(t0, np.sin(2 * math.pi * np.cumsum(np.full(n, 48.0)) / SR) * gain)
b = t0
while b < 10.8:
	tone(b, 0.16, 80, 40, "sine", 0.7)
	tone(b + 0.17, 0.14, 70, 38, "sine", 0.5)
	b += 0.833
for i in range(8):
	tone(t0 + 0.6 + 0.25 + i * 0.42 + 0.8, 0.12, 380, 140, "sine", 0.12)
for i in range(10):
	f = 500 + (i % 3) * 150
	tone(9.0 + i * 0.07, 0.05, f, f, "square", 0.05)

out = out[:int(DUR * SR)]
out = out / max(1e-6, np.max(np.abs(out))) * 0.85
with wave.open("assets/audio/common/intro_level1.wav", "wb") as w:
	w.setnchannels(1)
	w.setsampwidth(2)
	w.setframerate(SR)
	w.writeframes((out * 32767).astype(np.int16).tobytes())
print("wrote assets/audio/common/intro_level1.wav", len(out) / SR, "s")
