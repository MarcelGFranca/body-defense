## Builds `SpriteFrames` for an enemy from the sprite atlas, or from a placeholder when it has no animations.
class_name EnemySprites
extends RefCounted

const PLACEHOLDERS := {
	"virus": "res://assets/placeholders/virus.png",
	"bacterium": "res://assets/placeholders/bacterium.png",
}

static var _cache: Dictionary = {}


static func frames_for(data: EnemyData) -> SpriteFrames:
	# The cache is keyed by the sprite folder: a chain segment has the id of its enemy but art of its own.
	var key := data.sprite_dir if data.sprite_dir != "" else data.id
	if _cache.has(key):
		return _cache[key]
	var frames: SpriteFrames = null
	if data.sprite_dir != "":
		frames = SpriteAtlas.frames_for("enemies", data.sprite_dir.get_file())
	if frames == null:
		frames = SpriteFrames.new()
		frames.remove_animation("default")
		frames.add_animation("walk")
		frames.set_animation_loop("walk", true)
		frames.add_frame("walk", load(PLACEHOLDERS[data.type]))
	_cache[key] = frames
	return frames


## The still sprite used for icons.
static func icon_for(data: EnemyData) -> Texture2D:
	if data.sprite_dir != "":
		var path := "%s/%s_sprite.png" % [data.sprite_dir, data.id]
		if ResourceLoader.exists(path):
			return load(path)
	return load(PLACEHOLDERS[data.type])
