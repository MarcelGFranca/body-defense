## Builds `SpriteFrames` for an enemy from its generated sprite sheets, or from a placeholder.
class_name EnemySprites
extends RefCounted

const FRAME_SIZE := 32
const PLACEHOLDERS := {
	"virus": "res://assets/placeholders/virus.png",
	"bacterium": "res://assets/placeholders/bacterium.png",
}

static var _cache: Dictionary = {}


static func frames_for(data: EnemyData) -> SpriteFrames:
	if _cache.has(data.id):
		return _cache[data.id]
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	if data.sprite_dir != "" and _add_sheets(frames, data):
		_cache[data.id] = frames
		return frames
	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.add_frame("walk", load(PLACEHOLDERS[data.type]))
	_cache[data.id] = frames
	return frames


## The still sprite used for icons.
static func icon_for(data: EnemyData) -> Texture2D:
	if data.sprite_dir != "":
		var path := "%s/%s_sprite.png" % [data.sprite_dir, data.id]
		if ResourceLoader.exists(path):
			return load(path)
	return load(PLACEHOLDERS[data.type])


static func _add_sheets(frames: SpriteFrames, data: EnemyData) -> bool:
	var meta_path := "%s/animations/%s_animations.json" % [data.sprite_dir, data.id]
	if not FileAccess.file_exists(meta_path):
		return false
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	for anim_name in meta["animations"]:
		var info: Dictionary = meta["animations"][anim_name]
		var sheet: Texture2D = load("%s/animations/%s_%s_sheet.png" % [data.sprite_dir, data.id, anim_name])
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, float(info["fps"]))
		frames.set_animation_loop(anim_name, bool(info["loop"]))
		for i in int(info["frames"]):
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
			frames.add_frame(anim_name, frame)
	return true
