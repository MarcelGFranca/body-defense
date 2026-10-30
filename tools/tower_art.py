"""Pixel art for the prototype towers: how each one draws a frame, and its idle and attack animations.

Every animation has 8 frames of 32x32. The still icon used by the HUD is the first idle frame.
"""
import math

from PIL import Image

from pixel_art import (
    CYAN, GOO, GOO_DARK, GOO_LIGHT, OUTLINE, SIZE, VIOLET, WHITE, YELLOW, disc, dots, ellipse, outline, put,
    shade_ellipse, star, tint,
)

TONGUE = (255, 120, 140, 255)
DARK = (60, 30, 50, 255)
PINK_SPARK = (255, 205, 225, 255)


def new_canvas():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def bands(base):
    r, g, b = base
    light = (min(255, r + 60), min(255, g + 60), min(255, b + 60), 255)
    return (
        (int(r * 0.55), int(g * 0.55), int(b * 0.55), 255),
        (int(r * 0.78), int(g * 0.78), int(b * 0.78), 255),
        (r, g, b, 255),
        light,
    )


def draw_eyes(img, cx, cy, mode="open", gap=3, look=(1, 1)):
    for ex in (cx - gap - 1, cx + gap - 1):
        if mode == "blink":
            put(img, ex, cy + 1, OUTLINE)
            put(img, ex + 1, cy + 1, OUTLINE)
        elif mode == "wide":
            for dx in range(3):
                for dy in range(3):
                    put(img, ex - 1 + dx, cy - 1 + dy, WHITE)
            put(img, ex, cy, OUTLINE)
        else:
            for dx in range(2):
                for dy in range(2):
                    put(img, ex + dx, cy + dy, WHITE)
            put(img, ex + look[0], cy + look[1], OUTLINE)
            if mode == "angry":
                put(img, ex - 1, cy - 2, OUTLINE)
                put(img, ex, cy - 2, OUTLINE)
                put(img, ex + 1, cy - 1, OUTLINE)


def draw_mouth(img, cx, cy, mode="smile"):
    if mode == "open":
        for x, y in ellipse(cx, cy + 1, 3.5, 2.5):
            put(img, x, y, DARK)
        for dx in (-1, 0):
            put(img, cx + dx, cy + 2, TONGUE)
    elif mode == "o":
        for dx, dy in ((-1, 0), (0, 0), (-2, 1), (1, 1), (-1, 2), (0, 2)):
            put(img, cx + dx, cy + dy, OUTLINE)
    elif mode == "flat":
        for dx in range(-2, 2):
            put(img, cx + dx, cy + 1, OUTLINE)
    else:
        for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 0)):
            put(img, cx + dx, cy + dy, OUTLINE)


def ring_solid(img, cx, cy, radius, color, skip=1):
    for k, step in enumerate(range(0, 360, 3)):
        if k % skip == 0:
            a = math.radians(step)
            put(img, round(cx + radius * math.cos(a)), round(cy + radius * math.sin(a)), color)


class TowerArt:
    id = ""
    idle_fps = 6
    attack_fps = 12

    def idle_frames(self):
        raise NotImplementedError

    def attack_frames(self):
        raise NotImplementedError


class Macrophage(TowerArt):
    """A friendly pale pink blob that engulfs what comes near. Fixed, single target."""

    id = "macrophage"
    color = (236, 190, 200)
    nucleus = (140, 90, 170, 255)

    def render(self, cx=16, cy=17, rx=11.0, ry=10.0, reach=1.0, spin=0.0, mouth="smile", eyes="open",
               glow=0.0, nucleus_dy=0):
        img = new_canvas()
        body = ellipse(cx, cy, rx, ry)
        bumps = set()
        for a in (0.3, 1.5, 2.7, 3.9, 5.1):
            a += spin
            bumps |= disc(cx + rx * reach * math.cos(a), cy + ry * reach * math.sin(a), 3.2 * (0.85 + 0.15 * reach))
        shape = body | bumps
        shade_ellipse(img, shape, cx, cy, rx + 1, ry + 1, bands(self.color))
        for x, y in ellipse(cx, cy + 4 + nucleus_dy, 5, 3):
            img.putpixel((x, y), self.nucleus)
        outline(img, shape)
        draw_eyes(img, round(cx), round(cy) - 4, eyes)
        draw_mouth(img, round(cx), round(cy), mouth)
        if glow:
            tint(img, WHITE, glow)
        return img

    def idle_frames(self):
        frames = []
        for i in range(8):
            wave = math.sin(2 * math.pi * i / 8)
            frames.append(self.render(cy=17 + 0.6 * wave, rx=11 + 0.5 * wave, ry=10 - 0.5 * wave, spin=0.06 * wave,
                                      eyes="blink" if i == 6 else "open", nucleus_dy=round(0.6 * wave)))
        return frames

    def attack_frames(self):
        f = [
            self.render(cy=18, rx=12, ry=9, reach=0.9, eyes="angry", mouth="flat"),
            self.render(cy=18.5, rx=12.5, ry=8.5, reach=0.8, eyes="angry", mouth="flat"),
            self.render(cy=16.5, rx=10, ry=10.5, reach=1.1, eyes="wide", mouth="open"),
            self.render(cy=16.5, rx=9.8, ry=10.2, reach=1.14, eyes="wide", mouth="open", glow=0.25),
            self.render(cy=17.5, rx=11.5, ry=9, reach=1.0, eyes="blink", mouth="flat"),
            self.render(cy=16.5, rx=10, ry=10.5, reach=1.0, glow=0.15, nucleus_dy=-1),
            self.render(cy=17, rx=10.7, ry=10.2),
            self.render(),
        ]
        star(f[3], 27, 6, YELLOW, big=True)
        star(f[3], 5, 8, WHITE)
        dots(f[4], ((4, 24), (27, 24), (8, 28), (24, 28)), PINK_SPARK)
        star(f[5], 26, 8, PINK_SPARK)
        star(f[5], 6, 10, PINK_SPARK)
        return f


class MucusCell(TowerArt):
    """A goblet cell that secretes slowing goo. Fixed, no damage."""

    id = "mucus-cell"
    color = (214, 196, 72)

    def render(self, cup_rx=10.0, cup_ry=8.0, cup_dy=0.0, eyes="open", mouth="smile", drip=None):
        img = new_canvas()
        cup_cy = 12 + cup_dy
        cup = ellipse(16, cup_cy, cup_rx, cup_ry)
        stem = {(x, y) for x in range(14, 18) for y in range(int(cup_cy + cup_ry) - 2, 27)}
        base = {(x, y) for x in range(10, 22) for y in range(25, 29)}
        shape = cup | stem | base
        shade_ellipse(img, shape, 16, 16, 12, 13, bands(self.color))
        for x, y in ((12, 5), (13, 4), (19, 5), (20, 6), (16, 3)):
            if (x, y + round(cup_dy)) in cup:
                put(img, x, y + round(cup_dy), GOO_LIGHT)
        outline(img, shape)
        draw_eyes(img, 16, round(cup_cy) - 1, eyes)
        draw_mouth(img, 16, round(cup_cy) + 3, mouth)
        if drip is not None:
            dots(img, ((16, drip), (16, drip + 1)), GOO_LIGHT)
        return img

    def idle_frames(self):
        frames = []
        for i in range(8):
            wave = math.sin(2 * math.pi * i / 8)
            drip = (2 + i // 2) if i in (1, 2, 3, 4) else None
            frames.append(self.render(cup_rx=10 + 0.4 * wave, cup_ry=8 - 0.3 * wave,
                                      eyes="blink" if i == 6 else "open", drip=None if drip is None else drip))
        return frames

    def attack_frames(self):
        f = [
            self.render(cup_rx=10.5, cup_ry=7.5, cup_dy=1, eyes="blink"),
            self.render(cup_rx=8.5, cup_ry=9, eyes="wide", mouth="o"),
            self.render(cup_rx=9.5, cup_ry=8.5, eyes="wide", mouth="open"),
            self.render(cup_rx=9.8, cup_ry=8.2, eyes="wide", mouth="open"),
            self.render(cup_rx=10, cup_ry=8, mouth="smile"),
            self.render(cup_rx=10, cup_ry=8, mouth="smile"),
            self.render(cup_rx=10, cup_ry=8),
            self.render(),
        ]
        dots(f[2], ((16, 3), (15, 2), (17, 2), (16, 1)), GOO)
        dots(f[2], ((16, 2),), GOO_LIGHT)
        dots(f[3], ((8, 3), (9, 3), (24, 3), (23, 3), (16, 1), (11, 2), (21, 2)), GOO)
        dots(f[3], ((8, 2), (24, 2)), GOO_LIGHT)
        dots(f[4], ((5, 9), (4, 9), (27, 9), (28, 9), (9, 6), (23, 6)), GOO)
        dots(f[4], ((5, 8), (27, 8)), GOO_LIGHT)
        for x, y in ellipse(5, 27, 3, 1.6) | ellipse(27, 27, 3, 1.6):
            put(f[5], x, y, GOO)
        dots(f[5], ((3, 20), (3, 21), (29, 20), (29, 21)), GOO_DARK)
        for x, y in ellipse(16, 28, 14, 2):
            if abs(x - 16) > 8 and (x + y) % 2 == 0:
                put(f[6], x, y, GOO_DARK)
        dots(f[6], ((4, 27), (27, 27), (6, 28), (25, 28)), GOO)
        return f


class Interferon(TowerArt):
    """A spiky cyan cell that sends out an antiviral alarm pulse. Fixed, area damage."""

    id = "interferon"
    color = (90, 190, 235)

    def render(self, r=8.0, ray=1.0, spin=0.0, glow=0.0, eyes="open", mouth="smile"):
        img = new_canvas()
        body = ellipse(16, 16, r, r)
        rays = set()
        for i in range(8):
            a = i * math.pi / 4 + math.pi / 8 + spin
            for t, size in ((10.5, 1.5), (12.5, 1.1)):
                rays |= disc(16 + t * ray * math.cos(a), 16 + t * ray * math.sin(a), size)
        shape = body | rays
        shade_ellipse(img, shape, 16, 16, 12, 12, bands(self.color))
        outline(img, shape)
        draw_eyes(img, 16, 14, eyes)
        draw_mouth(img, 16, 18, mouth)
        if glow:
            tint(img, CYAN, glow)
        return img

    def idle_frames(self):
        frames = []
        for i in range(8):
            wave = math.sin(2 * math.pi * i / 8)
            frame = self.render(r=8 + 0.3 * wave, ray=1.0 + 0.03 * wave, spin=0.04 * i, eyes="blink" if i == 6 else "open")
            if i in (2, 5):
                star(frame, 3, 4, CYAN)
            frames.append(frame)
        return frames

    def attack_frames(self):
        f = [
            self.render(r=7.2, ray=0.85, eyes="wide", mouth="flat"),
            self.render(r=8.4, ray=1.1, glow=0.3, eyes="wide", mouth="o"),
            self.render(r=8.2, ray=1.2, glow=0.35, eyes="wide", mouth="open"),
            self.render(r=8, ray=1.2, glow=0.2, eyes="wide", mouth="open"),
            self.render(r=8, ray=1.15, glow=0.1, mouth="smile"),
            self.render(r=8, ray=1.05),
            self.render(r=8, ray=1.0),
            self.render(),
        ]
        ring_solid(f[2], 16, 16, 12.5, CYAN)
        star(f[2], 16, 2, WHITE)
        ring_solid(f[3], 16, 16, 14.5, CYAN)
        ring_solid(f[3], 16, 16, 15.5, VIOLET, skip=3)
        for x, y in ((3, 5), (28, 5), (3, 27), (28, 27)):
            star(f[3], x, y, WHITE)
        ring_solid(f[4], 16, 16, 15.5, CYAN, skip=4)
        dots(f[4], ((3, 6), (28, 6), (4, 26), (27, 26), (16, 1), (16, 30)), VIOLET)
        dots(f[5], ((2, 8), (29, 8), (3, 24), (28, 24)), CYAN)
        return f


TOWERS = [Macrophage(), MucusCell(), Interferon()]
