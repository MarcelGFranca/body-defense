## Why

Level music was a 50 s loop and the game ended in silence. The music must last at least 3 minutes and winning or losing needs its own tune.

## What Changes

- Every level track is now 185 s (the A B A form repeats 4 times with new melodies
- tempo follows the length)
- New victory and defeat tunes (about 7 s and 8 s) that play once, set in data/audio.tres
- GameAudio.play_jingle plays a tune without looping
- Fix the loop end of imported (compressed) music: it is now taken from the length in seconds instead of the compressed byte size

## Capabilities

### New Capabilities
- `audio`

## Impact

- tools/generate_audio.py, scripts/game_audio.gd, scripts/level.gd, scripts/data/audio_config.gd, assets/audio/music, docs, tests
