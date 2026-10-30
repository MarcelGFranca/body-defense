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



# --- the other seven towers ---------------------------------------------------

ORANGE = (255, 170, 80, 255)
FLAME = (255, 120, 40, 255)
ACID = (170, 255, 120, 255)
BONE = (240, 232, 205, 255)


def shape_ellipse(cx, cy, rx, ry):
    return ellipse(cx, cy, rx, ry)


class BlobTower(TowerArt):
    """Shared idea of the friendly cells: a shaded body, a face, details, and a squash-and-stretch attack."""

    color = (200, 200, 200)
    face_dy = -3
    mouth_dy = 1
    feet = False
    glow_color = WHITE

    def body(self, cx, cy, rx, ry, spin):
        return ellipse(cx, cy, rx, ry)

    def details(self, img, shape, cx, cy, rx, ry, spin):
        pass

    def render(self, cx=16, cy=17, rx=10.0, ry=10.0, spin=0.0, mouth="smile", eyes="open", glow=0.0):
        img = new_canvas()
        shape = self.body(cx, cy, rx, ry, spin)
        if self.feet:
            for dx in (-5, 4):
                shape |= ellipse(cx + dx + 1, cy + ry + 0.5, 2.6, 1.8)
        shade_ellipse(img, shape, cx, cy, rx + 1, ry + 1, bands(self.color))
        self.details(img, shape, cx, cy, rx, ry, spin)
        outline(img, shape)
        draw_eyes(img, round(cx), round(cy) + self.face_dy, eyes)
        draw_mouth(img, round(cx), round(cy) + self.mouth_dy, mouth)
        if glow:
            tint(img, self.glow_color, glow)
        return img

    def idle_frames(self):
        frames = []
        for i in range(8):
            wave = math.sin(2 * math.pi * i / 8)
            frames.append(self.render(cy=17 + 0.6 * wave, rx=10 + 0.5 * wave, ry=10 - 0.5 * wave, spin=0.05 * i,
                                      eyes="blink" if i == 6 else "open"))
        return frames

    def effect(self, frames):
        """Draws the attack effect on the frames (a list of 8 images)."""

    def attack_frames(self):
        f = [
            self.render(cy=18, rx=11, ry=9, eyes="angry", mouth="flat"),
            self.render(cy=18.5, rx=11.5, ry=8.5, eyes="angry", mouth="flat"),
            self.render(cy=16.5, rx=9.5, ry=10.8, eyes="wide", mouth="open"),
            self.render(cy=16.5, rx=9.3, ry=11, eyes="wide", mouth="open", glow=0.25),
            self.render(cy=17.5, rx=10.6, ry=9.4, eyes="wide", mouth="open", glow=0.1),
            self.render(cy=16.8, rx=10, ry=10.4, mouth="smile"),
            self.render(cy=17, rx=10.3, ry=9.9),
            self.render(),
        ]
        self.effect(f)
        return f


class Neutrophil(BlobTower):
    """A pale cell with a three-lobed nucleus that jabs again and again. Fixed, rapid fire."""

    id = "neutrophil"
    color = (205, 208, 236)
    glow_color = CYAN

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for dx, dy in ((-4, 4), (0, 6), (4, 4)):
            for x, y in disc(cx + dx, cy + dy, 2.3):
                if (x, y) in shape:
                    img.putpixel((x, y), (118, 84, 170, 255))

    def effect(self, f):
        for i in (2, 3, 4):
            dots(f[i], ((3, 8 + i), (2, 12 + i), (28, 9 + i), (29, 13 + i)), CYAN)
        star(f[3], 27, 5, YELLOW, big=True)
        star(f[3], 5, 6, WHITE)


class Platelet(BlobTower):
    """A small spiky fragment that sticks enemies in place. Fixed, root."""

    id = "platelet"
    color = (246, 168, 112)
    glow_color = ORANGE

    def body(self, cx, cy, rx, ry, spin):
        shape = ellipse(cx, cy, rx * 0.82, ry * 0.8)
        for i in range(7):
            a = i * 2 * math.pi / 7 + spin
            shape |= disc(cx + rx * 0.85 * math.cos(a), cy + ry * 0.82 * math.sin(a), 2.2)
        return shape

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for dx, dy in ((-5, 4), (5, 5), (0, 7), (6, -1), (-6, -2)):
            put(img, round(cx + dx), round(cy + dy), (200, 100, 60, 255))

    def effect(self, f):
        for i, size in ((2, 10), (3, 13), (4, 15)):
            for k in range(8):
                a = k * math.pi / 4
                for t in range(6, size):
                    if (t + k) % 2 == 0:
                        put(f[i], round(16 + t * math.cos(a)), round(17 + t * math.sin(a)), WHITE)
        dots(f[5], ((4, 6), (27, 6), (4, 27), (27, 27)), ORANGE)


class Hypothalamus(BlobTower):
    """A warm red cell with a little flame on its head that gives enemies a fever. Fixed, damage over time."""

    id = "hypothalamus"
    color = (232, 104, 84)
    face_dy = -1
    mouth_dy = 3
    glow_color = ORANGE

    def body(self, cx, cy, rx, ry, spin):
        return ellipse(cx, cy + 3, rx * 0.95, ry * 0.85)

    def details(self, img, shape, cx, cy, rx, ry, spin):
        flicker = math.sin(spin * 6)
        for x, y in disc(cx, cy - 5.5, 3.2) | disc(cx + flicker, cy - 9, 2.0):
            img.putpixel((x, y), FLAME)
        for x, y in disc(cx, cy - 5, 1.6) | disc(cx + flicker, cy - 8.5, 0.9):
            img.putpixel((x, y), YELLOW)
        for x, y in ((x, y) for x, y in disc(cx, cy - 5.5, 3.2) | disc(cx + flicker, cy - 9, 2.0)):
            shape.add((x, y))

    def effect(self, f):
        for i, r in ((2, 12), (3, 14), (4, 15)):
            ring_solid(f[i], 16, 18, r, ORANGE, skip=2)
        dots(f[3], ((5, 5), (26, 6), (3, 14), (28, 15)), FLAME)
        star(f[3], 16, 2, YELLOW)


class Lysozyme(BlobTower):
    """A green enzyme drop with a bubbling mouth that dissolves bacteria. Fixed, area, chemical."""

    id = "lysozyme"
    color = (112, 200, 120)
    glow_color = ACID

    def body(self, cx, cy, rx, ry, spin):
        shape = ellipse(cx, cy + 2, rx * 0.95, ry * 0.9)
        for k in range(5):
            shape.add((round(cx), round(cy - ry * 0.85 - 1 + k)))
        shape |= disc(cx, cy - 6.5, 3.2) - disc(cx, cy + 5, 1)
        return shape

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for dx, dy, r in ((-5, 4, 1.4), (5, 6, 1.1), (4, -1, 1.0)):
            for x, y in disc(cx + dx, cy + dy, r):
                if (x, y) in shape:
                    img.putpixel((x, y), (210, 255, 200, 255))

    def effect(self, f):
        # Two solid rings that spread out of the body and thin out, so the pulse reads at a glance.
        for i, r in ((1, 11), (2, 12), (3, 13), (4, 14), (5, 15)):
            ring_solid(f[i], 16, 17, r, ACID if i % 2 else WHITE)
        for i, r in ((3, 10), (4, 11), (5, 12), (6, 14)):
            ring_solid(f[i], 16, 17, r, ACID, skip=2)
        dots(f[3], ((4, 8), (27, 9), (3, 22), (28, 23), (16, 2)), ACID)
        dots(f[4], ((6, 5), (25, 6), (2, 16), (29, 17), (16, 31)), WHITE)
        dots(f[5], ((3, 4), (28, 5), (1, 27), (30, 28)), ACID)


class TLymphocyte(BlobTower):
    """A blue soldier cell with a big dark nucleus and little feet. Mobile, a heavy single hit."""

    id = "t-lymphocyte"
    color = (104, 144, 232)
    feet = True
    face_dy = -4
    mouth_dy = 0
    glow_color = CYAN

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for x, y in ellipse(cx, cy + 5, 6.2, 3.8):
            img.putpixel((x, y), (66, 50, 140, 255))
        for dx in (-8, 8):  # receptors
            for k in range(3):
                put(img, round(cx + dx * (1 + k * 0.12)), round(cy - 6 - k), (230, 240, 255, 255))

    def effect(self, f):
        for i in (2, 3):
            for t in range(14, 31):
                put(f[i], t, 15 + (i - 2), WHITE if t % 2 else CYAN)
        star(f[3], 28, 12, YELLOW, big=True)
        dots(f[4], ((26, 10), (28, 18), (24, 22)), CYAN)


class BLymphocyte(BlobTower):
    """A lilac cell that throws Y-shaped antibodies to mark enemies. Mobile, support."""

    id = "b-lymphocyte"
    color = (190, 124, 214)
    feet = True
    face_dy = -3
    mouth_dy = 1
    glow_color = VIOLET

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for x, y in ellipse(cx, cy + 5, 4.2, 2.8):
            img.putpixel((x, y), (118, 66, 160, 255))
        for dx, dy in ((-9, -5), (9, -5), (-9, 2), (9, 2)):  # antibodies on the surface
            ax, ay = round(cx + dx), round(cy + dy)
            for ox, oy in ((0, 0), (0, 1), (-1, -1), (1, -1)):
                put(img, ax + ox, ay + oy, (250, 240, 255, 255))

    def effect(self, f):
        for i, (ox, oy) in ((2, (6, 5)), (3, (4, 3)), (4, (2, 1))):
            for sx, sy in ((6, 6), (26, 6), (4, 24), (28, 24)):
                x = sx + (16 - sx) * 0 + (ox if sx < 16 else -ox) * 0
                for px, py in ((0, 0), (0, 1), (-1, -1), (1, -1)):
                    put(f[i], x + px, sy + py + (oy if sy < 16 else -oy) * 0, WHITE)
        dots(f[3], ((16, 2), (3, 14), (28, 14)), VIOLET)


class BoneMarrow(BlobTower):
    """A cream colored bone with a red heart of marrow that sends out neutrophils. Fixed, summoner."""

    id = "bone-marrow"
    color = (238, 226, 190)
    face_dy = -2
    mouth_dy = 2
    glow_color = (255, 120, 140, 255)

    def body(self, cx, cy, rx, ry, spin):
        shape = {(x, y) for x in range(round(cx - rx * 0.62), round(cx + rx * 0.62) + 1)
                 for y in range(round(cy - ry), round(cy + ry) + 1)}
        for ex in (-0.62, 0.62):
            for ey in (-1.0, 1.0):
                shape |= disc(cx + ex * rx, cy + ey * ry * 0.85, 3.6)
        return shape

    def details(self, img, shape, cx, cy, rx, ry, spin):
        for x, y in ellipse(cx, cy + 3, 5.0, 3.8):
            img.putpixel((x, y), (214, 70, 96, 255))
        for dx, dy in ((-3, 3), (1, 2), (3, 4)):
            put(img, round(cx + dx), round(cy + dy), (255, 150, 160, 255))

    def effect(self, f):
        for i, (x, y) in ((2, (6, 26)), (3, (3, 27)), (4, (2, 28))):
            for px, py in disc(x, y, 2.4):
                put(f[i], px, py, (230, 232, 250, 255))
            for px, py in disc(32 - x, y, 2.4):
                put(f[i], px, py, (230, 232, 250, 255))
        dots(f[3], ((16, 1), (4, 8), (28, 8)), (255, 120, 140, 255))


TOWERS = [Macrophage(), MucusCell(), Interferon(), Neutrophil(), Platelet(), Hypothalamus(), Lysozyme(),
          TLymphocyte(), BLymphocyte(), BoneMarrow()]
