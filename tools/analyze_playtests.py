"""Reads the games a playtest recorded and prints (and saves) a balance report.

Usage: python3 -I tools/analyze_playtests.py playtests/round_1 [playtests/round_2 ...]
Writes report.md next to games.jsonl.
"""
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
COSTS = {}


def load_costs():
    """Tower costs and enemy names from the generator table (one source of truth)."""
    text = open(os.path.join(ROOT, "tools", "generate_data.gd"), encoding="utf-8").read()
    for match in re.finditer(r'\{"id": "([a-z-]+)",[^\n]*?"cost": (\d+)', text):
        COSTS[match.group(1)] = int(match.group(2))


def games_of(folder):
    with open(os.path.join(folder, "games.jsonl"), encoding="utf-8") as fh:
        return [json.loads(line) for line in fh if line.strip()]


def pct(n, d):
    return 100.0 * n / d if d else 0.0


def ci(n, d):
    """Half width of the 95% confidence interval of a win rate, in percentage points."""
    if not d:
        return 0.0
    p = n / d
    return 196.0 * (p * (1 - p) / d) ** 0.5


def report(folder):
    games = games_of(folder)
    out = []
    w = out.append
    w("# Playtest report: %s (%d games, difficulty %s)\n" % (os.path.basename(folder), len(games), games[0]["difficulty"]))

    w("## By level\n")
    w("| level | name | games | win % | avg health left | avg time (s) | first leak (s) | avg amino left |")
    w("|---|---|---|---|---|---|---|---|")
    by_level = defaultdict(list)
    for g in games:
        by_level[g["level"]].append(g)
    for number in sorted(by_level):
        rows = by_level[number]
        wins = [g for g in rows if g["result"] == "won"]
        leaks = [g["first_leak_time"] for g in rows if g["first_leak_time"] >= 0]
        w("| %d | %s | %d | %.0f (+-%.0f) | %.1f/%d | %.0f | %s | %.0f |" % (
            number, rows[0]["level_name"], len(rows), pct(len(wins), len(rows)), ci(len(wins), len(rows)),
            sum(g["health"] for g in rows) / len(rows), rows[0]["health_max"],
            sum(g["time"] for g in rows) / len(rows),
            "%.0f" % (sum(leaks) / len(leaks)) if leaks else "-",
            sum(g["amino_end"] for g in rows) / len(rows)))

    w("\n## Win rate by level and strategy (%)\n")
    strategies = sorted({g["strategy"] for g in games})
    w("| level | " + " | ".join(strategies) + " |")
    w("|---|" + "---|" * len(strategies))
    for number in sorted(by_level):
        cells = []
        for name in strategies:
            rows = [g for g in by_level[number] if g["strategy"] == name]
            cells.append("%.0f" % pct(sum(g["result"] == "won" for g in rows), len(rows)) if rows else "-")
        w("| %d | %s |" % (number, " | ".join(cells)))

    w("\n## How the games end, by level\n")
    w("| level | won | lost | lost in wave (most common) | median time of loss (s) | health left when won (p25 / p50 / p75) |")
    w("|---|---|---|---|---|---|")
    for number in sorted(by_level):
        rows = by_level[number]
        lost = [g for g in rows if g["result"] != "won"]
        wave_of_loss = defaultdict(int)
        for g in lost:
            started = [int(k) for k, v in g["waves"].items() if v["first_spawn"] >= 0]
            wave_of_loss[max(started) + 1 if started else 0] += 1
        common = max(wave_of_loss.items(), key=lambda kv: kv[1]) if wave_of_loss else (0, 0)
        times = sorted(g["time"] for g in lost)
        healths = sorted(g["health"] for g in rows if g["result"] == "won")
        quart = lambda xs, q: xs[min(len(xs) - 1, int(q * len(xs)))] if xs else 0
        w("| %d | %d | %d | wave %d (%d games) | %s | %d / %d / %d |" % (
            number, len(rows) - len(lost), len(lost), common[0], common[1],
            "%.0f" % times[len(times) // 2] if times else "-", quart(healths, .25), quart(healths, .5), quart(healths, .75)))

    w("\n## By strategy\n")
    w("| strategy | games | win % | avg health left |")
    w("|---|---|---|---|")
    by_strategy = defaultdict(list)
    for g in games:
        by_strategy[g["strategy"]].append(g)
    for name, rows in sorted(by_strategy.items(), key=lambda kv: -pct(sum(g["result"] == "won" for g in kv[1]), len(kv[1]))):
        w("| %s | %d | %.0f | %.1f |" % (name, len(rows), pct(sum(g["result"] == "won" for g in rows), len(rows)),
                                          sum(g["health"] for g in rows) / len(rows)))

    w("\n## Towers: damage that took health away, per amino acid spent\n")
    w("| tower | built | cost | damage / game | damage per amino | kills / game |")
    w("|---|---|---|---|---|---|")
    damage = defaultdict(float)
    built = defaultdict(int)
    kills = defaultdict(int)
    games_with = defaultdict(int)
    for g in games:
        for tower, amount in g["damage_by_tower"].items():
            damage[tower] += amount
        for tower, count in g["towers_built"].items():
            built[tower] += count
            games_with[tower] += 1
        for tower, count in g["kills_by_tower"].items():
            kills[tower] += count
    for tower in sorted(set(built) | set(damage), key=lambda t: -(damage[t] / max(1, built[t] * COSTS.get(t, 1)))):
        spent = built[tower] * COSTS.get(tower, 0)
        w("| %s | %d | %s | %.0f | %.2f | %.1f |" % (
            tower, built[tower], COSTS.get(tower, "-"), damage[tower] / max(1, games_with[tower]),
            damage[tower] / spent if spent else 0.0, kills[tower] / max(1, games_with[tower])))

    w("\n## Share of the damage by tower, per level (%)\n")
    towers_all = sorted({t for g in games for t in g["damage_by_tower"]})
    w("| level | " + " | ".join(towers_all) + " |")
    w("|---|" + "---|" * len(towers_all))
    for number in sorted(by_level):
        totals = defaultdict(float)
        for g in by_level[number]:
            for t, a in g["damage_by_tower"].items():
                totals[t] += a
        grand = sum(totals.values()) or 1.0
        w("| %d | %s |" % (number, " | ".join("%.0f" % pct(totals[t], grand) for t in towers_all)))

    w("\n## Enemies: how many got out\n")
    w("| enemy | spawned | killed | leaked | leak % |")
    w("|---|---|---|---|---|")
    killed = defaultdict(int)
    leaked = defaultdict(int)
    for g in games:
        for enemy, count in g["kills"].items():
            killed[enemy] += count
        for enemy, count in g["leaks"].items():
            leaked[enemy] += count
    for enemy in sorted(set(killed) | set(leaked), key=lambda e: -pct(leaked[e], killed[e] + leaked[e])):
        total = killed[enemy] + leaked[enemy]
        w("| %s | %d | %d | %d | %.1f |" % (enemy, total, killed[enemy], leaked[enemy], pct(leaked[enemy], total)))

    w("\n## Enemies that leak in lost games vs won games (leaks per game)\n")
    w("| enemy | in lost games | in won games |")
    w("|---|---|---|")
    lost_games = [g for g in games if g["result"] != "won"]
    won_games = [g for g in games if g["result"] == "won"]
    for enemy in sorted(set(killed) | set(leaked), key=lambda e: -sum(g["leaks"].get(e, 0) for g in lost_games)):
        w("| %s | %.2f | %.2f |" % (enemy, sum(g["leaks"].get(enemy, 0) for g in lost_games) / max(1, len(lost_games)),
                                    sum(g["leaks"].get(enemy, 0) for g in won_games) / max(1, len(won_games))))

    w("\n## Waves: where the games are lost (leaks per wave) and how long a wave lasts\n")
    w("| level | wave | leaks / game | avg duration (s) |")
    w("|---|---|---|---|")
    for number in sorted(by_level):
        rows = by_level[number]
        wave_count = max(int(k) for g in rows for k in g["waves"]) + 1
        for wave in range(wave_count):
            leaks = sum(g["waves"][str(wave)]["leaks"] for g in rows if str(wave) in g["waves"]) / len(rows)
            lengths = [g["waves"][str(wave)]["last_end"] - g["waves"][str(wave)]["first_spawn"] for g in rows
                       if str(wave) in g["waves"] and g["waves"][str(wave)]["first_spawn"] >= 0 and g["waves"][str(wave)]["last_end"] >= 0]
            w("| %d | %d | %.1f | %s |" % (number, wave + 1, leaks, "%.0f" % (sum(lengths) / len(lengths)) if lengths else "-"))

    text = "\n".join(out) + "\n"
    with open(os.path.join(folder, "report.md"), "w", encoding="utf-8") as fh:
        fh.write(text)
    return text


if __name__ == "__main__":
    load_costs()
    for folder in sys.argv[1:]:
        print(report(folder))
