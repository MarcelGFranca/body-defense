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


def music():
    bpm = 120
    beat = 60.0 / bpm
    eighth = beat / 2
    bars = 8
    total = bars * 4 * beat
    out = silence(total)
    # Am, F, C, G: two bars each. Root for the bass, chord for the arpeggio, eight-note lead pattern.
    chords = [
        ("A2", ["A3", "C4", "E4"], ["E5", "D5", "C5", "D5", "E5", "E5", "G5", "E5", "D5", "C5", "A4", "C5", "D5", "D5", "E5", None]),
        ("F2", ["F3", "A3", "C4"], ["C5", "C5", "A4", "C5", "F5", "E5", "C5", "A4", "A4", "C5", "E5", "D5", "C5", "A4", "F4", None]),
        ("C3", ["C4", "E4", "G4"], ["G4", "C5", "E5", "G5", "E5", "C5", "E5", "D5", "C5", "E5", "G5", "E5", "D5", "C5", "G4", None]),
        ("G2", ["G3", "B3", "D4"], ["D5", "D5", "B4", "D5", "G5", "F5", "D5", "B4", "A4", "B4", "D5", "E5", "D5", "B4", "G4", None]),
    ]
    for index, (root, chord, lead) in enumerate(chords):
        start = index * 8 * beat
        for step in range(16):  # eighth notes over two bars
            at = start + step * eighth
            if step % 2 == 0:  # bass on every beat
                d = beat * 0.9
                place(out, triangle(np.full(int(SR * d), note(root))) * decay(d, 0.35, 0.004) * 0.55, at)
            if lead[step]:
                d = eighth * 1.7
                freq = np.full(int(SR * d), note(lead[step]))
                place(out, square(freq, 0.25) * decay(d, 0.16, 0.004) * 0.26, at)
            # a quiet arpeggio in sixteenths
            for half in range(2):
                d = eighth / 2 * 0.9
                tone = note(chord[(step * 2 + half) % 3])
                place(out, square(np.full(int(SR * d), tone), 0.5) * decay(d, 0.05, 0.002) * 0.07, at + half * eighth / 2)
            if step % 2 == 1:  # a hat on the off beats
                place(out, noise(0.04, step + 100 * index, 2) * decay(0.04, 0.012, 0.001) * 0.10, at)
    return out


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
    save(os.path.join(ROOT, "music", "garganta.wav"), music(), peak=0.7)
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
    music_length = length(os.path.join(ROOT, "music", "garganta.wav"))
    if abs(music_length - 16.0) > 0.05:
        problems.append("the music loop should be 16 s, found %.2f s" % music_length)
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
