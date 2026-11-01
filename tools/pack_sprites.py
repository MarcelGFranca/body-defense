#!/usr/bin/env python3 -I
"""Packs every enemy and tower animation sheet into one texture, so the sprites of a whole level are drawn in one batch.

The generators (generate_enemy_sprites.py, generate_tower_sprites.py) write one strip of 32 x 32 frames per animation.
Godot sends consecutive draws that use the same texture to the GPU as one call, but a level shows many different sheets
at once (every enemy kind, in every animation, plus the towers), so each sprite cost a call. This script copies all strips
into assets/sprites/atlas.png and writes assets/sprites/atlas.json with where each strip is.

Usage: python3 -I tools/pack_sprites.py [--check]
  --check   writes nothing; exits with 1 when the files on disk differ from what packing would produce.
Run it after the sprite generators, then `godot --headless --path . --import`.
"""
import json
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "sprites")
ATLAS_WIDTH = 2048
GAP = 2
FRAME = 32
KINDS = ("enemies", "towers")


def collect():
	"""Returns [(key, image, fps, loop, frames)] for every strip, in a fixed order."""
	strips = []
	for kind in KINDS:
		kind_dir = os.path.join(ROOT, "assets", kind)
		for name in sorted(os.listdir(kind_dir)):
			anim_dir = os.path.join(kind_dir, name, "animations")
			meta_path = os.path.join(anim_dir, f"{name}_animations.json")
			if not os.path.exists(meta_path):
				continue
			with open(meta_path, encoding="utf-8") as fh:
				meta = json.load(fh)
			for anim in sorted(meta["animations"]):
				info = meta["animations"][anim]
				sheet = Image.open(os.path.join(anim_dir, f"{name}_{anim}_sheet.png")).convert("RGBA")
				assert sheet.height == FRAME and sheet.width == FRAME * int(info["frames"]), (name, anim, sheet.size)
				strips.append((f"{kind}/{name}/{anim}", sheet, float(info["fps"]), bool(info["loop"]), int(info["frames"])))
	return strips


def pack(strips):
	"""Shelf packing, longest strip first. Every strip is one row of frames, so rows are 32 pixels high."""
	order = sorted(strips, key=lambda s: (-s[1].width, s[0]))
	rows = []  # each row: [used_width, [(strip, x)]]
	for strip in order:
		for row in rows:
			if row[0] + strip[1].width <= ATLAS_WIDTH:
				row[1].append((strip, row[0]))
				row[0] += strip[1].width + GAP
				break
		else:
			rows.append([strip[1].width + GAP, [(strip, 0)]])
	height = len(rows) * (FRAME + GAP)
	atlas = Image.new("RGBA", (ATLAS_WIDTH, height), (0, 0, 0, 0))
	index = {}
	for r, row in enumerate(rows):
		y = r * (FRAME + GAP)
		for strip, x in row[1]:
			atlas.paste(strip[1], (x, y))
			index[strip[0]] = {"x": x, "y": y, "frames": strip[4], "fps": strip[2], "loop": strip[3]}
	return atlas, {"width": ATLAS_WIDTH, "height": height, "frame": FRAME, "sheets": dict(sorted(index.items()))}


def main():
	atlas, index = pack(collect())
	png_path = os.path.join(OUT_DIR, "atlas.png")
	json_path = os.path.join(OUT_DIR, "atlas.json")
	text = json.dumps(index, indent="\t") + "\n"
	if "--check" in sys.argv:
		same = os.path.exists(png_path) and os.path.exists(json_path)
		if same:
			same = open(json_path, encoding="utf-8").read() == text and list(Image.open(png_path).convert("RGBA").getdata()) == list(atlas.getdata())
		print("atlas is up to date" if same else "atlas is OUT OF DATE: run tools/pack_sprites.py")
		sys.exit(0 if same else 1)
	os.makedirs(OUT_DIR, exist_ok=True)
	atlas.save(png_path, optimize=True)
	with open(json_path, "w", encoding="utf-8") as fh:
		fh.write(text)
	print(f"packed {len(index['sheets'])} strips into {png_path}")


if __name__ == "__main__":
	main()
