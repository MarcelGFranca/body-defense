"""Shared pixel-art helpers and generic animation builders for the enemy sprites.

Every enemy is an `EnemyArt` subclass (see enemies.py) that knows how to render one
32x32 frame. The builders below turn that into the full set of 8-frame animations.
"""
import math
from dataclasses import dataclass

from PIL import Image

SIZE = 32
CX, CY = 16, 17

OUTLINE = (43, 27, 58, 255)
WHITE = (255, 255, 255, 255)
CYAN = (110, 230, 255, 255)
VIOLET = (190, 130, 255, 255)
YELLOW = (255, 240, 130, 255)
RED = (230, 60, 60, 255)
TONGUE = (255, 100, 120, 255)
GOO = (214, 196, 72, 255)
GOO_LIGHT = (245, 235, 140, 255)
GOO_DARK = (168, 148, 48, 255)
DUST = (214, 200, 214, 255)
PUFF = (236, 230, 240, 255)
BG = (58, 31, 43, 255)

BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

# Key frames kept from the long sequences below: every animation ends up with 8 frames.
KEEP = {
    "hit_physical": [0, 1, 3, 4, 5, 6, 8, 9],
    "hit_antiviral": [0, 1, 2, 3, 4, 6, 8, 11],
    "hit_mucus": [0, 2, 4, 6, 7, 8, 10, 11],
    "attack": [0, 2, 4, 5, 6, 7, 9, 12],
    "death": [0, 3, 5, 7, 8, 9, 11, 14],
}


@dataclass(frozen=True)
class Palette:
    bands: tuple  # four body shades, darkest to lightest
    knob_lit: tuple  # lit side of spikes, bumps and death fragments
    knob_shade: tuple  # shaded side of the same
    spray: tuple  # droplets released by the attack


def put(img, x, y, color):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        img.putpixel((x, y), color)


def disc(cx, cy, radius):
    return {
        (x, y)
        for x in range(max(0, int(cx - radius) - 1), min(SIZE, int(cx + radius) + 2))
        for y in range(max(0, int(cy - radius) - 1), min(SIZE, int(cy + radius) + 2))
        if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 <= radius ** 2
    }


def ellipse(cx, cy, rx, ry):
    return {
        (x, y)
        for x in range(SIZE)
        for y in range(SIZE)
        if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1
    }


def shade_ellipse(img, pixels, cx, cy, rx, ry, bands):
    """Light from the top-left corner, with ordered dithering at the band edges."""
    for x, y in pixels:
        nx = (x + 0.5 - cx) / rx
        ny = (y + 0.5 - cy) / ry
        level = (-0.6 * nx - 0.8 * ny + 1) / 2 * 3.2
        band = int(level + (BAYER[y % 4][x % 4] / 16 - 0.5) * 0.5)
        img.putpixel((x, y), bands[max(0, min(3, band))])


def outline(img, filled):
    edge = set()
    for x, y in filled:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n not in filled and 0 <= n[0] < SIZE and 0 <= n[1] < SIZE:
                edge.add(n)
    for p in edge:
        img.putpixel(p, OUTLINE)


def tint(img, color, amount):
    for x in range(SIZE):
        for y in range(SIZE):
            px = img.getpixel((x, y))
            if px[3] and px != OUTLINE:
                img.putpixel((x, y), tuple(round(px[i] + (color[i] - px[i]) * amount) for i in range(3)) + (255,))
    return img


def holes(img, density):
    for x in range(SIZE):
        for y in range(SIZE):
            px = img.getpixel((x, y))
            if px[3] and px != OUTLINE and BAYER[y % 4][x % 4] < density * 16:
                img.putpixel((x, y), (0, 0, 0, 0))
    return img


def scan(img, phase, color):
    for y in range(SIZE):
        if (y + phase) % 5 == 0:
            for x in range(SIZE):
                px = img.getpixel((x, y))
                if px[3] and px != OUTLINE:
                    img.putpixel((x, y), tuple(round(px[i] + (color[i] - px[i]) * 0.7) for i in range(3)) + (255,))
    return img


def star(img, x, y, color, big=False):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        put(img, x + dx, y + dy, color)
    if big:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)):
            put(img, x + dx, y + dy, color)


def anger_mark(img, x, y):
    for dx, dy in ((2, 0), (2, 1), (2, 3), (2, 4), (0, 2), (1, 2), (3, 2), (4, 2)):
        put(img, x + dx, y + dy, RED)


def dots(img, points, color):
    for x, y in points:
        put(img, x, y, color)


def dizzy_stars(img, phase):
    for k in range(3):
        a = phase + k * 2 * math.pi / 3
        star(img, round(16 + 9 * math.cos(a)), round(5 + 2 * math.sin(a)), YELLOW)


def ring(img, cx, cy, radius, color, skip=1):
    for step in range(0, 360, 6):
        if (step // 6) % skip == 0:
            a = math.radians(step)
            put(img, round(cx + radius * math.cos(a)), round(cy + radius * math.sin(a)), color)


def shield_arc(img, cx, cy, radius, color, skip=1):
    for k, deg in enumerate(range(110, 251, 4)):
        if k % skip == 0:
            a = math.radians(deg)
            put(img, round(cx + radius * math.cos(a)), round(cy + radius * math.sin(a)), color)


def cracks(img, cx, cy, length):
    for a in (-0.6, 0.5, 2.3, 3.9, 5.2):
        x, y = cx, cy
        for t in range(length):
            x += math.cos(a) + (0.6 if t % 3 == 1 else -0.4) * math.sin(a)
            y += math.sin(a) - (0.6 if t % 3 == 1 else -0.4) * math.cos(a)
            if 0 <= round(x) < SIZE and 0 <= round(y) < SIZE:
                px = img.getpixel((round(x), round(y)))
                if px[3] and px != OUTLINE:
                    put(img, round(x), round(y), OUTLINE)


def goo(img, coverage):
    for x in range(SIZE):
        for y in range(SIZE):
            px = img.getpixel((x, y))
            if not px[3] or px == OUTLINE or (9 <= x <= 24 and 11 <= y <= 25):
                continue
            if BAYER[y % 4][x % 4] / 16 < coverage:
                img.putpixel((x, y), GOO_LIGHT if (x + y) % 5 == 0 else GOO)
    for x, length in ((10, 2), (13, 3), (16, 4), (19, 3), (22, 2)):
        lowest = max((y for y in range(SIZE) if img.getpixel((x, y))[3]), default=None)
        if lowest is None:
            continue
        for d in range(int(length * coverage * 1.4) + 1):
            put(img, x, lowest + 1 + d, GOO_DARK if d else GOO)
    return img


def bubble(img, x, y, r=1.4):
    filled = disc(x, y, r)
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    for px in filled:
        layer.putpixel(px, GOO_LIGHT)
    outline(layer, filled)
    img.alpha_composite(layer)


def blob_layer(filled, color):
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    for px in filled:
        layer.putpixel(px, color)
    outline(layer, filled)
    return layer


def fragments(radius, size, color, count, offset=0.0):
    filled = set()
    for i in range(count):
        a = offset + i * 2 * math.pi / count
        filled |= disc(CX + radius * math.cos(a), CY + radius * math.sin(a), size)
    return blob_layer(filled, color)


def spray(img, step, color):
    sets = (
        ((4, 21), (27, 21), (3, 25), (28, 24)),
        ((2, 19), (29, 19), (2, 24), (29, 26), (5, 28), (26, 28)),
        ((1, 17), (30, 17), (1, 22), (30, 23), (3, 27), (28, 28), (1, 12), (30, 12)),
        ((0, 14), (31, 14), (0, 21), (31, 21), (2, 28)),
    )
    dots(img, sets[step], color)
    if step < 2:
        dots(img, ((sets[step][0][0] + 1, sets[step][0][1]), (sets[step][1][0] - 1, sets[step][1][1])), GOO)


class EnemyArt:
    """Base class: subclasses draw one frame; the builders below make the animations."""

    id = ""
    palette = None
    piece_count = 14  # fragments in the death burst
    walk_fps = 10
    action_fps = 10
    immune_to_antiviral = False

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        raise NotImplementedError

    def walk_angle(self, i):
        return 0.0

    def burst(self, step):
        """Death burst frame `step` (0..5): fragments flying outward, then fading."""
        p = self.palette
        half = math.pi / self.piece_count
        if step == 0:
            img = fragments(7, 2.0, p.knob_lit, self.piece_count)
            img.alpha_composite(fragments(3.5, 2.0, p.bands[2], 7, half))
            ring(img, CX, CY, 12.5, WHITE)
        elif step == 1:
            img = fragments(10.5, 1.6, p.knob_lit, self.piece_count)
            img.alpha_composite(fragments(6.5, 1.7, p.bands[2], 7, half))
            ring(img, CX, CY, 14.5, WHITE, skip=2)
        elif step == 2:
            img = fragments(12.5, 1.2, p.knob_lit, self.piece_count)
            img.alpha_composite(fragments(9, 1.3, p.bands[2], 7, half))
            dots(img, ((16, 17), (15, 16), (17, 18), (13, 20), (19, 14)), p.bands[2])
        elif step == 3:
            img = fragments(14, 0.9, p.knob_shade, self.piece_count)
            img.alpha_composite(fragments(10.5, 1.0, p.bands[2], 7, half))
            blob = disc(16, 17, 4.5)
            img.alpha_composite(blob_layer(blob, PUFF))
        elif step == 4:
            img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
            for x, y in disc(16, 16, 6.5):
                if BAYER[y % 4][x % 4] < 9:
                    img.putpixel((x, y), PUFF)
            dots(img, ((5, 10), (27, 10), (8, 26), (24, 27), (3, 18), (29, 20)), p.knob_shade)
        else:
            img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
            for x, y in disc(16, 15, 7):
                if BAYER[y % 4][x % 4] < 3:
                    img.putpixel((x, y), PUFF)
            dots(img, ((6, 8), (26, 9), (9, 25)), WHITE)
        return img


def walk_frames(art):
    frames = []
    for i in range(8):
        phase = (i % 4) / 4
        h = math.sin(math.pi * phase)
        land = (1 - h) ** 4
        dy = -2.4 * h + 0.8 * land
        rx = 10 + 0.7 * land - 0.4 * h
        ry = 10 - 0.7 * land + 0.4 * h
        expr = "blink" if i == 6 else "normal"
        look = (1, 2) if i < 4 else (2, 2)
        img = art.render(cy=CY + dy, rx=rx, ry=ry, angle=art.walk_angle(i), expr=expr, look=look)
        if land > 0.5:
            dots(img, ((5, 28), (4, 29), (3, 29), (26, 28), (27, 29), (28, 29)), DUST)
        elif i % 4 == 1:
            dots(img, ((3, 27), (28, 27)), DUST)
        frames.append(img)
    return frames


def hit_physical_frames(art):
    r = art.render
    f = []
    img = tint(r(cx=14.5, rx=8.5, ry=11, expr="hurt"), WHITE, 1.0)
    star(img, 4, 14, YELLOW, big=True)
    dots(img, ((1, 10), (2, 11), (1, 18), (2, 17)), WHITE)
    f.append(img)
    img = tint(r(cx=14, rx=7.8, ry=11.5, expr="hurt"), WHITE, 0.5)
    star(img, 4, 14, WHITE)
    dots(img, ((1, 8), (2, 9), (1, 20), (2, 19)), WHITE)
    f.append(img)
    f.append(r(cx=15, rx=9, ry=10.6, expr="hurt"))
    f.append(r(cx=18, cy=18, rx=11.5, ry=8, expr="hurt"))
    img = r(cx=16.5, rx=9, ry=11.2, expr="dazed", look=(0, 0))
    dizzy_stars(img, 0.0)
    f.append(img)
    img = r(cy=17.6, rx=10.6, ry=9.4, expr="dazed", look=(2, 1))
    dizzy_stars(img, 1.4)
    f.append(img)
    img = r(rx=9.6, ry=10.4, expr="dazed", look=(0, 2))
    dizzy_stars(img, 2.8)
    f.append(img)
    img = r(rx=10.2, ry=9.8, expr="dazed", look=(1, 1))
    dizzy_stars(img, 4.2)
    f.append(img)
    f.append(r(rx=10, ry=10, expr="blink"))
    f.append(r())
    return f


def hit_antiviral_frames(art):
    r = art.render
    f = []
    img = tint(r(cx=17, expr="hurt"), CYAN, 0.7)
    star(img, 5, 8, CYAN, big=True)
    star(img, 27, 25, WHITE)
    f.append(img)
    img = scan(r(cx=15, expr="hurt"), 0, CYAN)
    star(img, 27, 9, VIOLET)
    star(img, 5, 25, CYAN)
    f.append(img)
    img = holes(tint(r(cx=17, rx=9.8, ry=9.8, expr="hurt"), CYAN, 0.8), 0.18)
    star(img, 6, 24, VIOLET, big=True)
    star(img, 26, 8, CYAN)
    f.append(img)
    img = scan(holes(tint(r(cx=15, rx=9.5, ry=9.5, expr="hurt"), VIOLET, 0.5), 0.35), 2, CYAN)
    star(img, 27, 24, WHITE, big=True)
    f.append(img)
    img = holes(tint(r(cx=16.5, rx=9, ry=9, expr="hurt"), VIOLET, 0.6), 0.55)
    dots(img, ((8, 6), (24, 7), (6, 26), (26, 27), (4, 16), (28, 14)), CYAN)
    f.append(img)
    img = holes(tint(r(cx=15.5, rx=9.3, ry=9.3, expr="hurt"), CYAN, 0.6), 0.4)
    star(img, 6, 8, VIOLET)
    f.append(img)
    img = scan(holes(tint(r(cx=16.5, rx=9.6, ry=9.6, expr="hurt"), CYAN, 0.4), 0.22), 4, CYAN)
    f.append(img)
    img = holes(tint(r(rx=9.8, ry=9.8, expr="hurt"), VIOLET, 0.3), 0.1)
    star(img, 26, 8, CYAN)
    f.append(img)
    img = tint(r(rx=10.3, ry=9.7, expr="hurt"), CYAN, 0.2)
    star(img, 5, 25, WHITE)
    f.append(img)
    f.append(r(expr="hurt"))
    f.append(r(expr="blink"))
    f.append(r())
    return f


def immune_antiviral_frames(art):
    """Bacteria are unaffected by antiviral damage: the attack bounces off a shield."""
    r = art.render
    f = []
    img = r(cx=16, expr="normal", look=(0, 2))
    star(img, 3, 14, CYAN, big=True)
    f.append(img)
    img = r(cx=15.4, expr="smug", look=(0, 2))
    shield_arc(img, 16, 17, 13.6, CYAN)
    star(img, 2, 17, WHITE)
    f.append(img)
    img = r(cx=15.6, expr="smug", look=(0, 2))
    shield_arc(img, 16, 17, 13.6, CYAN)
    dots(img, ((2, 10), (3, 8), (2, 24), (3, 26)), CYAN)
    f.append(img)
    img = r(cx=15.8, expr="smug", look=(1, 2))
    shield_arc(img, 16, 17, 13.6, (200, 245, 255, 255))
    dots(img, ((1, 6), (5, 5), (1, 28), (5, 29)), CYAN)
    f.append(img)
    img = r(expr="smug", look=(1, 2))
    shield_arc(img, 16, 17, 13.6, CYAN, skip=2)
    dots(img, ((0, 3), (7, 3), (0, 30)), WHITE)
    f.append(img)
    img = r(expr="smug", look=(2, 2))
    shield_arc(img, 16, 17, 13.6, CYAN, skip=4)
    f.append(img)
    f.append(r(expr="smug", look=(2, 2)))
    f.append(r())
    return f


def hit_mucus_frames(art):
    r = art.render
    f = []
    coverage = [0.15, 0.3, 0.45, 0.6, 0.72, 0.82, 0.9]
    ry_list = [10, 9.8, 9.5, 9.3, 9.1, 9.0, 9.0]
    for i in range(7):
        ry = ry_list[i]
        cy = 17 + (10 - ry)
        img = r(cy=cy, rx=10 + (10 - ry) * 0.5, ry=ry, expr="blink" if i == 4 else "sticky")
        goo(img, coverage[i])
        if i in (2, 5):
            bubble(img, 24, 5)
        if i in (3, 6):
            bubble(img, 8, 6)
        if i == 6:
            dots(img, ((10, 30), (22, 31)), GOO)
        f.append(img)
    for cx, rx, ry, cy in ((16.7, 9.4, 9.9, 17), (15.3, 9.2, 10.1, 16.8), (16.6, 9.8, 9.4, 17.4), (16, 10.2, 9.0, 17.9),
                           (16, 10.3, 9.0, 17.9)):
        img = r(cx=cx, cy=cy, rx=rx, ry=ry, expr="sticky")
        goo(img, 0.9)
        f.append(img)
    bubble(f[8], 24, 6)
    bubble(f[10], 8, 5)
    dots(f[9], ((12, 30), (20, 31)), GOO)
    return f


def attack_frames(art):
    r = art.render
    sp = art.palette.spray
    f = []
    f.append(r(cy=17.4, rx=10.4, ry=9.6, expr="angry"))
    f.append(r(cy=18.4, rx=11, ry=8.6, expr="angry"))
    f.append(r(cx=15.6, cy=19, rx=11.5, ry=8, expr="angry"))
    img = tint(r(cx=16.6, cy=19, rx=11.5, ry=8, expr="angry"), RED, 0.15)
    anger_mark(img, 25, 3)
    f.append(img)
    img = tint(r(cx=15.6, cy=19, rx=11.5, ry=8, expr="angry"), RED, 0.3)
    anger_mark(img, 25, 3)
    anger_mark(img, 3, 3)
    f.append(img)
    img = r(cy=16.4, rx=8.2, ry=11.8, expr="angry_open")
    anger_mark(img, 3, 3)
    anger_mark(img, 25, 3)
    f.append(img)
    img = r(cy=18.7, rx=10.8, ry=10, expr="angry_open")
    dots(img, ((8, 2), (8, 3), (16, 1), (16, 2), (24, 2), (24, 3)), WHITE)
    spray(img, 0, sp)
    f.append(img)
    img = tint(r(cy=18.6, rx=11, ry=10.2, expr="angry_open"), RED, 0.3)
    anger_mark(img, 3, 3)
    anger_mark(img, 25, 3)
    spray(img, 1, sp)
    f.append(img)
    img = tint(r(cy=18.2, rx=10.6, ry=10.4, expr="angry_open"), RED, 0.2)
    spray(img, 2, sp)
    f.append(img)
    img = r(cy=16.8, rx=9.2, ry=10.8, expr="angry")
    spray(img, 3, sp)
    f.append(img)
    f.append(r(cy=17.4, rx=10.6, ry=9.6, expr="angry"))
    f.append(r(rx=9.8, ry=10.2, expr="normal", look=(2, 2)))
    f.append(r())
    return f


def death_frames(art):
    r = art.render
    f = []
    img = tint(r(rx=10, ry=10, expr="hurt"), WHITE, 1.0)
    star(img, 4, 14, YELLOW, big=True)
    f.append(img)
    f.append(tint(r(cx=14.5, rx=9, ry=11, expr="hurt"), WHITE, 0.5))
    f.append(r(cx=14.5, rx=9.6, ry=10.6, expr="hurt"))
    f.append(tint(r(cx=17.5, rx=10.5, ry=10, expr="hurt"), RED, 0.2))
    f.append(tint(r(cx=15.6, rx=11, ry=11, expr="hurt"), RED, 0.4))
    f.append(tint(r(cx=16.4, rx=11.6, ry=11.6, expr="hurt"), RED, 0.5))
    img = tint(r(cx=15.6, rx=12, ry=12, expr="dead"), WHITE, 0.4)
    cracks(img, 16, 17, 4)
    f.append(img)
    img = tint(r(cx=16.4, rx=12.2, ry=12.2, expr="dead"), WHITE, 0.65)
    cracks(img, 16, 17, 8)
    star(img, 26, 7, WHITE)
    star(img, 6, 27, CYAN)
    f.append(img)
    img = tint(r(rx=12.4, ry=12.4, expr="dead"), WHITE, 1.0)
    cracks(img, 16, 17, 10)
    star(img, 26, 7, WHITE, big=True)
    star(img, 6, 7, WHITE)
    star(img, 26, 27, WHITE)
    star(img, 6, 27, WHITE, big=True)
    f.append(img)
    for step in range(6):
        f.append(art.burst(step))
    return f


def build_animations(art):
    """Returns {name: (frames, fps, loop)} with exactly 8 frames per animation."""
    antiviral_name = "immune_antiviral" if art.immune_to_antiviral else "hit_antiviral"
    antiviral = immune_antiviral_frames(art) if art.immune_to_antiviral else hit_antiviral_frames(art)
    full = {
        "walk": (walk_frames(art), art.walk_fps, True),
        "hit_physical": (hit_physical_frames(art), art.action_fps, False),
        antiviral_name: (antiviral, art.action_fps, False),
        "hit_mucus": (hit_mucus_frames(art), 8, False),
        "attack": (attack_frames(art), art.action_fps, False),
        "death": (death_frames(art), 8, False),
    }
    out = {}
    for name, (frames, fps, loop) in full.items():
        keep = KEEP.get("hit_antiviral" if name == "immune_antiviral" else name)
        if keep and name != "immune_antiviral":
            frames = [frames[i] for i in keep]
        assert len(frames) == 8, name
        out[name] = (frames, fps, loop)
    return out
