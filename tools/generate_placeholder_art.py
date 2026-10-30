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
    """An amino acid as a ball-and-stick molecule: a central carbon with an amine (blue), a carboxyl (red) and a side chain (green)."""
    img = new_canvas()
    bond = (150, 128, 176, 255)
    atoms = (  # (x, y, radius, color)
        (16, 15.5, 3.0, (232, 232, 244)),  # central carbon
        (11.5, 11, 2.5, (84, 144, 255)),  # nitrogen of the amine group
        (20.5, 11, 2.5, (240, 76, 92)),  # oxygen of the carboxyl group
        (16, 20.5, 2.5, (112, 214, 96)),  # side chain
    )
    for x, y, _, _ in atoms[1:]:
        steps = 12
        for k in range(steps + 1):
            t = k / steps
            put(img, round(16 + (x - 16) * t), round(15.5 + (y - 15.5) * t), bond)
            put(img, round(16 + (x - 16) * t) + 1, round(15.5 + (y - 15.5) * t), bond)
    filled = set()
    for x, y, r, color in atoms:
        body = disc(x, y, r)
        shade_ellipse(img, body, x, y, r, r, bands(color))
        put(img, round(x) - 1, round(y) - 1, (255, 255, 255, 255))
        filled |= body
    outline(img, filled | {(x, y) for x in range(32) for y in range(32) if img.getpixel((x, y))[3] > 0})
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
