## Builds `SpriteFrames` for a tower from its generated sprite sheets, or null when it has none.
class_name TowerSprites
extends RefCounted

const FRAME_SIZE := 32

static var _cache: Dictionary = {}


static func frames_for(tower_id: String) -> SpriteFrames:
	if _cache.has(tower_id):
		return _cache[tower_id]
	_cache[tower_id] = _load(tower_id)
	return _cache[tower_id]


static func _load(tower_id: String) -> SpriteFrames:
	var dir := "res://assets/towers/%s/animations" % tower_id
	var meta_path := "%s/%s_animations.json" % [dir, tower_id]
	if not FileAccess.file_exists(meta_path):
		return null
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim_name in meta["animations"]:
		var info: Dictionary = meta["animations"][anim_name]
		var sheet: Texture2D = load("%s/%s_%s_sheet.png" % [dir, tower_id, anim_name])
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, float(info["fps"]))
		frames.set_animation_loop(anim_name, bool(info["loop"]))
		for i in int(info["frames"]):
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
			frames.add_frame(anim_name, frame)
	return frames
