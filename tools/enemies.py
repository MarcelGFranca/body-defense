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
        # Every enemy looks angry: the brows slope down towards the nose.
        for x, y in ((9, 11), (10, 12), (11, 12), (12, 13), (13, 13), (24, 11), (23, 12), (22, 12), (21, 13), (20, 13)):
            p(x, y)

    def mouth():
        # A frown with teeth, never a smile.
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
        if expr == "dazed":
            for dx, dy in ((-1, 2), (0, 2), (-2, 3), (1, 3), (-1, 4), (0, 4)):
                p(dx, dy)
        else:
            # Angry, never smiling: steep brows and a frown.
            for dx, dy in ((-2, 4), (-1, 3), (0, 3), (1, 4)):
                p(dx, dy)
            brows(steep=True)
    elif expr == "blink":
        for ex in (left, right):
            for dx in range(3):
                p(ex + dx, -2)
        brows(steep=True)
        for dx, dy in ((-2, 4), (-1, 3), (0, 3), (1, 4)):
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
        # Angry brows and a frown.
        for dx, dy in ((-3, -4), (-2, -3), (2, -4), (1, -3)):
            p(dx, dy)
    for dx, dy in ((-1, 2), (0, 2)) if expr in ("hurt", "dead", "blink", "sticky") else ((-2, 3), (-1, 2), (0, 2), (1, 3)):
        p(dx, dy)


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




# --- the other ten enemies ----------------------------------------------------

def capsule(cx, cy, half, radius, tilt=0.0):
    """A rod: discs along a line, `half` pixels to each side of the center."""
    filled = set()
    steps = max(2, int(half * 3))
    for k in range(steps + 1):
        t = -half + 2 * half * k / steps
        filled |= disc(cx + t * math.cos(tilt), cy + t * math.sin(tilt), radius)
    return filled


def hexagon(cx, cy, radius, angle=0.0):
    corners = [(cx + radius * math.cos(angle + i * math.pi / 3), cy + radius * math.sin(angle + i * math.pi / 3))
               for i in range(6)]
    filled = set()
    for x in range(SIZE):
        for y in range(SIZE):
            inside = True
            for i in range(6):
                (x1, y1), (x2, y2) = corners[i], corners[(i + 1) % 6]
                if (x2 - x1) * (y + 0.5 - y1) - (y2 - y1) * (x + 0.5 - x1) < 0:
                    inside = False
                    break
            if inside:
                filled.add((x, y))
    return filled


def line_pixels(x1, y1, x2, y2, width=0.8):
    filled = set()
    steps = int(max(abs(x2 - x1), abs(y2 - y1)) * 2) + 1
    for k in range(steps + 1):
        t = k / steps
        filled |= disc(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t, width)
    return filled


class SarsCov2(Influenza):
    """Coronavirus: a magenta ball with a crown of club-shaped spikes. Releases small viruses when it dies."""

    id = "sars-cov-2"
    spike_count = 10
    palette = Palette(
        bands=((110, 36, 120, 255), (156, 60, 160, 255), (204, 96, 196, 255), (240, 160, 232, 255)),
        knob_lit=(150, 255, 214, 255),
        knob_shade=(72, 190, 150, 255),
        spray=(210, 255, 236, 255),
    )
    shaft_lit = (236, 170, 236, 255)
    shaft_shade = (170, 100, 170, 255)

    def walk_angle(self, i):
        return i * 2 * (2 * math.pi / self.spike_count) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        brx, bry = 8.4 * rx / 10, 8.4 * ry / 10
        body = ellipse(cx, cy, brx, bry)
        shafts, tips = set(), set()
        for i in range(self.spike_count):
            a = angle + i * 2 * math.pi / self.spike_count
            for k in range(5):
                shafts |= disc(cx + (brx + k * 0.6) * math.cos(a), cy + (bry + k * 0.6) * math.sin(a), 0.8)
            tips |= disc(cx + (brx + 3.6) * math.cos(a), cy + (bry + 3.6) * math.sin(a), 2.0)
        shade_ellipse(img, body, cx, cy, brx, bry, p.bands)
        for x, y in shafts - body:
            img.putpixel((x, y), self.shaft_lit if (x - cx) + (y - cy) < -3 else self.shaft_shade)
        for x, y in tips - body:
            img.putpixel((x, y), p.knob_lit if (x - cx) + (y - cy) < -3 else p.knob_shade)
        outline(img, body | shafts | tips)
        draw_face_large(img, cx, cy, expr, look, "sly")
        return img


class HerpesSimplex(EnemyArt):
    """Herpes virus: a lavender hexagonal capsid inside a pale envelope. Goes dormant now and then."""

    id = "herpes-simplex"
    piece_count = 12
    walk_fps = 9
    action_fps = 10
    palette = Palette(
        bands=((74, 70, 150, 255), (110, 104, 200, 255), (150, 146, 236, 255), (206, 204, 255, 255)),
        knob_lit=(226, 226, 255, 255),
        knob_shade=(150, 146, 214, 255),
        spray=(230, 230, 255, 255),
    )

    def walk_angle(self, i):
        return i * (math.pi / 3) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        envelope = ellipse(cx, cy, rx * 1.02, ry * 1.02)
        capsid = hexagon(cx, cy, 8.2 * (rx + ry) / 20, angle + math.pi / 6)
        for x, y in envelope - capsid:
            img.putpixel((x, y), (214, 214, 244, 255) if (x + y) % 2 == 0 else (186, 186, 228, 255))
        shade_ellipse(img, capsid, cx, cy, rx * 0.85, ry * 0.85, p.bands)
        outline(img, envelope)
        for x, y in capsid:
            if any((x + dx, y + dy) not in capsid for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                img.putpixel((x, y), p.bands[0])
        draw_face_large(img, cx, cy, expr, look, "sly")
        return img


class Hpv(EnemyArt):
    """HPV: a slate blue faceted shell like a small cut gem. Armored."""

    id = "hpv"
    piece_count = 10
    walk_fps = 8
    action_fps = 10
    palette = Palette(
        bands=((58, 78, 112, 255), (84, 110, 156, 255), (120, 150, 200, 255), (186, 210, 240, 255)),
        knob_lit=(214, 230, 250, 255),
        knob_shade=(100, 130, 180, 255),
        spray=(206, 224, 246, 255),
    )

    def walk_angle(self, i):
        return i * (math.pi / 5) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        corners = [(cx + rx * 1.02 * math.cos(angle + i * math.pi / 5 + math.pi / 10),
                    cy + ry * 1.02 * math.sin(angle + i * math.pi / 5 + math.pi / 10)) for i in range(10)]
        body = set()
        for x in range(SIZE):
            for y in range(SIZE):
                if (x + 0.5 - cx) ** 2 / (rx * 1.02) ** 2 + (y + 0.5 - cy) ** 2 / (ry * 1.02) ** 2 <= 1.0:
                    body.add((x, y))
        shade_ellipse(img, body, cx, cy, rx, ry, p.bands)
        for i in range(0, 10, 2):
            x1, y1 = corners[i]
            for x, y in line_pixels(cx, cy, x1, y1, 0.5):
                if (x, y) in body and math.hypot(x - cx, y - cy) > 7.5:
                    img.putpixel((x, y), p.bands[0])
        for x, y in disc(cx, cy, 8.2):
            if (x, y) in body and 7.4 < math.hypot(x + 0.5 - cx, y + 0.5 - cy) < 8.2:
                img.putpixel((x, y), p.bands[1])
        outline(img, body)
        draw_face_large(img, cx, cy, expr, look, "grumpy")
        return img


class EColi(EnemyArt):
    """E. coli: a rosy rod with a few wavy tails. The plain bacterium."""

    id = "e-coli"
    piece_count = 10
    walk_fps = 9
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((170, 84, 96, 255), (212, 116, 120, 255), (244, 156, 150, 255), (255, 214, 200, 255)),
        knob_lit=(255, 224, 208, 255),
        knob_shade=(206, 118, 124, 255),
        spray=(255, 224, 214, 255),
    )

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        half, radius = 4.4 * rx / 10, 6.8 * ry / 10
        body = capsule(cx + 4, cy, half, radius)
        tails = set()
        for k in range(3):
            base_y = cy - 3 + k * 3
            for t in range(6):
                tails |= disc(cx + 4 - half - radius - 0.5 - t * 0.9, base_y + 1.0 * math.sin(angle + t * 0.9 + k), 0.7)
        shade_ellipse(img, body, cx + 4, cy, half + radius, radius, p.bands)
        for x, y in tails - body:
            img.putpixel((x, y), p.knob_shade)
        outline(img, body | tails)
        draw_small_face(img, round(cx + 5), round(cy), expr, look)
        return img


class StaphylococcusAureus(EnemyArt):
    """Staph: a golden cluster of cocci like a bunch of grapes. Learns to resist."""

    id = "staphylococcus-aureus"
    piece_count = 10
    walk_fps = 8
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((170, 120, 24, 255), (214, 160, 40, 255), (246, 200, 70, 255), (255, 240, 150, 255)),
        knob_lit=(255, 244, 170, 255),
        knob_shade=(206, 150, 40, 255),
        spray=(255, 240, 170, 255),
    )
    # (dx, dy, radius), back to front
    grapes = ((-7, -5, 4.6), (7, -5, 4.6), (-8, 4, 4.8), (8, 4, 4.8), (0, 8, 4.8), (0, -4, 5.4), (0, 1, 6.6))

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        sx, sy = rx / 10, ry / 10
        drawn = set()
        for n, (dx, dy, r) in enumerate(self.grapes):
            wiggle = 0.7 * math.sin(angle + n * 1.1)
            ccx, ccy = cx + dx * sx, cy + dy * sy + wiggle
            mask = ellipse(ccx, ccy, r * sx, r * sy)
            shade_ellipse(img, mask, ccx, ccy, r * sx, r * sy, p.bands)
            for x, y in mask:
                if any((x + ox, y + oy) not in mask and (x + ox, y + oy) in drawn
                       for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    img.putpixel((x, y), OUTLINE)
            drawn |= mask
        outline(img, drawn)
        draw_small_face(img, round(cx), round(cy + 1), expr, look)
        return img


class HelicobacterPylori(EnemyArt):
    """H. pylori: a teal corkscrew with a tuft of tails. Slowing attacks do nothing to it."""

    id = "helicobacter-pylori"
    piece_count = 10
    walk_fps = 9
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((30, 110, 112, 255), (46, 154, 150, 255), (84, 206, 190, 255), (170, 245, 228, 255)),
        knob_lit=(190, 250, 236, 255),
        knob_shade=(60, 160, 154, 255),
        spray=(200, 250, 240, 255),
    )

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        body = set()
        for k in range(34):
            t = k / 33
            x = cx - 11 * rx / 10 + 22 * rx / 10 * t
            y = cy + 4.2 * ry / 10 * math.sin(t * 2 * math.pi * 1.1 + angle)
            body |= disc(x, y, 4.3 * (ry / 10))
        shade_ellipse(img, body, cx, cy, 14, 8, p.bands)
        tails = set()
        for k in range(3):
            for t in range(6):
                tails |= disc(cx + 12 * rx / 10 + t * 0.9, cy - 2 + k * 2 + 0.9 * math.sin(angle + t + k), 0.6)
        for x, y in tails - body:
            img.putpixel((x, y), p.knob_shade)
        outline(img, body | tails)
        draw_mini_face(img, round(cx - 1), round(cy + 4.2 * ry / 10 * math.sin(2 * math.pi * 0.55 * 1.1 + angle)), expr)
        return img


class ClostridioidesDifficile(EnemyArt):
    """C. difficile: an olive rod with a pale spore at one end. It comes back once after dying."""

    id = "clostridioides-difficile"
    piece_count = 10
    walk_fps = 9
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((86, 90, 36, 255), (124, 130, 52, 255), (166, 174, 78, 255), (214, 222, 140, 255)),
        knob_lit=(232, 238, 170, 255),
        knob_shade=(130, 138, 60, 255),
        spray=(226, 232, 170, 255),
    )

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        half, radius = 5.5 * rx / 10, 6.4 * ry / 10
        body = capsule(cx - 2, cy, half, radius)
        spore_c = (cx + half + radius - 2.0, cy + 0.5)
        spore = ellipse(spore_c[0], spore_c[1], 4.6 * rx / 10, 4.6 * ry / 10)
        shade_ellipse(img, body, cx - 2, cy, half + radius, radius, p.bands)
        for x, y in spore:
            lit = (x - spore_c[0]) + (y - spore_c[1]) < -1
            img.putpixel((x, y), (255, 246, 210, 255) if lit else (226, 208, 150, 255))
        outline(img, body | spore)
        draw_small_face(img, round(cx - 3), round(cy), expr, look)
        return img


class Hiv(EnemyArt):
    """HIV: a big dark red ball covered in tiny studs, with a golden crown of larger ones. Boss."""

    id = "hiv"
    piece_count = 18
    walk_fps = 7
    action_fps = 9
    palette = Palette(
        bands=((92, 20, 44, 255), (136, 32, 62, 255), (186, 52, 84, 255), (238, 110, 126, 255)),
        knob_lit=(255, 214, 110, 255),
        knob_shade=(206, 150, 50, 255),
        spray=(255, 226, 150, 255),
    )
    stud_count = 20

    def walk_angle(self, i):
        return i * (2 * math.pi / self.stud_count) / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        brx, bry = rx * 1.12, ry * 1.12
        body = ellipse(cx, cy, brx, bry)
        studs = set()
        for i in range(self.stud_count):
            a = angle + i * 2 * math.pi / self.stud_count
            big = i % 2 == 0
            studs |= disc(cx + (brx + 0.5) * math.cos(a), cy + (bry + 0.5) * math.sin(a), 1.6 if big else 1.0)
        shade_ellipse(img, body, cx, cy, brx, bry, p.bands)
        for x, y in studs - body:
            img.putpixel((x, y), p.knob_lit if (x - cx) + (y - cy) < -3 else p.knob_shade)
        for x, y in ellipse(cx, cy, brx * 0.45, bry * 0.45):
            if (x + y) % 2 == 0:
                img.putpixel((x, y), p.bands[1])
        outline(img, body | studs)
        draw_face_large(img, cx, cy, expr, look, "grumpy")
        return img


class MycobacteriumTuberculosis(EnemyArt):
    """Tuberculosis: a thick olive-grey rod in a plated waxy coat. Boss."""

    id = "mycobacterium-tuberculosis"
    piece_count = 16
    walk_fps = 6
    action_fps = 8
    immune_to_antiviral = True
    palette = Palette(
        bands=((70, 78, 66, 255), (104, 114, 94, 255), (146, 158, 128, 255), (200, 212, 176, 255)),
        knob_lit=(214, 224, 188, 255),
        knob_shade=(110, 122, 98, 255),
        spray=(216, 226, 190, 255),
    )

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        half, radius = 5.0 * rx / 10, 8.6 * ry / 10
        body = capsule(cx, cy, half, radius, tilt=0.0)
        shade_ellipse(img, body, cx, cy, half + radius, radius, p.bands)
        plates = set()
        for k in range(-2, 3):
            px = cx + k * 4.6
            for x, y in line_pixels(px, cy - radius + 1, px - 1.5, cy + radius - 1, 0.45):
                if (x, y) in body:
                    plates.add((x, y))
        for x, y in plates:
            img.putpixel((x, y), p.bands[0])
        for k in range(6):
            wob = 0.6 * math.sin(angle + k)
            x = cx - 12 + k * 4.8
            for dx, dy in ((0, -radius - 0.4 + wob), (0, radius + 0.4 - wob)):
                for px_, py_ in disc(x, cy + dy, 1.2):
                    if (px_, py_) not in body:
                        img.putpixel((px_, py_), p.knob_lit if dy < 0 else p.knob_shade)
        outline_pixels = body | {(x, y) for x in range(SIZE) for y in range(SIZE) if img.getpixel((x, y))[3] > 0}
        outline(img, outline_pixels)
        draw_face_large(img, cx, cy, expr, look, "grumpy")
        return img


class NeisseriaMeningitidis(EnemyArt):
    """Meningococcus: two magenta beans pressed together, each with its own face. Boss that splits in two."""

    id = "neisseria-meningitidis"
    piece_count = 16
    walk_fps = 8
    action_fps = 10
    immune_to_antiviral = True
    palette = Palette(
        bands=((140, 30, 96, 255), (190, 48, 132, 255), (232, 84, 170, 255), (255, 160, 214, 255)),
        knob_lit=(255, 190, 228, 255),
        knob_shade=(200, 60, 140, 255),
        spray=(255, 200, 232, 255),
    )

    def walk_angle(self, i):
        return i * 2 * math.pi / 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        sx, sy = rx / 10, ry / 10
        centers = [(cx - 6.4 * sx, cy + 0.8 * math.sin(angle)), (cx + 6.4 * sx, cy - 0.8 * math.sin(angle))]
        drawn = set()
        masks = []
        for ccx, ccy in centers:
            mask = ellipse(ccx, ccy, 7.6 * sx, 9.4 * sy)
            masks.append(mask)
            shade_ellipse(img, mask, ccx, ccy, 7.6 * sx, 9.4 * sy, p.bands)
            for x, y in mask:
                if any((x + dx, y + dy) not in mask and (x + dx, y + dy) in drawn
                       for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    img.putpixel((x, y), OUTLINE)
            drawn |= mask
        for ccx, ccy in centers:  # the groove where the two cells meet
            for dy in range(-6, 7, 2):
                put(img, round(cx), round(cy + dy), p.bands[0])
        outline(img, drawn)
        for ccx, ccy in centers:
            draw_small_face(img, round(ccx), round(ccy), expr, look)
        return img


class StreptococcusSegment(StreptococcusPyogenes):
    """One coccus of the strep chain, used when the chain splits into separate enemies."""

    id = "streptococcus-pyogenes-segment"
    piece_count = 8

    def render(self, cx=CX, cy=CY, rx=10.0, ry=10.0, angle=0.0, expr="normal", look=(2, 2)):
        p = self.palette
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        mask = ellipse(cx, cy + 0.8 * math.sin(angle), rx * 0.9, ry * 0.9)
        shade_ellipse(img, mask, cx, cy, rx * 0.9, ry * 0.9, p.bands)
        outline(img, mask)
        draw_small_face(img, round(cx), round(cy), expr, look)
        return img

    def burst(self, step):
        return EnemyArt.burst(self, step)


ENEMIES = [Rhinovirus(), Influenza(), StreptococcusPyogenes(), SarsCov2(), HerpesSimplex(), Hpv(), EColi(),
           StaphylococcusAureus(), HelicobacterPylori(), ClostridioidesDifficile(), Hiv(),
           MycobacteriumTuberculosis(), NeisseriaMeningitidis(), StreptococcusSegment()]
