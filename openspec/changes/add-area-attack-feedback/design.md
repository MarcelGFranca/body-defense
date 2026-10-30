## Decisions

- **Two layers of feedback.** The 32 px sprite is small on a phone, so the sprite animation alone is easy to miss. The expanding ring uses the whole range, so the player also sees where the hit lands.
- **Ring colour by damage type** (`PULSE_COLORS` in `tower.gd`), so it needs no per-tower data.
- **Only the lysozyme sheets are regenerated**; `generate_tower_sprites.py` writes every tower, and the diff must show no other tower changed.
