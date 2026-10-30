## Context

Godot has no long-press event. Android's `onLongClick()` maps to a `Timer` started on press (`button_down` on cards, a mouse press on the map).

## Decisions

- **`HOLD_SECONDS = 0.3`.** Shorter than Android's default (about 0.5 s) so it feels immediate; a normal tap lasts 0.1 to 0.2 s. Tested on the emulator with `adb shell input swipe x y x y 2500`.
- **A held press never acts on release.** `_card_held` (cards) and `_map_held` (map) are cleared only by the next press, so the order of `pressed` and `button_up` does not matter.
- **Effectiveness comes from the damage table and armor of the enemies in the level's waves**, not from fixed text, so it stays correct when balance changes. Good: factor above 1, or an armored enemy against immunological damage (it ignores armor). Weak: factor below 0.8. Useless: factor 0.
- **The panel ignores the mouse** so the release reaches the card that was held.
