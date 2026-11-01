#!/bin/sh
# Runs all automated tests with a time limit, so a script that does not load (a parse error) fails
# instead of leaving Godot waiting forever. Usage: tools/run_tests.sh   (expected last line: "N checks, 0 failures")
cd "$(dirname "$0")/.." || exit 1
timeout "${TEST_TIMEOUT:-240}" godot --headless --path . --fixed-fps 60 res://tests/test_runner.tscn
status=$?
if [ "$status" -eq 124 ]; then
	echo "FAIL: the test run did not finish in ${TEST_TIMEOUT:-240} s (does tests/test_runner.gd load?)" >&2
fi
exit "$status"
