## Decisions

- **The charge animation is stretched to the interval.** After the attack animation (0.67 s) the charge plays with `speed_scale = charge_seconds / (interval - attack_seconds)`, so it ends exactly when the tower can fire again, whatever the interval in the data. At 2 s: scale 0.75.
- **"Charged" is the last frame.** The animation does not loop, so the tower waits fully charged when no enemy is in range. A new tower starts in idle, which also reads as ready.
- **The beam is a node, not part of the sprite.** `TowerBeam` draws above the enemies (`z_index = 2`) and is data-driven by `beam_width`: a width of 0 keeps the thin flash line the macrophage uses.
- **Damage is applied at the moment of the shot**; the beam (0.28 s) and the explosion (0.5 s) are visuals only, so balance is untouched.
- **Charge art lives in the generator** (`TLymphocyte.charge_frames`); `generate_tower_sprites.py` adds a `charge` animation to any art class that has `charge_frames`.
