"""Generates the 16-bit sprites and animations of every prototype enemy.

Usage: python3 -I tools/generate_enemy_sprites.py
Output: assets/enemies/<id>/ (sprite, and animations/ with sheets, GIFs, overview and JSON)
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image, ImageDraw

from enemies import ENEMIES
from pixel_art import BG, SIZE, build_animations

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "enemies")


def save_gif(frames, path, fps, scale=8):
    out = []
    for frame in frames:
        bg = Image.new("RGBA", (SIZE, SIZE), BG)
        bg.alpha_composite(frame)
        out.append(bg.resize((SIZE * scale, SIZE * scale), Image.NEAREST).convert("P", palette=Image.ADAPTIVE))
    out[0].save(path, save_all=True, append_images=out[1:], duration=int(1000 / fps), loop=0)


def save_overview(rows, path, scale=4, label_width=130):
    overview = Image.new("RGBA", (label_width + 8 * SIZE * scale, len(rows) * SIZE * scale), BG)
    draw = ImageDraw.Draw(overview)
    for r, (name, frames) in enumerate(rows):
        draw.text((6, r * SIZE * scale + SIZE * scale // 2 - 5), name, fill=(255, 179, 199, 255))
        for c, frame in enumerate(frames):
            overview.alpha_composite(frame.resize((SIZE * scale, SIZE * scale), Image.NEAREST),
                                     (label_width + c * SIZE * scale, r * SIZE * scale))
    overview.save(path)


def generate(art):
    base = os.path.join(ROOT, art.id)
    anim_dir = os.path.join(base, "animations")
    os.makedirs(anim_dir, exist_ok=True)
    art.render().save(os.path.join(base, f"{art.id}_sprite.png"))

    meta = {"frame_size": [SIZE, SIZE], "animations": {}}
    rows = []
    for name, (frames, fps, loop) in build_animations(art).items():
        sheet = Image.new("RGBA", (SIZE * len(frames), SIZE), (0, 0, 0, 0))
        for i, frame in enumerate(frames):
            sheet.paste(frame, (i * SIZE, 0))
        sheet.save(os.path.join(anim_dir, f"{art.id}_{name}_sheet.png"))
        save_gif(frames, os.path.join(anim_dir, f"{art.id}_{name}.gif"), fps)
        meta["animations"][name] = {"frames": len(frames), "fps": fps, "loop": loop}
        rows.append((name, frames))
    save_overview(rows, os.path.join(anim_dir, f"{art.id}_overview_x4.png"))
    with open(os.path.join(anim_dir, f"{art.id}_animations.json"), "w", encoding="utf-8") as fh:
        json.dump(meta, fh, indent=2)


def main():
    for art in ENEMIES:
        generate(art)
        print("generated", art.id)


if __name__ == "__main__":
    main()
