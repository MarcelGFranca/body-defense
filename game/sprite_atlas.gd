## Builds `SpriteFrames` from the packed sprite atlas (`tools/pack_sprites.py` makes `assets/sprites/atlas.png`).
## Every enemy and tower animation lives in one texture, so all the sprites of a level are drawn in one batch.
class_name SpriteAtlas
extends RefCounted

const TEXTURE_PATH := "res://assets/sprites/atlas.png"
const INDEX_PATH := "res://assets/sprites/atlas.json"

static var _texture: Texture2D
static var _index: Dictionary = {}


## The frames of `kind` ("enemies" or "towers") and folder `name`, or null when that folder has no animations.
static func frames_for(kind: String, name: String) -> SpriteFrames:
	_load()
	var prefix := "%s/%s/" % [kind, name]
	var frames: SpriteFrames = null
	var frame_size := int(_index["frame"])
	for key: String in _index["sheets"]:
		if not key.begins_with(prefix):
			continue
		if frames == null:
			frames = SpriteFrames.new()
			frames.remove_animation("default")
		var sheet: Dictionary = _index["sheets"][key]
		var anim := key.trim_prefix(prefix)
		frames.add_animation(anim)
		frames.set_animation_speed(anim, float(sheet["fps"]))
		frames.set_animation_loop(anim, bool(sheet["loop"]))
		for i in int(sheet["frames"]):
			var frame := AtlasTexture.new()
			frame.atlas = _texture
			frame.region = Rect2(int(sheet["x"]) + i * frame_size, int(sheet["y"]), frame_size, frame_size)
			frames.add_frame(anim, frame)
	return frames


static func _load() -> void:
	if _texture != null:
		return
	_texture = load(TEXTURE_PATH)
	_index = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
