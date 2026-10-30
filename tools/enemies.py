"""The three enemies of the first prototype: how each one draws a single 32x32 frame."""
import math

from PIL import Image

from pixel_art import (
    BAYER, CX, CY, OUTLINE, PUFF, SIZE, TONGUE, WHITE, EnemyArt, Palette, blob_layer, disc, dots, ellipse,
    outline, put, ring, shade_ellipse,
)


def draw_face_large(img, cx, cy, expr, look, style):
    """Face for the round viruses. `style` is "grumpy" (Rhinovirus) or "sly" (Influenza)."""
    ox, oy = round(cx) - 16, round(cy) - 17

    def p(x, y, c=OUTLINE):
        put(img, x + ox, y + oy, c)

    def eyes(pupil_dx, pupil_dy, height=4):
        for ex in (10, 18):
            for dx in range(4):
                for dy in range(height):
                    p(ex + dx, 14 + dy, WHITE)
            for dx in (0, 1):
                for dy in (0, 1):
                    p(ex + pupil_dx + dx, 14 + min(pupil_dy, height - 2) + dy)

    def brows():
        if style == "sly":
            for x, y in ((9, 12), (10, 12), (11, 13), (12, 13), (20, 13), (21, 12), (22, 12), (23, 11)):
                p(x, y)
        else:
            for x, y in ((9, 12), (10, 12), (11, 13), (12, 13), (20, 13), (21, 13), (22, 12), (23, 12)):
                p(x, y)

    def mouth():
        if style == "sly":
            for x, y in ((13, 21), (14, 22), (15, 23), (16, 23), (17, 23), (18, 23), (19, 22), (20, 21)):
                p(x, y)
            for x in (15, 16, 17, 18):
                p(x, 22, WHITE)
        else:
            for x, y in ((13, 23), (14, 22), (15, 21), (16, 21), (17, 21), (18, 21), (19, 22), (20, 23)):
                p(x, y)
            for x in (15, 16, 17, 18):
                p(x, 22, WHITE)

    if expr in ("normal", "smug"):
        eyes(*look, height=3 if style == "sly" else 4)
        brows()
        mouth()
    elif expr == "blink":
        for ex in (10, 18):
            for dx in range(4):
                p(ex + dx, 16)
            p(ex, 15)
            p(ex + 3, 15)
        brows()
        mouth()
    elif expr in ("angry", "angry_open"):
        eyes(1, 1)
        for x, y in ((9, 11), (10, 12), (11, 12), (12, 13), (13, 13), (24, 11), (23, 12), (22, 12), (21, 13), (20, 13)):
            p(x, y)
        if expr == "angry":
            mouth()
        else:
            for x in range(12, 22):
                for y in range(20, 25):
                    if not ((x in (12, 21)) and y in (20, 24)):
                        p(x, y)
            for x in (13, 15, 17, 19):
                p(x, 20, WHITE)
                p(x + 1, 20, WHITE)
            for x in (15, 16, 17, 18):
                p(x, 23, TONGUE)
    elif expr == "hurt":
        for x, y in ((10, 14), (11, 15), (12, 16), (11, 17), (10, 18),
                     (21, 14), (20, 15), (19, 16), (20, 17), (21, 18)):
            p(x, y)
        for x, y in ((14, 22), (15, 21), (16, 22), (17, 21), (18, 22), (19, 21)):
            p(x, y)
    elif expr == "dazed":
        eyes(*look)
        for x, y in ((15, 21), (16, 21), (14, 22), (17, 22), (15, 23), (16, 23)):
            p(x, y)
    elif expr == "dead":
        for ex in (10, 18):
            for d in range(4):
                p(ex + d, 14 + d)
                p(ex + 3 - d, 14 + d)
        for x in range(14, 20):
            p(x, 22)
        for x, y in ((17, 23), (18, 23), (18, 24)):
            p(x, y, TONGUE)
    elif expr == "sticky":
        for ex in (10, 18):
            for dx in range(4):
                for dy in (2, 3):
                    p(ex + dx, 14 + dy, WHITE)
                p(ex + dx, 15)
            p(ex + 1, 17)
            p(ex + 2, 17)
        for x in range(14, 20):
            p(x, 22)


class Rhinovirus(EnemyArt):
    """Cold virus: a grumpy green ball covered in round bumps. Swarm enemy."""

    id = "rhinovirus"
    piece_count = 14
    walk_fps = 10
    action_fps = 10
    palette = Palette(
        bands=((47, 122, 69, 255), (74, 165, 74, 255), (126, 217, 87, 255), (200, 245, 154, 255)),
        knob_lit=(230, 255, 158, 255),
        knob_shade=(160, 214, 96, 255),
        spray=(245, 235, 140, 255),
    )
    bump_count = 14
    bump_radius = 1.9

    def walk_angle(self, i):
        return i * (2 * math.pi / self.bump_count) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        body = ellipse(cx, cy, rx, ry)
        knobs = set()
        for i in range(self.bump_count):
            a = angle + i * 2 * math.pi / self.bump_count
            knobs |= disc(cx + (rx + 0.4) * math.cos(a), cy + (ry + 0.4) * math.sin(a), self.bump_radius)
        shade_ellipse(img, body, cx, cy, rx, ry, p.bands)
        for x, y in knobs - body:
            img.putpixel((x, y), p.knob_lit if (x - cx) + (y - cy) < -3 else p.knob_shade)
        outline(img, body | knobs)
        draw_face_large(img, cx, cy, expr, look, "grumpy")
        return img


class Influenza(EnemyArt):
    """Flu virus: a sly orange ball with long red-tipped spikes. Fast enemy."""

    id = "influenza"
    piece_count = 12
    walk_fps = 14
    action_fps = 12
    palette = Palette(
        bands=((166, 64, 40, 255), (214, 104, 52, 255), (244, 150, 66, 255), (255, 204, 120, 255)),
        knob_lit=(232, 80, 60, 255),
        knob_shade=(176, 48, 52, 255),
        spray=(255, 236, 200, 255),
    )
    spike_count = 12
    shaft_lit = (255, 214, 130, 255)
    shaft_shade = (210, 160, 90, 255)

    def walk_angle(self, i):
        return i * 2 * (2 * math.pi / self.spike_count) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        brx, bry = 8.6 * rx / 10, 8.6 * ry / 10
        body = ellipse(cx, cy, brx, bry)
        shafts, tips = set(), set()
        for i in range(self.spike_count):
            a = angle + i * 2 * math.pi / self.spike_count
            for k in range(7):
                t = k * 0.55
                shafts |= disc(cx + (brx + t) * math.cos(a), cy + (bry + t) * math.sin(a), 0.9)
            tips |= disc(cx + (brx + 3.9) * math.cos(a), cy + (bry + 3.9) * math.sin(a), 1.5)
        shade_ellipse(img, body, cx, cy, brx, bry, p.bands)
        for x, y in shafts - body:
            img.putpixel((x, y), self.shaft_lit if (x - cx) + (y - cy) < -3 else self.shaft_shade)
        for x, y in tips - body:
            img.putpixel((x, y), p.knob_lit if (x - cx) + (y - cy) < -3 else p.knob_shade)
        outline(img, body | shafts | tips)
        draw_face_large(img, cx, cy, expr, look, "sly")
        return img


def draw_small_face(img, ci, cj, expr, look):
    """Face for the big coccus of the Streptococcus chain, centered on pixel (ci, cj)."""
    def p(dx, dy, c=OUTLINE):
        put(img, ci + dx, cj + dy, c)

    left, right = -4, 1
    pdx, pdy = min(1, look[0]), min(1, look[1])

    def eyes():
        for ex in (left, right):
            for dx in range(3):
                for dy in range(3):
                    p(ex + dx, -3 + dy, WHITE)
            for dx in (0, 1):
                for dy in (0, 1):
                    p(ex + pdx + dx, -3 + pdy + dy)

    def brows(steep=False):
        top = -6 if steep else -5
        for dx, dy in ((-5, top), (-4, top), (-3, -4), (4, top), (3, top), (2, -4)):
            p(dx, dy)

    if expr in ("normal", "dazed", "smug"):
        eyes()
        if expr == "smug":
            for ex in (left, right):
                for dx in range(3):
                    p(ex + dx, -3)
            for dx, dy in ((-2, 3), (-1, 3), (0, 3), (1, 3), (2, 2), (3, 1)):
                p(dx, dy)
        elif expr == "dazed":
            for dx, dy in ((-1, 2), (0, 2), (-2, 3), (1, 3), (-1, 4), (0, 4)):
                p(dx, dy)
        else:
            for dx, dy in ((-2, 3), (-1, 3), (0, 3), (1, 3), (2, 2)):
                p(dx, dy)
        if expr != "dazed":
            brows()
    elif expr == "blink":
        for ex in (left, right):
            for dx in range(3):
                p(ex + dx, -2)
        brows()
        for dx, dy in ((-2, 3), (-1, 3), (0, 3), (1, 3), (2, 2)):
            p(dx, dy)
    elif expr in ("angry", "angry_open"):
        eyes()
        brows(steep=True)
        if expr == "angry":
            for dx, dy in ((-2, 4), (-1, 3), (0, 3), (1, 4)):
                p(dx, dy)
        else:
            for dx in range(-2, 2):
                for dy in range(2, 5):
                    p(dx, dy)
            for dx in (-2, 0):
                p(dx, 2, WHITE)
                p(dx + 1, 2, WHITE)
            for dx in (-1, 0):
                p(dx, 4, TONGUE)
    elif expr == "hurt":
        for dx, dy in ((-4, -3), (-3, -2), (-2, -2), (-4, -1), (3, -3), (2, -2), (1, -2), (3, -1)):
            p(dx, dy)
        for dx, dy in ((-2, 3), (-1, 2), (0, 3), (1, 2)):
            p(dx, dy)
    elif expr == "dead":
        for ex in (left, right):
            for d in range(3):
                p(ex + d, -3 + d)
                p(ex + 2 - d, -3 + d)
        for dx in range(-2, 2):
            p(dx, 3)
        for dx, dy in ((0, 4), (1, 4)):
            p(dx, dy, TONGUE)
    elif expr == "sticky":
        for ex in (left, right):
            for dx in range(3):
                p(ex + dx, -3)
                p(ex + dx, -2, WHITE)
                p(ex + dx, -1, WHITE)
            p(ex + 1, -1)
        for dx in range(-2, 2):
            p(dx, 3)


def draw_mini_face(img, ci, cj, expr):
    """Tiny face for the two small cocci at the ends of the chain."""
    def p(dx, dy, c=OUTLINE):
        put(img, ci + dx, cj + dy, c)

    if expr in ("hurt", "dead"):
        for dx, dy in ((-3, -2), (-2, -1), (2, -2), (1, -1)):
            p(dx, dy)
    elif expr in ("blink", "sticky"):
        for dx in (-3, -2, 1, 2):
            p(dx, -1)
    else:
        for ex in (-3, 1):
            for dx in range(2):
                for dy in range(2):
                    p(ex + dx, -2 + dy, WHITE)
            p(ex + 1, -1)
    for dx in (-1, 0):
        p(dx, 2)


class StreptococcusPyogenes(EnemyArt):
    """Strep throat bacterium: a chain of three purple cocci. The chain trait is off in the prototype."""

    id = "streptococcus-pyogenes"
    piece_count = 8
    walk_fps = 8
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((74, 52, 150, 255), (108, 80, 196, 255), (146, 112, 232, 255), (200, 176, 255, 255)),
        knob_lit=(214, 190, 255, 255),
        knob_shade=(150, 120, 214, 255),
        spray=(232, 214, 255, 255),
    )
    # (dx, dy, radius) of each coccus, along the chain from the lower left to the upper right
    chain = ((-8, 5, 6.2), (0, 0, 7.4), (8, -5, 6.2))
    draw_order = (0, 2, 1)

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        sx, sy = 1 + (rx / 10 - 1) * 0.5, 1 + (ry / 10 - 1) * 0.5
        centers = []
        for n, (dx, dy, r) in enumerate(self.chain):
            wiggle = 1.1 * math.sin(angle - n * 1.3)
            centers.append((cx + dx * sx, cy + dy * sy + wiggle, r * sx, r * sy))
        drawn = set()
        for n in self.draw_order:
            ccx, ccy, rrx, rry = centers[n]
            mask = ellipse(ccx, ccy, rrx, rry)
            shade_ellipse(img, mask, ccx, ccy, rrx, rry, p.bands)
            for x, y in mask:
                if any((x + dx, y + dy) not in mask and (x + dx, y + dy) in drawn
                       for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    img.putpixel((x, y), OUTLINE)
            drawn |= mask
        outline(img, drawn)
        for n in (0, 2):
            draw_mini_face(img, round(centers[n][0]), round(centers[n][1]), expr)
        draw_small_face(img, round(centers[1][0]), round(centers[1][1]), expr, look)
        return img

    def burst(self, step):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        if step <= 2:
            spread = (1.3, 1.6, 1.9)[step]
            radius = (4.4, 3.6, 2.8)[step]
            for dx, dy, _ in self.chain:
                img.alpha_composite(blob_layer(disc(CX + dx * spread, CY + dy * spread, radius), p.bands[2]))
            if step < 2:
                ring(img, CX, CY, (12.5, 14.5)[step], WHITE, skip=step + 1)
        elif step == 3:
            for k in range(8):
                a = k * math.pi / 4 + 0.4
                img.alpha_composite(blob_layer(disc(CX + 9 * math.cos(a), CY + 9 * math.sin(a), 1.8), p.knob_lit))
            dots(img, ((16, 17), (15, 16), (17, 18)), p.bands[2])
        elif step == 4:
            for x, y in disc(16, 16, 6.5):
                if BAYER[y % 4][x % 4] < 9:
                    img.putpixel((x, y), PUFF)
            dots(img, ((5, 10), (27, 10), (8, 26), (24, 27), (3, 18), (29, 20)), p.knob_shade)
        else:
            for x, y in disc(16, 15, 7):
                if BAYER[y % 4][x % 4] < 3:
                    img.putpixel((x, y), PUFF)
            dots(img, ((6, 8), (26, 9), (9, 25)), WHITE)
        return img


ENEMIES = [Rhinovirus(), Influenza(), StreptococcusPyogenes()]
