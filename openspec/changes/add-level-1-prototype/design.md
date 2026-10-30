## Context

This change builds the first playable level on top of two pending changes: `add-enemy-roster-and-economy` (enemy data, amino acids) and `add-tower-roster-and-damage` (tower data, damage rules). See `proposal.md` for the motivation and the three specs in `specs/` for the requirements. The visual reference for the map is `design/fase-1-nariz-garganta.html` (a 360×640 drawing, which maps to the 720×1280 project size at 2×). In the game the map is taller (360×820) and scrolls, so the path is longer than in the mockup, which shows the earlier single-screen layout. Enemy sprites and animations already exist in `assets/enemies/`.

## Goals / Non-Goals

**Goals:**
- A complete, testable loop on one level: build, survive timed waves, win or lose.
- A HUD that works with a thumb on a portrait phone.
- Timing, layout and numbers in data, so they can be tuned without code edits.

**Non-Goals:**
- Upgrades, the other seven towers, other levels, sound, menus outside the level.
- Android export and device tuning (a later change).
- Final balance: wave times and counts are provisional.

## Decisions

- **The map is rendered in a low-resolution `SubViewport` (360×640) shown 2× with Nearest filtering; the HUD is a `CanvasLayer` at full resolution.** Alternative: draw the HUD inside the low-resolution viewport. Small pixel text would be hard to read on a phone, so the HUD uses a pixel font at an integer scale with pixel-art panels. A `SubViewportContainer` forwards taps to the map with the right coordinates.
- **Speed and pause use `Engine.time_scale` and `get_tree().paused`.** Alternative: pass a speed factor to every system. The engine setting scales movement, timers and physics together, which is exactly the "everything runs at the same speed" rule. HUD nodes that must keep working while paused use the "always" process mode, and HUD tweens ignore the time scale so menus do not speed up at 2×.
- **A single `WaveScheduler` node owns the level clock and every wave's state.** A wave is `waiting`, `spawning` or `done`. "Call next wave" starts the first `waiting` wave and does not touch the others. Alternative: shift later waves earlier when one is called. Keeping absolute times makes the schedule easy to read and test.
- **Wave data as resources: `LevelData` (path, slots, resources, waves) and `WaveData` (start time, enemy entries, spawn interval).** The map's path and slot positions are stored as data, copied from the mockup.
- **Build flow as a popup menu anchored to the tapped slot, clamped to the screen, with a full-screen transparent catcher to close it.** Alternative: a bottom card bar (tap card, then slot). Slot-first needs fewer taps and gives larger targets, as chosen by the designer.
- **The map is scrolled with a `Camera2D` in the low-resolution viewport, driven by drag input in the HUD.** The map is 360×820 units against about 484 visible between the HUD bars, so the scroll range runs from showing the very top under the top bar to showing the very bottom above the bottom bar. Alternative: move the map node itself; a camera keeps tap conversion in one place (`screen_to_world` and `world_to_screen`). A press only becomes a drag after 14 px of movement, so taps stay reliable. A thin indicator with enemy marks stops enemies from getting lost off screen.
- **Taps are hit-tested by distance in the level, not with `Area2D` nodes.** A tap within 24 map units (48 dp at the 720 px reference width) of a slot or an enemy selects it, so the tap area is always at least the 48 dp minimum and the logic is testable without a window.
- **Victory and defeat are checked by the scheduler and the body health holder, never by the HUD.** The HUD only reacts to their signals.

Sanity check of the provisional times, using the data speeds (Rhinovirus 45, Influenza 79 and *S. pyogenes* 40 map units per second on a 1,700 unit path, so about 38 s, 22 s and 43 s): wave 1 finishes around 53 s, so wave 2 at 50 s starts while the last rhinoviruses are still walking; wave 2 finishes around 100 s, so wave 3 at 150 s leaves about a minute to save amino acids or call the wave early.

## Risks / Trade-offs

- [Provisional wave times may feel too slow or too fast] → They are data, tuned in playtests; the call button covers the "too slow" case.
- [`Engine.time_scale` also speeds up tweens, audio and effects] → HUD tweens ignore the time scale; gameplay effects are meant to speed up with the game.
- [Tapping moving enemies is hard on a phone] → Enlarged tap areas; the enemy card is a convenience, never required to play.
- [Popup menu near a screen edge could be clipped] → The menu clamps itself inside the safe area.

## Open Questions

- Whether calling a wave early should give a bonus (for example extra amino acids). It does not change the specs, data or tasks; it can be added after playtests.
