#!/usr/bin/env python3 -I
"""Writes assets/ui/disc.png: a white disc with a one pixel soft edge, used by game/canvas_shapes.gd.

Godot draws every circle as its own draw call, but a rectangle of one texture is merged with the rectangles next to it, so
circles are drawn as tinted rectangles of this disc. 256 pixels is big enough for the largest aura (about 120 map units
across), and the game samples it by point, so smaller discs keep a hard edge.
Usage: python3 -I tools/generate_disc.py
"""
import os

import numpy as np
from PIL import Image

SIZE = 256


def main():
	half = SIZE / 2.0
	axis = np.arange(SIZE) + 0.5 - half
	distance = np.sqrt(axis[None, :] ** 2 + axis[:, None] ** 2)
	alpha = np.clip(half - distance + 0.5, 0.0, 1.0)
	pixels = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
	pixels[..., :3] = 255
	pixels[..., 3] = np.round(alpha * 255).astype(np.uint8)
	path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "ui", "disc.png")
	Image.fromarray(pixels, "RGBA").save(path, optimize=True)
	print(f"wrote {path}")


if __name__ == "__main__":
	main()
