"""Generates placeholder pixel art: generic enemy images and small UI icons.

Usage: python3 -I tools/generate_placeholder_art.py
Output: assets/placeholders/, assets/ui/
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image

from pixel_art import OUTLINE, SIZE, WHITE, disc, ellipse, outline, put, shade_ellipse

ASSETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")


def new_canvas():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def bands(base):
    r, g, b = base
    shades = [(max(0, int(c * k)), max(0, int(c2 * k)), max(0, int(c3 * k))) for (c, c2, c3), k in
              (((r, g, b), 0.55), ((r, g, b), 0.78), ((r, g, b), 1.0), ((r, g, b), 1.0))]
    light = (min(255, r + 60), min(255, g + 60), min(255, b + 60))
    return (shades[0] + (255,), shades[1] + (255,), (r, g, b, 255), light + (255,))


def finish(img, filled, face=None):
    outline(img, filled)
    if face:
        face(img)
    return img


def eyes(img, cx, cy, gap=3):
    for ex in (cx - gap - 1, cx + gap - 1):
        for dx in range(2):
            for dy in range(2):
                put(img, ex + dx, cy + dy, WHITE)
        put(img, ex + 1, cy + 1, OUTLINE)


def smile(img, cx, cy):
    for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 0)):
        put(img, cx + dx, cy + dy, OUTLINE)


def virus_placeholder():
    img = new_canvas()
    body = ellipse(16, 16, 9, 9)
    shade_ellipse(img, body, 16, 16, 9, 9, bands((110, 170, 170)))
    knobs = set()
    for i in range(8):
        a = i * math.pi / 4
        knobs |= disc(16 + 10.5 * math.cos(a), 16 + 10.5 * math.sin(a), 2.0)
    for x, y in knobs - body:
        img.putpixel((x, y), (200, 235, 235, 255))
    return finish(img, body | knobs)


def bacterium_placeholder():
    img = new_canvas()
    body = ellipse(16, 16, 12, 7)
    shade_ellipse(img, body, 16, 16, 12, 7, bands((220, 130, 160)))
    return finish(img, body)


def amino_acid_orb():
    img = new_canvas()
    body = disc(16, 16, 6)
    shade_ellipse(img, body, 16, 16, 6, 6, bands((255, 190, 70)))
    for x, y in ((13, 13), (14, 12)):
        put(img, x, y, (255, 250, 200, 255))
    outline(img, body)
    return img.crop((8, 8, 24, 24))


def heart():
    rows = [
        "..XX..XX..",
        ".XXXXXXXX.",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
        ".XXXXXXXX.",
        "..XXXXXX..",
        "...XXXX...",
        "....XX....",
    ]
    img = Image.new("RGBA", (12, 12), (0, 0, 0, 0))
    filled = set()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c == "X":
                filled.add((x + 1, y + 2))
                img.putpixel((x + 1, y + 2), (232, 70, 90, 255) if y > 0 else (255, 130, 140, 255))
    for x, y in filled:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n not in filled and 0 <= n[0] < 12 and 0 <= n[1] < 12:
                img.putpixel(n, OUTLINE)
    return img


def save(img, *parts):
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


def main():
    save(virus_placeholder(), "placeholders", "virus.png")
    save(bacterium_placeholder(), "placeholders", "bacterium.png")
    save(amino_acid_orb(), "ui", "amino_acid_orb.png")
    save(heart(), "ui", "heart.png")


if __name__ == "__main__":
    main()
