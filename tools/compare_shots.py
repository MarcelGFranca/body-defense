#!/usr/bin/env python3 -I
"""Compares the screenshots of two folders (made by tools/perf_shot.tscn) and prints how much they differ.

Usage: python3 -I tools/compare_shots.py BEFORE_DIR AFTER_DIR [--save DIFF_DIR]
For every PNG name found in both folders it prints the share of pixels that differ by more than 24/255 in some channel
(a visible change), the share that differ at all, and the mean absolute difference. With --save it also writes an image
where the differing pixels are red over a dimmed copy of the picture.
"""
import os
import sys

import numpy as np
from PIL import Image


def main():
	args = [a for a in sys.argv[1:] if not a.startswith("--")]
	before_dir, after_dir = args[0], args[1]
	save = sys.argv[sys.argv.index("--save") + 1] if "--save" in sys.argv else None
	if save:
		os.makedirs(save, exist_ok=True)
	for name in sorted(os.listdir(before_dir)):
		if not name.endswith(".png") or not os.path.exists(os.path.join(after_dir, name)):
			continue
		a = np.asarray(Image.open(os.path.join(before_dir, name)).convert("RGB")).astype(int)
		b = np.asarray(Image.open(os.path.join(after_dir, name)).convert("RGB")).astype(int)
		if a.shape != b.shape:
			print(f"{name}: sizes differ {a.shape} vs {b.shape}")
			continue
		diff = np.abs(a - b).max(axis=2)
		visible = (diff > 24).mean() * 100
		any_diff = (diff > 0).mean() * 100
		print(f"{name}: visible diff {visible:6.3f}% of pixels, any diff {any_diff:6.3f}%, mean abs diff {np.abs(a - b).mean():.3f}/255")
		if save:
			out = (a * 0.35).astype(np.uint8)
			out[diff > 24] = (255, 0, 0)
			Image.fromarray(out).save(os.path.join(save, name))


if __name__ == "__main__":
	main()
