## 1. Sound files

- [x] 1.1 Create `tools/generate_audio.py` that writes the hit, attack and death sounds of all 13 enemies, the attack sounds of all 10 towers, the blocked sound and the level 1 music into `assets/audio/`, and verify that running it produces the expected number of non-empty WAV files
- [x] 1.2 Check the generated files: bosses last longer than regular enemies, the music loop is about 16 s, and no file clips (peak below full scale), with a script that measures them (done with `tools/generate_audio.py --check`)

## 2. Data

- [x] 2.1 Add sound fields to `EnemyData` (hit, attack, death), `TowerData` (attack) and `LevelData` (music), add the `AudioConfig` resource with the effect and music volumes, fill them in `tools/generate_data.gd`, and verify that regenerating the data sets every path
- [x] 2.2 Make the validator check that every sound and music path is set and that the file exists, and verify with a test on a modified copy that a missing sound is reported with the enemy or tower name

## 3. Playing sounds

- [x] 3.1 Create the `GameAudio` autoload with 8 effect voices, the 60 ms rule per sound and the music player, and verify with tests that fifty requests for the same sound in one frame start only once and that no more than 8 sounds play at once
- [x] 3.2 Play the enemy sounds (hit when damaged, blocked sound when immune, attack at the exit, death on dying), and verify with tests that each situation plays the right file
- [x] 3.3 Play each tower's attack sound when it attacks (Macrophage hit, Interferon pulse, Mucus Cell throw), and verify with tests that each plays its own file
- [x] 3.4 Start the level music with the level, loop it, fade it out on victory or defeat and keep it playing while paused, and verify with tests for each of these and that the music volume comes from the audio data

## 4. Check

- [ ] 4.1 Run level 1 in a window with the bot and verify that sounds and music play without errors, then run `openspec validate add-game-audio` and verify that the change is valid (the bot played the whole level headless with silent dummy audio and no errors or warnings, and `openspec validate` passes; nobody has listened to it on a device yet, so this stays open)
