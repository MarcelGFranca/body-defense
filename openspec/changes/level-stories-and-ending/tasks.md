## 1. Implementation

- [x] 1.1 game/intro_stories.gd: the scenes of levels 2 to 10 (dusty book, night cough, 5 second rule, dirty water, raw burger, skate fall, raw oysters, mosquito bite, swollen glands) and of the ending (the last battle, the morning after)
- [x] 1.2 game/intro.gd: STORIES table (cue times, zoom point, organ, invaders, boss, title, sound), the organ drawings (trachea, lungs, esophagus, stomach, intestines, blood, liver, spleen, lymph nodes) and the shared helpers
- [x] 1.3 Session.start_level plays the story of the level it starts (the bots skip it)
- [x] 1.4 Session.play_ending() plays story 11 and returns to the menu
- [x] 1.5 The HUD plays the ending when the last level is won
- [x] 1.6 tools/generate_intro_sound.py writes intro_level1.wav, intro_2..10.wav and intro_end.wav
- [x] 1.7 Every story has a SKIP button
- [x] 1.8 tests draw every story from start to end
- [x] 1.9 Add tests, update docs, run the test runner (0 failures)
