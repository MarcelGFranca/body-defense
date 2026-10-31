## Why

Each level should tell how the germs got into the body, and beating the last boss deserves an ending. The designer approved ten HTML mockups (levels 2 to 10 and the ending).

## What Changes

- game/intro_stories.gd: the scenes of levels 2 to 10 (dusty book, night cough, 5 second rule, dirty water, raw burger, skate fall, raw oysters, mosquito bite, swollen glands) and of the ending (the last battle, the morning after)
- game/intro.gd: STORIES table (cue times, zoom point, organ, invaders, boss, title, sound), the organ drawings (trachea, lungs, esophagus, stomach, intestines, blood, liver, spleen, lymph nodes) and the shared helpers
- Session.start_level plays the story of the level it starts (the bots skip it)
- Session.play_ending() plays story 11 and returns to the menu
- The HUD plays the ending when the last level is won
- tools/generate_intro_sound.py writes intro_level1.wav, intro_2..10.wav and intro_end.wav
- Every story has a SKIP button
- tests draw every story from start to end

## Capabilities

### New Capabilities
- `stories`

## Impact

- game/intro.gd, game/intro_stories.gd, game/session.gd, game/hud.gd, tools/generate_intro_sound.py, tools/intro_screenshots.gd, assets/audio/common/intro_*.wav, tests, docs
