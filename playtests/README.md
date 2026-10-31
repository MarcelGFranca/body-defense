# Recorded games

Each folder holds games played by bots that build in ten different ways (see `tools/playtest.gd`).
`games.jsonl` has one game per line (result, health left, time, towers built, damage and kills by
tower, enemies that got out, how every wave went), `summary.csv` has the main numbers, and
`report.md` is the analysis made by `tools/analyze_playtests.py`.

| Folder | What it is |
|---|---|
| `baseline_1000` | 1000 games on the numbers before the balance pass (Medium). |
| `final_100` | 100 games on the final numbers (Medium). |
| `medium_1000`, `easy_1000`, `hard_1000` | 1000 games on the final numbers, on each difficulty. |
| `before_first_wave_10s`, `first_wave_10s` | 100 games each on Medium, with the first wave at 5 s / 20 s and then at 10 s for every level (same bots, same seeds). Win rates are identical on every level and the average health left differs by 0.4 at most. |

To record more:

```
godot --headless --path . --fixed-fps 60 res://tools/playtest.tscn -- --games 100 --out res://playtests/mine [--difficulty hard] [--level 5]
python3 -I tools/analyze_playtests.py playtests/mine
```
