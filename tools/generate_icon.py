"""Draws the app icon: the macrophage against a virus, with the title, kept inside the Android safe zone.

Android masks the adaptive icon (a circle, squircle or rounded square, depending on the phone) and only guarantees
the central circle of 66% of the 108 dp layer: 288 px of the 432 px layer. Everything drawn in the foreground stays
inside SAFE_RADIUS of the centre; `--check` verifies it.

Usage: python3 -I tools/generate_icon.py [--check]
Output: assets/icon/icon.png (512), adaptive_background.png and adaptive_foreground.png (432),
        design/icon-options/safe_zone_preview.png (the foreground under circle and rounded square masks)
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ASSETS = os.path.join(ROOT, "assets")
LAYER = 432
SAFE_RADIUS = 142  # a little inside the 144 px (288 px circle) that Android guarantees
FONT = ImageFont.truetype(os.path.join(ASSETS, "fonts", "PressStart2P-Regular.ttf"), 8)
OUTLINE = (43, 27, 58, 255)
BG = (58, 31, 43, 255)
BG_LIGHT = (92, 44, 66, 255)
WHITE = (255, 255, 255, 255)
YELLOW = (255, 240, 130, 255)


def rays(size, count=8):
    img = Image.new("RGBA", (size, size), BG)
    px = img.load()
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            if int((math.atan2(y - c, x - c) + math.pi) / (2 * math.pi) * count * 2) % 2 == 0:
                px[x, y] = BG_LIGHT
    return img


def title_line(text, color):
    """One line of the title as a 1x pixel image with an outline (8 px tall plus the outline)."""
    img = Image.new("RGBA", (int(len(text) * 8) + 4, 12), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.fontmode = "1"
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
        draw.text((2 + dx, 2 + dy), text, font=FONT, fill=OUTLINE)
    draw.text((2, 2), text, font=FONT, fill=color)
    return img


def sprite(path, size, flip=False):
    img = Image.open(os.path.join(ASSETS, path)).convert("RGBA")
    if flip:
        img = img.transpose(Image.FLIP_LEFT_RIGHT)
    return img.resize((size, size), Image.NEAREST)


def foreground(scale=1.265):
    """The characters and the title on a transparent 432 px layer, scaled around the centre."""
    layer = Image.new("RGBA", (LAYER, LAYER), (0, 0, 0, 0))
    hero = 64
    layer.alpha_composite(sprite("towers/macrophage.png", hero), (124, 120))
    layer.alpha_composite(sprite("enemies/rhinovirus/rhinovirus_sprite.png", hero, True), (244, 120))
    draw = ImageDraw.Draw(layer)
    bolt = [(214, 120), (202, 160), (212, 160), (204, 196), (228, 150), (216, 150), (226, 120)]
    draw.polygon(bolt, fill=YELLOW, outline=OUTLINE)
    for text, color, top in (("BODY", YELLOW, 206), ("DEFENSE", WHITE, 236)):
        line = title_line(text, color)
        line = line.resize((line.width * 3, line.height * 3), Image.NEAREST)
        layer.alpha_composite(line, ((LAYER - line.width) // 2, top))
    # the picture is a little above the middle: bring it down, then scale it around the centre
    shifted = Image.new("RGBA", (LAYER, LAYER), (0, 0, 0, 0))
    shifted.alpha_composite(layer, (0, 18))
    layer = shifted
    if scale != 1.0:
        size = round(LAYER * scale)
        layer = layer.resize((size, size), Image.NEAREST)
        framed = Image.new("RGBA", (LAYER, LAYER), (0, 0, 0, 0))
        framed.alpha_composite(layer, ((LAYER - size) // 2, (LAYER - size) // 2))
        layer = framed
    return layer


def farthest_pixel(layer):
    """Distance from the centre of the farthest visible pixel."""
    px = layer.load()
    far = 0.0
    c = (layer.width - 1) / 2
    for y in range(layer.height):
        for x in range(layer.width):
            if px[x, y][3] > 0:
                far = max(far, math.hypot(x - c, y - c))
    return far


def preview(layer):
    """The foreground over the rays under a circle mask and a rounded-square mask, side by side."""
    tiles = []
    for shape in ("circle", "squircle"):
        tile = rays(LAYER, 8)
        tile.alpha_composite(layer)
        mask = Image.new("L", (LAYER, LAYER), 0)
        draw = ImageDraw.Draw(mask)
        if shape == "circle":
            draw.ellipse((0, 0, LAYER - 1, LAYER - 1), fill=255)
        else:
            draw.rounded_rectangle((0, 0, LAYER - 1, LAYER - 1), radius=100, fill=255)
        out = Image.new("RGBA", (LAYER, LAYER), (30, 30, 30, 255))
        out.paste(tile, (0, 0), mask)
        tiles.append(out)
    sheet = Image.new("RGBA", (LAYER * 2 + 20, LAYER), (30, 30, 30, 255))
    sheet.paste(tiles[0], (0, 0))
    sheet.paste(tiles[1], (LAYER + 20, 0))
    return sheet


def main():
    icon_dir = os.path.join(ASSETS, "icon")
    front = foreground()
    far = farthest_pixel(front)
    print("farthest pixel from the centre: %.1f px (limit %d)" % (far, SAFE_RADIUS))
    if "--check" in sys.argv:
        sys.exit(0 if far <= SAFE_RADIUS else 1)
    rays(LAYER, 8).save(os.path.join(icon_dir, "adaptive_background.png"))
    front.save(os.path.join(icon_dir, "adaptive_foreground.png"))
    # the legacy icon (phones before Android 8, and the store) is the same picture on the rays, a bit bigger
    legacy = rays(LAYER, 8)
    legacy.alpha_composite(foreground(1.44))
    legacy.resize((512, 512), Image.NEAREST).save(os.path.join(icon_dir, "icon.png"))
    out_dir = os.path.join(ROOT, "design", "icon-options")
    os.makedirs(out_dir, exist_ok=True)
    preview(front).save(os.path.join(out_dir, "safe_zone_preview.png"))
    print("wrote the icon")


if __name__ == "__main__":
    main()
