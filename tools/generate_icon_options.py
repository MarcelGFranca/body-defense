"""Draws five app icon candidates (64x64 pixel art, shown at 512x512) for the designer to choose from.

Usage: python3 -I tools/generate_icon_options.py
Output: design/icon-options/option_1.png ... option_5.png and sheet.png
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ASSETS = os.path.join(ROOT, "assets")
OUT = os.path.join(ROOT, "design", "icon-options")
FONT = ImageFont.truetype(os.path.join(ASSETS, "fonts", "PressStart2P-Regular.ttf"), 8)

N = 64
OUTLINE = (43, 27, 58, 255)
BG = (58, 31, 43, 255)
BG_LIGHT = (92, 44, 66, 255)
WHITE = (255, 255, 255, 255)
YELLOW = (255, 240, 130, 255)
GOLD = (255, 190, 60, 255)
RED = (230, 60, 60, 255)
VEIN = (150, 40, 60, 255)
VEIN_LIGHT = (200, 70, 85, 255)
CYAN = (110, 230, 255, 255)
SHIELD = (70, 120, 200, 255)
SHIELD_LIGHT = (130, 180, 245, 255)


def sprite(path, scale=1):
    img = Image.open(os.path.join(ASSETS, path)).convert("RGBA")
    return img.resize((img.width * scale, img.height * scale), Image.NEAREST)


def canvas(color=BG):
    return Image.new("RGBA", (N, N), color)


def paste(img, part, x, y):
    img.paste(part, (x, y), part)


def rays(img, color, count=12, cx=32, cy=32):
    """Alternating wedges behind the hero, like a burst."""
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            angle = math.atan2(y - cy, x - cx)
            if int((angle + math.pi) / (2 * math.pi) * count * 2) % 2 == 0:
                px[x, y] = color


def text(img, line, y, color=WHITE):
    draw = ImageDraw.Draw(img)
    draw.fontmode = "1"
    width = draw.textlength(line, font=FONT)
    x = round((N - width) / 2)
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
        draw.text((x + dx, y + dy), line, font=FONT, fill=OUTLINE)
    draw.text((x, y + 1), line, font=FONT, fill=(0, 0, 0, 0))
    draw.text((x, y), line, font=FONT, fill=color)


def title(img, y, two_colors=True):
    text(img, "BODY", y, YELLOW if two_colors else WHITE)
    text(img, "DEFENSE", y + 9, WHITE)


def shield(img, cx, top, w, h, fill, light):
    draw = ImageDraw.Draw(img)
    pts = [(cx - w // 2, top), (cx + w // 2, top), (cx + w // 2, top + h * 0.55), (cx, top + h), (cx - w // 2, top + h * 0.55)]
    draw.polygon([(x + dx, y + dy) for x, y in pts for dx, dy in [(0, 0)]], fill=fill, outline=OUTLINE)
    draw.line([(cx - w // 2 + 1, top + 1), (cx + w // 2 - 1, top + 1)], fill=light)


def virus_dot(img, cx, cy, r, body, spike):
    draw = ImageDraw.Draw(img)
    for k in range(8):
        a = k * math.pi / 4
        draw.point((round(cx + math.cos(a) * (r + 1)), round(cy + math.sin(a) * (r + 1))), fill=spike)
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=body, outline=OUTLINE)


def option_1():
    """The macrophage as the hero inside a shield."""
    img = canvas()
    rays(img, BG_LIGHT)
    shield(img, 32, 3, 38, 40, SHIELD, SHIELD_LIGHT)
    paste(img, sprite("towers/macrophage.png"), 16, 6)
    title(img, 44)
    return img


def option_2(background=True):
    """Hero versus villain."""
    img = canvas() if background else canvas((0, 0, 0, 0))
    if background:
        rays(img, BG_LIGHT, 8)
    paste(img, sprite("towers/macrophage.png"), -4, 6)
    paste(img, sprite("enemies/rhinovirus/rhinovirus_sprite.png").transpose(Image.FLIP_LEFT_RIGHT), 36, 6)
    draw = ImageDraw.Draw(img)
    bolt = [(35, 6), (27, 22), (33, 22), (28, 38), (39, 18), (33, 18), (38, 6)]
    draw.polygon(bolt, fill=YELLOW, outline=OUTLINE)
    title(img, 44)
    return img


def option_3():
    """The heart is the body's health, guarded from every side."""
    img = canvas()
    rays(img, BG_LIGHT, 10, 32, 24)
    paste(img, sprite("ui/heart.png", 3), 14, 4)
    virus_dot(img, 8, 12, 4, (110, 200, 100, 255), (190, 240, 120, 255))
    virus_dot(img, 56, 12, 4, (240, 130, 60, 255), (255, 200, 120, 255))
    virus_dot(img, 8, 34, 3, (150, 100, 230, 255), (190, 130, 255, 255))
    virus_dot(img, 56, 34, 3, (80, 170, 220, 255), (150, 220, 255, 255))
    title(img, 44)
    return img


def option_4():
    """A tower defense scene: a vein, a tower on its slot, a virus on the way."""
    img = canvas(VEIN)
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, N - 1, N - 1), fill=BG)
    path = [(-4, 56), (24, 56), (24, 46), (70, 46)]
    draw.line(path, fill=VEIN, width=11, joint="curve")
    draw.line(path, fill=VEIN_LIGHT, width=3, joint="curve")
    draw.ellipse((-1, 21, 33, 55), outline=CYAN)  # tower range
    paste(img, sprite("towers/interferon.png"), 0, 22)
    paste(img, sprite("enemies/influenza/influenza_sprite.png"), 31, 22)
    draw.rectangle((0, 0, N - 1, 19), fill=BG)
    title(img, 2)
    draw.line((0, 20, N, 20), fill=OUTLINE)
    return img


def option_5():
    """The villain, big, with the crosshair already on it."""
    img = canvas()
    rays(img, (70, 32, 48, 255), 14)
    paste(img, sprite("enemies/rhinovirus/rhinovirus_sprite.png", 2), 0, -9)
    draw = ImageDraw.Draw(img)
    for r in (19,):
        draw.ellipse((32 - r, 24 - r, 32 + r, 24 + r), outline=RED)
    for a, b in (((32, 1), (32, 8)), ((32, 40), (32, 40)), ((11, 24), (18, 24)), ((46, 24), (53, 24))):
        draw.line((a, b), fill=RED)
    draw.rectangle((0, 42, N - 1, N - 1), fill=BG)
    draw.line((0, 42, N, 42), fill=OUTLINE)
    title(img, 45)
    return img


ADAPTIVE = 108  # 432 px at 4x; the launcher keeps only the central 72x72 (two thirds)


def adaptive():
    """Android adaptive icon layers: the rays full-bleed behind, the art inside the safe zone."""
    back = Image.new("RGBA", (ADAPTIVE, ADAPTIVE), BG)
    rays(back, BG_LIGHT, 8, ADAPTIVE // 2, ADAPTIVE // 2)
    front = Image.new("RGBA", (ADAPTIVE, ADAPTIVE), (0, 0, 0, 0))
    paste(front, option_2(background=False), (ADAPTIVE - N) // 2, (ADAPTIVE - N) // 2)
    return back, front


def main():
    os.makedirs(OUT, exist_ok=True)
    options = [option_1(), option_2(), option_3(), option_4(), option_5()]
    sheet = Image.new("RGBA", (5 * 520, 520), (30, 20, 30, 255))
    for index, img in enumerate(options, 1):
        big = img.resize((512, 512), Image.NEAREST)
        big.save(os.path.join(OUT, "option_%d.png" % index))
        sheet.paste(big, ((index - 1) * 520 + 4, 4))
    sheet.save(os.path.join(OUT, "sheet.png"))
    icon_dir = os.path.join(ASSETS, "icon")
    os.makedirs(icon_dir, exist_ok=True)
    options[1].resize((512, 512), Image.NEAREST).save(os.path.join(icon_dir, "icon.png"))
    back, front = adaptive()
    back.resize((432, 432), Image.NEAREST).save(os.path.join(icon_dir, "adaptive_background.png"))
    front.resize((432, 432), Image.NEAREST).save(os.path.join(icon_dir, "adaptive_foreground.png"))
    print("wrote %d icon options to %s" % (len(options), os.path.relpath(OUT, ROOT)))


if __name__ == "__main__":
    main()
