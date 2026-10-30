## Decisions

- **One switch for every debug aid.** `Session.debug_mode` reads `all_levels_open`, so the secret code is the single place where debug is turned on and future aids can use the same flag.
- **The readout updates four times a second** (`Engine.get_frames_per_second()`), so the number is readable. It ignores the mouse, is drawn with an outline and is right-aligned at the top right (below the top bar in a level, because the buttons fill the bar).
