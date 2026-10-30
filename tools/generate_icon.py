"""Draws the app icon: the macrophage guarding the body from three viruses, with no text so it reads at small sizes.

Usage: python3 -I tools/generate_icon.py
Output: assets/icon/icon.png (512), adaptive_background.png and adaptive_foreground.png (432)
"""
import math
import os

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ASSETS = os.path.join(ROOT, "assets")
OUTLINE = (43, 27, 58, 255)
BG = (58, 31, 43, 255)
BG_LIGHT = (92, 44, 66, 255)
RING = (110, 230, 255, 255)
VIRUSES = [  # angle in degrees, body, spike
    (-140, (110, 200, 100, 255), (190, 240, 120, 255)),
    (-40, (240, 130, 60, 255), (255, 200, 120, 255)),
    (90, (150, 100, 230, 255), (190, 130, 255, 255)),
]


def rays(size, count=12):
    img = Image.new("RGBA", (size, size), BG)
    px = img.load()
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            angle = math.atan2(y - c, x - c)
            if int((angle + math.pi) / (2 * math.pi) * count * 2) % 2 == 0:
                px[x, y] = BG_LIGHT
    return img


def virus(draw, cx, cy, r, body, spike):
    for k in range(12):
        a = k * math.pi / 6
        draw.line((cx + math.cos(a) * r, cy + math.sin(a) * r, cx + math.cos(a) * (r + 3), cy + math.sin(a) * (r + 3)), fill=spike)
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=body, outline=OUTLINE)
    draw.ellipse((cx - r * 0.5, cy - r * 0.6, cx - r * 0.1, cy - r * 0.2), fill=spike)


def art(size, hero_fraction):
    """The characters on a transparent square of `size` pixels; the hero is `hero_fraction` of the width."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    c = size / 2
    hero = round(size * hero_fraction)
    ring_r = size * 0.36
    draw.ellipse((c - ring_r, c - ring_r, c + ring_r, c + ring_r), outline=RING, width=max(1, size // 64))
    for angle, body, spike in VIRUSES:
        a = math.radians(angle)
        virus(draw, c + math.cos(a) * ring_r, c + math.sin(a) * ring_r, size * 0.065, body, spike)
    sprite = Image.open(os.path.join(ASSETS, "towers", "macrophage.png")).convert("RGBA").resize((hero, hero), Image.NEAREST)
    img.paste(sprite, (round(c - hero / 2), round(c - hero / 2)), sprite)
    return img


def main():
    icon_dir = os.path.join(ASSETS, "icon")
    full = rays(64)
    full.alpha_composite(art(64, 0.5))
    full.resize((512, 512), Image.NEAREST).save(os.path.join(icon_dir, "icon.png"))
    rays(72).resize((432, 432), Image.NEAREST).save(os.path.join(icon_dir, "adaptive_background.png"))
    # the adaptive foreground keeps everything inside the central two thirds (the launcher masks the rest)
    front = Image.new("RGBA", (72, 72), (0, 0, 0, 0))
    inner = art(48, 0.55)
    front.alpha_composite(inner, (12, 12))
    front.resize((432, 432), Image.NEAREST).save(os.path.join(icon_dir, "adaptive_foreground.png"))
    print("wrote the icon")


if __name__ == "__main__":
    main()
