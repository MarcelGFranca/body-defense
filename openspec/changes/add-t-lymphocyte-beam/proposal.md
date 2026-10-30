## Why

The T lymphocyte hits like every other single-target tower: a thin line and a short animation. The designer asked that its animation be a charge that lasts until it can shoot, and that its shot be a much thicker beam with an explosion where it lands.

## What Changes

- A new `charge` animation (8 frames: sparks gather in the nucleus, which glows white) that fills the rest of the shot interval after the attack animation, and stays fully charged until the next shot.
- The attack animation becomes a recoil with a flash at the receptors; the beam is no longer painted in the sprite.
- A thick beam (`beam_width` 14 map units, about four times the thin line) is drawn from the tower to the target, with an explosion at the target: flash, ring and sparks.
- The ability text says it charges and fires a thick beam.
- Damage, interval and range are unchanged.

## Capabilities

### Modified Capabilities
- `tower-feedback`: charging towers and beams.

## Impact

- New `game/tower_beam.gd`, new field `TowerData.beam_width` (generated data), `game/tower.gd`, sprite generator (`charge` animation) and the T lymphocyte sheets, tests.
- New screenshot tool `tools/tlymphocyte_screenshots`.
