"""Generates the Apolo Software logo: a pixel-art sun with rays (assets/ui/apolo_logo.png, 64 x 64 drawn, saved at 4x).

Usage: python3 -I tools/generate_logo.py
"""
import math
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "ui", "apolo_logo.png")
GOLD = (244, 211, 94, 255)
ORANGE = (240, 140, 50, 255)
DARK = (150, 70, 30, 255)
LIGHT = (255, 243, 176, 255)


def main():
    size = 64
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    centre = (size - 1) / 2
    for i in range(16):
        angle = math.tau * i / 16
        long_ray = i % 2 == 0
        inner, outer = 20, 31 if long_ray else 26
        half = 0.13 if long_ray else 0.09
        points = [
            (centre + math.cos(angle - half) * inner, centre + math.sin(angle - half) * inner),
            (centre + math.cos(angle) * outer, centre + math.sin(angle) * outer),
            (centre + math.cos(angle + half) * inner, centre + math.sin(angle + half) * inner),
        ]
        draw.polygon(points, fill=ORANGE if long_ray else GOLD)
    draw.ellipse((centre - 18, centre - 18, centre + 18, centre + 18), fill=DARK)
    draw.ellipse((centre - 16, centre - 16, centre + 16, centre + 16), fill=GOLD)
    draw.ellipse((centre - 11, centre - 14, centre + 5, centre + 2), fill=LIGHT)
    # a letter A cut into the disc
    draw.polygon([(centre - 9, centre + 11), (centre, centre - 10), (centre + 9, centre + 11), (centre + 5, centre + 11),
                  (centre, centre - 1), (centre - 5, centre + 11)], fill=DARK)
    draw.rectangle((centre - 4, centre + 4, centre + 4, centre + 6), fill=DARK)
    image = image.resize((size * 4, size * 4), Image.NEAREST)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    image.save(OUT)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
