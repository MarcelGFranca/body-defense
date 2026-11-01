#!/usr/bin/env python3
"""Mutation check of the test suite: breaks the game code on purpose, one small change at a time, and runs the tests.
A mutant is KILLED when the tests fail (or crash), SURVIVED when they still pass. A surviving mutant is either a gap
in the tests or a change that does not alter behaviour (listed with the `equivalent` reason in tools/mutants.json).
Usage: python3 -I tools/mutation_check.py [--only id,id] [--list]
Every file is restored after each run, also on Ctrl+C. Run it with no other Godot test running."""
import json, re, subprocess, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
mutants = json.loads((ROOT / "tools/mutants.json").read_text())
if "--list" in sys.argv:
	for m in mutants:
		print("%-32s %-26s %s" % (m["id"], m["area"], m["equivalent"] or ""))
	sys.exit(0)
if "--only" in sys.argv:
	wanted = sys.argv[sys.argv.index("--only") + 1].split(",")
	mutants = [m for m in mutants if m["id"] in wanted]
survivors = []
for m in mutants:
	path = ROOT / m["file"]
	original = path.read_text()
	if m["old"] not in original:
		print("%-32s BAD-PATTERN (the code changed: update tools/mutants.json)" % m["id"])
		continue
	path.write_text(original.replace(m["old"], m["new"], 1))
	try:
		run = subprocess.run(["godot", "--headless", "--path", str(ROOT), "--fixed-fps", "60", "res://tests/test_runner.tscn"],
			capture_output=True, text=True, timeout=90)
		text = run.stdout + run.stderr
		failed = [l for l in text.split("\n") if l.startswith("FAIL")]
		crashed = "SCRIPT ERROR" in text or run.returncode != 0 or not re.search(r"\d+ checks, \d+ failures", text)
		killed = bool(failed) or crashed
	except subprocess.TimeoutExpired:
		killed, failed = True, ["timeout"]
	finally:
		path.write_text(original)
	print("%-32s %s %s" % (m["id"], "KILLED  " if killed else "SURVIVED", (failed[0][:70] if failed else "")))
	if not killed:
		survivors.append(m)
real = [m for m in survivors if not m["equivalent"]]
print("\n%d mutants, %d survived (%d equivalent, %d gaps in the tests)" % (len(mutants), len(survivors), len(survivors) - len(real), len(real)))
sys.exit(1 if real else 0)
