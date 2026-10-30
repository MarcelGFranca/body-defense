## Plays sound effects and music. Registered as the `GameAudio` autoload.
extends Node

const VOICES := 8
## The same sound cannot restart within this time.
const MIN_REPEAT_MSEC := 60
const FADE_OUT_SECONDS := 1.5
const CONFIG_PATH := "res://data/audio.tres"

var config: AudioConfig
var current_music := ""
var music_fading := false
## When true, every sound that really starts is added to `play_log` (used by tests).
var record := false
var play_log: Array = []

var _voices: Array[AudioStreamPlayer] = []
var _last_start: Dictionary = {}
var _music: AudioStreamPlayer
var _fade: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	config = load(CONFIG_PATH) as AudioConfig
	if config == null:
		config = AudioConfig.new()
	for i in VOICES:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)
	_music = AudioStreamPlayer.new()
	add_child(_music)


## Plays a sound effect. Returns false when it was skipped (empty path, repeated too soon, no free voice).
func play_sfx(path: String) -> bool:
	if path == "":
		return false
	var now := Time.get_ticks_msec()
	if now - int(_last_start.get(path, -1000000)) < MIN_REPEAT_MSEC:
		return false
	var voice := _free_voice()
	if voice == null:
		return false
	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("missing sound: %s" % path)
		return false
	_last_start[path] = now
	voice.stream = stream
	voice.volume_db = config.sfx_volume_db
	voice.play()
	if record:
		play_log.append(path)
	return true


func voices_in_use() -> int:
	var count := 0
	for voice in _voices:
		if voice.playing:
			count += 1
	return count


## Starts a music loop. It keeps playing, without a gap, until `stop_music` is called.
func play_music(path: String) -> void:
	if path == "" or (current_music == path and _music.playing and not music_fading):
		return
	var source := load(path) as AudioStreamWAV
	if source == null:
		push_warning("missing music: %s" % path)
		return
	var stream := source.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / (4 if stream.stereo else 2)
	if _fade != null:
		_fade.kill()
	music_fading = false
	_music.stream = stream
	_music.volume_db = config.music_volume_db
	_music.play()
	current_music = path


func stop_music(fade_seconds: float = FADE_OUT_SECONDS) -> void:
	if not _music.playing:
		current_music = ""
		return
	if fade_seconds <= 0.0:
		_finish_music()
		return
	if music_fading:
		return
	music_fading = true
	_fade = create_tween().set_ignore_time_scale(true)
	_fade.tween_property(_music, "volume_db", -60.0, fade_seconds)
	_fade.tween_callback(_finish_music)


func is_music_playing() -> bool:
	return _music.playing


func music_stream() -> AudioStreamWAV:
	return _music.stream as AudioStreamWAV


func music_volume_db() -> float:
	return _music.volume_db


## Clears the log and the repeat timers and silences everything (used by tests).
func reset() -> void:
	play_log.clear()
	_last_start.clear()
	for voice in _voices:
		voice.stop()
	_finish_music()


func _finish_music() -> void:
	if _fade != null:
		_fade.kill()
	_music.stop()
	music_fading = false
	current_music = ""


func _free_voice() -> AudioStreamPlayer:
	for voice in _voices:
		if not voice.playing:
			return voice
	return null
