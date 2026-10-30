"""Generates the prototype tower sprites: the HUD icon and the idle and attack animations.

Usage: python3 -I tools/generate_tower_sprites.py
Output: assets/towers/<id>.png and assets/towers/<id>/animations/
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image

from generate_enemy_sprites import save_gif, save_overview
from pixel_art import SIZE
from tower_art import TOWERS

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "towers")


def generate(art):
    anim_dir = os.path.join(ROOT, art.id, "animations")
    os.makedirs(anim_dir, exist_ok=True)
    animations = {
        "idle": (art.idle_frames(), art.idle_fps, True),
        "attack": (art.attack_frames(), art.attack_fps, False),
    }
    animations["idle"][0][0].save(os.path.join(ROOT, f"{art.id}.png"))
    meta = {"frame_size": [SIZE, SIZE], "animations": {}}
    rows = []
    for name, (frames, fps, loop) in animations.items():
        assert len(frames) == 8, f"{art.id} {name}"
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
    for art in TOWERS:
        generate(art)
        print("generated", art.id)


if __name__ == "__main__":
    main()
