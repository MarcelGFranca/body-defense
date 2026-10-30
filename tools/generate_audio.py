"""Generates every sound effect and the level music in a retro 16-bit style (22,050 Hz, mono WAV).

Usage: python3 -I tools/generate_audio.py            # writes assets/audio/
       python3 -I tools/generate_audio.py --check    # also measures the files and exits 1 on problems
"""
import os
import sys
import wave

import numpy as np

SR = 22050
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "audio")

# id -> (base pitch in Hz, is boss). Viruses are thin and high, bacteria rounder and lower, bosses deepest.
ENEMIES = {
    "rhinovirus": (700, False), "influenza": (900, False), "sars-cov-2": (600, False),
    "herpes-simplex": (520, False), "hpv": (450, False),
    "e-coli": (400, False), "streptococcus-pyogenes": (480, False), "staphylococcus-aureus": (380, False),
    "helicobacter-pylori": (350, False), "clostridioides-difficile": (330, False),
    "hiv": (200, True), "mycobacterium-tuberculosis": (150, True), "neisseria-meningitidis": (180, True),
}
VIRUSES = {"rhinovirus", "influenza", "sars-cov-2", "herpes-simplex", "hpv", "hiv"}
TOWERS = ["macrophage", "neutrophil", "mucus-cell", "platelet", "hypothalamus", "lysozyme", "interferon",
          "t-lymphocyte", "b-lymphocyte", "bone-marrow"]


# --- building blocks ---------------------------------------------------------

def time(duration):
    return np.arange(int(SR * duration)) / SR


def sweep(f0, f1, duration):
    """Frequency curve that slides exponentially from f0 to f1."""
    t = time(duration)
    return f0 * (f1 / f0) ** (t / duration)


def phase(freq):
    return np.cumsum(freq) / SR


def square(freq, duty=0.5):
    return np.where(phase(freq) % 1.0 < duty, 1.0, -1.0)


def triangle(freq):
    return 4.0 * np.abs(phase(freq) % 1.0 - 0.5) - 1.0


def noise(duration, seed, hold=1):
    """White noise; `hold` repeats each value for a grainier, lower sound."""
    rng = np.random.default_rng(seed)
    n = int(SR * duration)
    values = rng.uniform(-1.0, 1.0, n // hold + 1)
    return np.repeat(values, hold)[:n]


def decay(duration, tau, attack=0.003):
    t = time(duration)
    return np.minimum(t / max(attack, 1e-6), 1.0) * np.exp(-t / tau)


def lowpass(x, width):
    return np.convolve(x, np.ones(width) / width, mode="same")


def highpass(x, width):
    return x - lowpass(x, width)


def crush(x, bits=6):
    steps = 2 ** (bits - 1)
    return np.round(x * steps) / steps


def silence(duration):
    return np.zeros(int(SR * duration))


def place(base, part, at):
    start = int(SR * at)
    end = min(len(base), start + len(part))
    base[start:end] += part[:end - start]
    return base


def save(path, samples, peak=0.8):
    samples = np.asarray(samples, dtype=np.float64)
    top = np.max(np.abs(samples))
    if top > 0:
        samples = samples / top * peak
    fade = int(SR * 0.004)
    samples[:fade] *= np.linspace(0, 1, fade)
    samples[-fade:] *= np.linspace(1, 0, fade)
    data = (samples * 32767).astype("<i2").tobytes()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SR)
        f.writeframes(data)


# --- enemies -----------------------------------------------------------------

def enemy_hit(f0, virus, boss):
    duration = 0.16 if boss else 0.09
    wave_ = square(sweep(f0, f0 * 0.6, duration), 0.25 if virus else 0.5)
    return crush(wave_ * decay(duration, duration / 3)) + 0.2 * noise(duration, 1, 3) * decay(duration, 0.015)


def enemy_attack(f0, virus, boss):
    duration = 0.34 if boss else 0.2
    t = time(duration)
    freq = sweep(f0 * 1.2, f0 * 0.8, duration) * (1 + 0.07 * np.sin(2 * np.pi * 14 * t))
    body = square(freq, 0.25 if virus else 0.5) * 0.7 + triangle(freq / 2) * 0.5
    gate = np.where(np.sin(2 * np.pi * 30 * t) > -0.3, 1.0, 0.45)
    return crush(body * gate * decay(duration, duration / 1.6, 0.008), 7)


def enemy_death(f0, virus, boss):
    duration = 0.75 if boss else 0.32
    pop = square(sweep(f0 * 1.5, f0 * 0.25, duration), 0.25 if virus else 0.5) * decay(duration, duration / 3)
    burst = noise(duration, 7, 2) * decay(duration, duration / 6)
    sound = pop * 0.8 + burst * 0.6
    if boss:
        rumble = triangle(sweep(f0 * 0.6, f0 * 0.15, duration)) * decay(duration, duration / 2)
        sound = sound + rumble * 0.9
    return crush(sound, 6)


# --- towers ------------------------------------------------------------------

def tower_sound(name):
    if name == "macrophage":  # a wet chomp
        d = 0.18
        return lowpass(noise(d, 11), 5) * decay(d, 0.05) * 1.4 + triangle(sweep(240, 80, d)) * decay(d, 0.06)
    if name == "neutrophil":  # a quick tick
        d = 0.05
        return square(sweep(1300, 900, d), 0.25) * decay(d, 0.02) + 0.3 * noise(d, 12, 2) * decay(d, 0.01)
    if name == "mucus-cell":  # a wet splat with a bubble
        d = 0.3
        bubble = triangle(sweep(450, 150, d)) * (0.6 + 0.4 * np.sin(2 * np.pi * 22 * time(d))) * decay(d, 0.1)
        return lowpass(noise(d, 13), 9) * decay(d, 0.06) * 1.6 + bubble
    if name == "platelet":  # a double click
        out = silence(0.16)
        for at in (0.0, 0.07):
            place(out, square(sweep(900, 600, 0.04), 0.25) * decay(0.04, 0.015), at)
        return out
    if name == "hypothalamus":  # a warm hum that rises
        d = 0.34
        return triangle(sweep(200, 420, d)) * (0.75 + 0.25 * np.sin(2 * np.pi * 12 * time(d))) * decay(d, 0.2, 0.03)
    if name == "lysozyme":  # fizzing
        d = 0.28
        return highpass(noise(d, 14), 6) * decay(d, 0.1) + 0.3 * square(sweep(2000, 1100, d), 0.25) * decay(d, 0.08)
    if name == "interferon":  # a rising pulse with an echo
        d = 0.3
        pulse = square(sweep(300, 1200, d), 0.5) * decay(d, 0.12, 0.01)
        out = silence(d + 0.14)
        place(out, pulse, 0.0)
        place(out, pulse * 0.4, 0.09)
        return out
    if name == "t-lymphocyte":  # a sharp zap
        d = 0.16
        return square(sweep(1800, 300, d), 0.25) * decay(d, 0.06) + 0.4 * noise(d, 15, 2) * decay(d, 0.03)
    if name == "b-lymphocyte":  # a soft bloop
        d = 0.22
        t = time(d)
        freq = 400 + 400 * np.sin(np.pi * t / d)
        return triangle(freq) * decay(d, 0.12, 0.01)
    if name == "bone-marrow":  # pop, pop
        out = silence(0.2)
        for at in (0.0, 0.1):
            place(out, triangle(sweep(520, 240, 0.08)) * decay(0.08, 0.03), at)
        return out
    raise ValueError(name)


def blocked_sound():
    d = 0.14
    ping = square(np.full(int(SR * d), 1500.0), 0.5) * 0.6 + square(np.full(int(SR * d), 2250.0), 0.5) * 0.3
    return ping * decay(d, 0.045, 0.001)


# --- music -------------------------------------------------------------------

NOTE_INDEX = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}


def note(name):
    """Frequency of a note name such as "A4" or "E5"."""
    octave = int(name[-1])
    semitone = NOTE_INDEX[name[0]] + (1 if "#" in name else 0)
    return 440.0 * 2 ** ((semitone - 9 + 12 * (octave - 4)) / 12)


# Triads by name: bass root, then the chord tones used by the keyboard.
CHORDS = {
    "Am": ("A2", ["A4", "C5", "E5", "A5"]),
    "F": ("F2", ["F4", "A4", "C5", "F5"]),
    "C": ("C3", ["E4", "G4", "C5", "E5"]),
    "G": ("G2", ["D4", "G4", "B4", "D5"]),
    "E": ("E2", ["E4", "G#4", "B4", "E5"]),
}

# One bar of the lead = 16 sixteenths; "_" holds the previous note and "-" is a rest.
LEAD_A = [
    ("Am", "E5 _ _ _ A5 _ _ G5 E5 _ _ _ C5 _ D5 E5"),
    ("F", "F5 _ _ _ A5 _ _ C6 A5 _ _ G5 F5 _ E5 F5"),
    ("C", "G5 _ _ _ E5 _ _ G5 C6 _ _ _ B5 _ G5 E5"),
    ("G", "D5 _ _ _ G5 _ _ B5 A5 _ _ G5 D5 _ E5 D5"),
    ("Am", "E5 _ _ _ A5 _ _ G5 E5 _ _ _ C6 _ B5 A5"),
    ("F", "A5 _ _ _ C6 _ _ A5 F5 _ _ _ A5 _ C6 _"),
    ("G", "B5 _ _ B5 D6 _ _ B5 G5 _ _ _ A5 _ B5 _"),
    ("E", "E5 _ G#5 _ B5 _ _ _ E6 _ _ _ _ _ - -"),
]
LEAD_B = [
    ("F", "C6 _ _ _ _ _ A5 _ C6 _ _ _ D6 _ C6 _"),
    ("G", "B5 _ _ _ _ _ G5 _ B5 _ _ _ C6 _ D6 _"),
    ("Am", "E6 _ _ _ _ _ C6 _ A5 _ _ _ C6 _ E6 _"),
    ("C", "G6 _ _ _ E6 _ _ _ C6 _ E6 _ G6 _ _ _"),
    ("F", "A5 _ C6 _ F6 _ _ _ E6 _ C6 _ A5 _ C6 _"),
    ("G", "D6 _ _ _ B5 _ D6 _ G6 _ _ _ F6 _ D6 _"),
    ("E", "E6 _ _ G#5 B5 _ _ E6 D6 _ B5 _ G#5 _ B5 _"),
    ("E", "E6 _ _ _ _ _ _ _ _ _ _ _ _ _ - -"),
]
INTRO = [("Am", None)] * 2
OUTRO = [("F", None), ("G", None), ("E", None), ("E", None)]

# Section plan: name, bars, keyboard 2 style. Intro 2 + A 8 + B 8 + A again 8 + outro 4 = 30 bars.
SECTIONS = [
    ("intro", INTRO, "arp"), ("a", LEAD_A, "stab"), ("b", LEAD_B, "pad"),
    ("a", LEAD_A, "arp"), ("outro", OUTRO, "pad"),
]
# Bass: eighth notes, "r" = root, "o" = octave up.
BASS_DRIVE = "r r o r r o r o".split()
BASS_HALF = "r o r o r o r o".split()


def envelope(duration, attack=0.004, tau=0.5, sustain=0.6, release=0.02):
    t = time(duration)
    body = sustain + (1.0 - sustain) * np.exp(-t / tau)
    return np.minimum(t / attack, 1.0) * body * np.minimum((duration - t) / release, 1.0)


def lead_note(name, duration):
    """Keyboard 1: two slightly detuned narrow pulses with a late vibrato."""
    t = time(duration)
    freq = note(name) * (1 + 0.004 * np.sin(2 * np.pi * 5.5 * t) * np.minimum(t / 0.25, 1.0))
    tone = square(freq * 1.003, 0.25) + square(freq * 0.997, 0.25)
    return tone * envelope(duration, tau=0.35, sustain=0.55)


def keys_note(name, duration, soft=False):
    """Keyboard 2: a rounder, mellower tone (a pulse plus a triangle an octave down)."""
    freq = np.full(int(SR * duration), note(name))
    tone = lowpass(square(freq, 0.5), 3) * 0.6 + triangle(freq * 0.5) * 0.5
    if soft:
        return tone * envelope(duration, attack=0.12, tau=1.0, sustain=0.8, release=0.1)
    return tone * envelope(duration, attack=0.003, tau=0.12, sustain=0.15, release=0.01)


def bass_note(name, duration):
    """Bass keyboard: a low saw, filtered, over a sine-like sub."""
    freq = np.full(int(SR * duration), note(name))
    saw = 2.0 * (phase(freq) % 1.0) - 1.0
    return (lowpass(saw, 5) * 0.7 + triangle(freq) * 0.9) * envelope(duration, tau=0.18, sustain=0.45, release=0.015)


def parse_lead(text):
    """Turn a bar of 16 tokens into (step, note, length in steps)."""
    tokens = text.split()
    assert len(tokens) == 16, text
    notes = []
    for step, token in enumerate(tokens):
        if token == "_":
            notes[-1][2] += 1
        elif token != "-":
            notes.append([step, token, 1])
    return notes


def music():
    bpm = 144
    step = 60.0 / bpm / 4
    bar = step * 16
    bars = sum(len(section) for _, section, _ in SECTIONS)
    total = bars * bar
    lead, keys, bass = silence(total), silence(total), silence(total)
    index = 0
    for name, section, style in SECTIONS:
        for chord_name, lead_text in section:
            root, tones = CHORDS[chord_name]
            start = index * bar
            index += 1
            if lead_text:
                for at, pitch, length in parse_lead(lead_text):
                    d = length * step * 0.95
                    place(lead, lead_note(pitch, d), start + at * step)
            drive = BASS_DRIVE if name in ("a",) else BASS_HALF
            if name == "intro":
                drive = ["r", "-", "r", "-", "r", "-", "r", "-"]
            octave_up = root[:-1] + str(int(root[-1]) + 1)
            for eighth, kind in enumerate(drive):
                if kind != "-":
                    place(bass, bass_note(root if kind == "r" else octave_up, step * 1.8), start + eighth * 2 * step)
            if style == "stab":
                for at in (2, 6, 10, 14):
                    for tone in tones[:3]:
                        place(keys, keys_note(tone, step * 1.6), start + at * step)
            elif style == "arp":
                order = [0, 1, 2, 3, 2, 1]
                for at in range(16):
                    place(keys, keys_note(tones[order[at % len(order)]], step * 0.9), start + at * step)
            else:
                for tone in tones[:3]:
                    place(keys, keys_note(tone, bar * 0.98, soft=True), start)
    mix = lead * 0.24 + keys * 0.14 + bass * 0.34
    return mix


# --- the music of the other nine levels ------------------------------------------
# Every track is 50 s and has the same three voices as the first one. What changes is the key, the scale,
# the chords, the tempo (the section length decides how many bars fit in 50 s) and the melody (seeded).

SCALES = {
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "dorian": [0, 2, 3, 5, 7, 9, 10],
    "harmonic": [0, 2, 3, 5, 7, 8, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
}
# Rhythms of the lead in sixteenths: where a new note starts in a bar.
BUSY = [[0, 2, 4, 6, 8, 10, 12, 14], [0, 3, 6, 8, 11, 14], [0, 4, 7, 8, 12, 14], [0, 2, 4, 8, 10, 12]]
SPARSE = [[0, 6, 8, 12], [0, 8], [0, 4, 8, 12], [0, 6, 10]]

TRACKS = {
    # name: root MIDI note, scale, chord degrees of section A, section B, outro, section length, bass style, seed
    "trachea": (62, "dorian", [0, 6, 5, 6], [3, 4, 0, 0], [3, 4, 6, 0], 7, "drive", 21),
    "lungs": (64, "harmonic", [0, 5, 6, 0], [3, 4, 5, 6], [5, 6, 4, 0], 9, "gallop", 31),
    "esophagus": (57, "dorian", [0, 3, 6, 4], [5, 3, 4, 0], [5, 4, 3, 0], 5, "half", 41),
    "stomach": (60, "minor", [0, 5, 2, 6], [3, 4, 0, 0], [3, 6, 4, 0], 6, "drive", 51),
    "intestines": (55, "minor", [0, 6, 5, 4], [2, 3, 4, 0], [5, 6, 4, 0], 8, "gallop", 61),
    "bloodstream": (59, "minor", [0, 5, 3, 4], [5, 6, 4, 0], [3, 4, 5, 0], 9, "gallop", 71),
    "liver": (62, "minor", [0, 2, 5, 6], [3, 5, 4, 0], [5, 6, 4, 0], 7, "drive", 81),
    "spleen": (57, "harmonic", [0, 3, 4, 0], [5, 6, 4, 4], [3, 4, 6, 0], 10, "gallop", 91),
    "lymph-nodes": (64, "harmonic", [0, 5, 2, 6], [3, 4, 5, 6], [5, 6, 4, 4], 10, "gallop", 101),
}
INTRO_BARS = 2
OUTRO_BARS = 4


def pitch(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def scale_midi(root, scale, degree):
    offsets = SCALES[scale]
    return root + offsets[degree % 7] + 12 * (degree // 7)


def chord_midis(root, scale, degree):
    return [scale_midi(root, scale, degree + k) for k in (0, 2, 4, 7)]


def make_lead(rng, root, scale, degree, templates, high, last):
    """One bar of lead as [(step, midi, length in steps)]: chord tones on the strong beats, scale steps between."""
    steps = list(templates[rng.integers(len(templates))])
    tones = [scale_midi(root, scale, degree + k) + 12 * high for k in (0, 2, 4)]
    notes = []
    current = scale_midi(root, scale, degree + int(rng.integers(0, 4))) + 12 * high
    for index, at in enumerate(steps):
        if at in (0, 8) or index == 0:
            current = tones[int(rng.integers(len(tones)))]
        else:
            current += [-2, -1, 0, 1, 2][int(rng.integers(5))] * (1 if current < tones[-1] + 5 else -1)
        if last and index == 0:
            current = tones[0]
        end = steps[index + 1] if index + 1 < len(steps) else 16
        notes.append((at, current, end - at))
    return notes


def compose(name):
    root, scale, prog_a, prog_b, prog_out, n, bass_style, seed = TRACKS[name]
    rng = np.random.default_rng(seed)
    bars = INTRO_BARS + 3 * n + OUTRO_BARS
    bpm = bars * 4.8  # 50 s
    step = 60.0 / bpm / 4
    bar = step * 16
    total = bars * bar
    lead, keys, bass = silence(total), silence(total), silence(total)

    plan = []  # (chord degree, section, bar index in the section, is last bar of a phrase)
    for i in range(INTRO_BARS):
        plan.append((prog_a[0], "intro", i))
    for section, prog in (("a", prog_a), ("b", prog_b), ("a2", prog_a)):
        for i in range(n):
            plan.append((prog[i % 4], section, i))
    for i in range(OUTRO_BARS):
        plan.append((prog_out[i % 4], "outro", i))

    for index, (degree, section, i) in enumerate(plan):
        start = index * bar
        bass_root = scale_midi(root - 24, scale, degree)
        tones = chord_midis(root, scale, degree)
        # lead
        if section in ("a", "a2", "b"):
            templates = SPARSE if section == "b" else BUSY
            last = i % 4 == 3
            for at, midi, length in make_lead(rng, root, scale, degree, templates, 1 if section != "b" else 2, last):
                d = length * step * 0.95
                place(lead, lead_note_midi(midi, d), start + at * step)
        # bass
        if section == "intro":
            pattern = ["r", "-", "r", "-", "r", "-", "r", "-"]
        elif section == "b" or bass_style == "half":
            pattern = ["r", "o", "r", "o", "r", "o", "r", "o"]
        else:
            pattern = ["r", "r", "o", "r", "r", "o", "r", "o"]
        if bass_style == "gallop" and section in ("a", "a2"):
            for at in range(0, 16):
                if at % 4 in (0, 1, 3):
                    midi = bass_root + (12 if at in (6, 14) else 0)
                    place(bass, bass_note_midi(midi, step * 1.6), start + at * step)
        else:
            for eighth, kind in enumerate(pattern):
                if kind != "-":
                    place(bass, bass_note_midi(bass_root + (12 if kind == "o" else 0), step * 1.8), start + eighth * 2 * step)
        # keyboard 2
        if section in ("a",):
            for at in (2, 6, 10, 14):
                for midi in tones[:3]:
                    place(keys, keys_note_midi(midi + 12, step * 1.6), start + at * step)
        elif section in ("intro", "a2"):
            order = [0, 1, 2, 3, 2, 1]
            for at in range(16):
                place(keys, keys_note_midi(tones[order[at % 6]] + 12, step * 0.9), start + at * step)
        else:
            for midi in tones[:3]:
                place(keys, keys_note_midi(midi + 12, bar * 0.98, soft=True), start)
    return lead * 0.24 + keys * 0.14 + bass * 0.34


def lead_note_midi(midi, duration):
    return lead_note_hz(pitch(midi), duration)


def lead_note_hz(freq_hz, duration):
    t = time(duration)
    freq = freq_hz * (1 + 0.004 * np.sin(2 * np.pi * 5.5 * t) * np.minimum(t / 0.25, 1.0))
    tone = square(freq * 1.003, 0.25) + square(freq * 0.997, 0.25)
    return tone * envelope(duration, tau=0.35, sustain=0.55)


def keys_note_midi(midi, duration, soft=False):
    freq = np.full(int(SR * duration), pitch(midi))
    tone = lowpass(square(freq, 0.5), 3) * 0.6 + triangle(freq * 0.5) * 0.5
    if soft:
        return tone * envelope(duration, attack=0.12, tau=1.0, sustain=0.8, release=0.1)
    return tone * envelope(duration, attack=0.003, tau=0.12, sustain=0.15, release=0.01)


def bass_note_midi(midi, duration):
    freq = np.full(int(SR * duration), pitch(midi))
    saw = 2.0 * (phase(freq) % 1.0) - 1.0
    return (lowpass(saw, 5) * 0.7 + triangle(freq) * 0.9) * envelope(duration, tau=0.18, sustain=0.45, release=0.015)


# --- run ---------------------------------------------------------------------

def generate():
    files = {}
    for enemy, (f0, boss) in ENEMIES.items():
        virus = enemy in VIRUSES
        for kind, make in (("hit", enemy_hit), ("attack", enemy_attack), ("death", enemy_death)):
            path = os.path.join(ROOT, "enemies", enemy, f"{kind}.wav")
            save(path, make(f0, virus, boss))
            files[path] = (enemy, kind, boss)
    for tower in TOWERS:
        path = os.path.join(ROOT, "towers", tower, "attack.wav")
        save(path, tower_sound(tower))
        files[path] = (tower, "attack", False)
    save(os.path.join(ROOT, "common", "block.wav"), blocked_sound())
    save(os.path.join(ROOT, "music", "throat.wav"), music(), peak=0.7)
    for name in TRACKS:
        save(os.path.join(ROOT, "music", "%s.wav" % name), compose(name), peak=0.7)
    return files


def length(path):
    with wave.open(path, "rb") as f:
        return f.getnframes() / f.getframerate()


def peak(path):
    with wave.open(path, "rb") as f:
        data = np.frombuffer(f.readframes(f.getnframes()), dtype="<i2")
    return np.max(np.abs(data)) / 32768.0


def check(files):
    problems = []
    for path in files:
        if length(path) <= 0.02:
            problems.append("%s is empty" % path)
        if peak(path) >= 0.99:
            problems.append("%s clips" % path)
    regular = [length(p) for p, (e, k, boss) in files.items() if k == "death" and not boss]
    bosses = [length(p) for p, (e, k, boss) in files.items() if k == "death" and boss]
    if min(bosses) <= max(regular):
        problems.append("boss deaths must last longer than regular deaths")
    music_length = length(os.path.join(ROOT, "music", "throat.wav"))
    for name in ["throat"] + list(TRACKS):
        track_length = length(os.path.join(ROOT, "music", "%s.wav" % name))
        if abs(track_length - 50.0) > 0.05:
            problems.append("the %s music loop should be 50 s, found %.2f s" % (name, track_length))
        if peak(os.path.join(ROOT, "music", "%s.wav" % name)) >= 0.99:
            problems.append("the %s music clips" % name)
    print("%d sounds, music %.2f s, longest enemy death %.2f s, longest regular death %.2f s" % (
        len(files), music_length, max(bosses), max(regular)))
    for problem in problems:
        print("problem:", problem)
    return not problems


if __name__ == "__main__":
    written = generate()
    if "--check" in sys.argv:
        sys.exit(0 if check(written) else 1)
    print("wrote %d sounds and the music" % len(written))
