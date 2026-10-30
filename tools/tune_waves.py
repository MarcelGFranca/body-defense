"""Finds the wave scale each level needs to reach a target difficulty, using playtests.

For several multipliers of the current wave scales it plays every level in parallel with the ten bot
strategies, measures the average body health left (as a fraction), and picks, for each level, the
multiplier whose result is closest to the target. Then it writes the new scales into generate_data.gd.

Usage: python3 -I tools/tune_waves.py [--apply]
"""
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
GENERATE = os.path.join(ROOT, "tools", "generate_data.gd")
MULTIPLIERS = [0.4, 0.55, 0.7, 0.85, 1.0, 1.25, 1.6, 2.0]
GAMES = 20
# Average share of the body's health that is left (over all ten strategies) that each level aims for.
TARGET = {2: 0.60, 3: 0.50, 4: 0.50, 5: 0.45, 6: 0.42, 7: 0.38, 8: 0.40, 9: 0.35, 10: 0.30}


def run(command, env=None):
    return subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True)


def play(level, mult):
    out = "res://playtests/tune/m%s_L%d" % (mult, level)
    run(["godot", "--headless", "--path", ".", "--fixed-fps", "60", "res://tools/playtest.tscn", "--", "--games", str(GAMES),
         "--level", str(level), "--out", out])
    path = os.path.join(ROOT, "playtests", "tune", "m%s_L%d" % (mult, level), "games.jsonl")
    games = [json.loads(line) for line in open(path, encoding="utf-8")]
    return sum(g["health"] / g["health_max"] for g in games) / len(games)


def main():
    results = {}
    for mult in MULTIPLIERS:
        env = dict(os.environ, BD_SCALE_MULT=str(mult))
        run(["godot", "--headless", "--path", ".", "--script", "res://tools/generate_data.gd"], env=env)
        with ThreadPoolExecutor(max_workers=8) as pool:
            scores = list(pool.map(lambda level: play(level, mult), sorted(TARGET)))
        for level, score in zip(sorted(TARGET), scores):
            results[(level, mult)] = score
        print("multiplier %.2f: %s" % (mult, " ".join("L%d=%.2f" % (l, sc) for l, sc in zip(sorted(TARGET), scores))), flush=True)
    text = open(GENERATE, encoding="utf-8").read()
    chosen = {}
    for level in sorted(TARGET):
        # health left falls as the multiplier grows: interpolate where it crosses the target
        points = [(m, results[(level, m)]) for m in MULTIPLIERS]
        best = min(points, key=lambda p: abs(p[1] - TARGET[level]))[0]
        for (m1, s1), (m2, s2) in zip(points, points[1:]):
            if s1 >= TARGET[level] >= s2 and s1 != s2:
                best = m1 + (m2 - m1) * (s1 - TARGET[level]) / (s1 - s2)
                break
        chosen[level] = best
        print("level %d: multiplier %.2f (target %.2f)" % (level, best, TARGET[level]))
    if "--apply" in sys.argv:
        for level, mult in chosen.items():
            pattern = r'(\{"number": %d, "name": "[^"]+", "part": "[^"]+",(?: "scale": )?)([\d.]*)' % level
            match = re.search(r'\{"number": %d, "name": "[^"]+", "part": "[^"]+", "scale": ([\d.]+)' % level, text)
            old = float(match.group(1)) if match else 1.0
            new = round(old * mult, 2)
            if match:
                text = re.sub(r'(\{"number": %d, "name": "[^"]+", "part": "[^"]+", "scale": )[\d.]+' % level, r"\g<1>%s" % new, text)
            else:
                text = re.sub(r'(\{"number": %d, "name": "[^"]+", "part": "[^"]+",)' % level, r'\1 "scale": %s,' % new, text)
        open(GENERATE, "w", encoding="utf-8").write(text)
        run(["godot", "--headless", "--path", ".", "--script", "res://tools/generate_data.gd"])
        print("scales written to generate_data.gd")


if __name__ == "__main__":
    main()
