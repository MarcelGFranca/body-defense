## Why

Enemies, economy, towers and damage are specified in two other changes, but there is still no playable level. A first prototype of level 1 (nose and throat) lets us test the whole loop on a phone: place towers, survive timed waves, and read the HUD. The decisions below were made together with the designer: the player builds by tapping a slot and then choosing a tower, waves start at fixed times with a button to call later waves early, and a 2× speed is part of the prototype from day one.

## What Changes

- Define level 1 as a portrait map with an entrance, a winding path, 6 tower slots and an exit toward the lungs, using three enemies (Rhinovirus, Influenza, *S. pyogenes*) and three towers (Macrophage, Mucus Cell, Interferon).
- Define a wave system driven by a level clock: each wave has a start time in seconds, an enemy list and a spawn interval. Level 1 has 3 waves starting at 5 s, 50 s and 150 s (provisional, to be tuned).
- Add a button that calls the next wave immediately, without moving the other waves' start times.
- Define win and lose conditions: the level is won when every wave has started and no enemy is left, and lost when the body's health reaches zero.
- Make the map larger than the screen: the path runs past the edges and the player drags to scroll, with a thin scroll indicator that also shows where the enemies are.
- Name the level "Garganta" and show the level name at the top of the HUD.
- Define the HUD for portrait phones: a top bar, the map, and a bottom area with wave info, the tap-slot-then-choose build flow, a tower card with sell, enemy info card, pause, and a 1× / 2× speed toggle.
- Out of scope: upgrades, the other seven towers, levels 2 to 8, sound, menus outside the level, Android export, and final balance.

## Capabilities

### New Capabilities
- `level-1-prototype`: the layout, slots, available enemies and towers, starting resources and wave list of level 1.
- `wave-system`: timed waves, calling the next wave, and the win and lose conditions.
- `hud`: the heads-up display, the build and sell flow, the enemy info card, pause and game speed.

### Modified Capabilities
<!-- None: the dependent specs are still pending in other changes. -->

## Impact

- New Godot scenes: the level, the HUD, and the wave scheduler, plus wave data files.
- Depends on `add-enemy-roster-and-economy` (enemies, amino acids) and `add-tower-roster-and-damage` (towers, damage).
- Uses the enemy sprites and animations already generated in `assets/enemies/`. Tower art and the HUD art are still needed.
- The earlier layout mockup `design/fase-1-nariz-garganta.html` is the visual reference for the map.
- No new external dependencies.
