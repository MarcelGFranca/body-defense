## Builds `SpriteFrames` for a tower from the sprite atlas, or null when it has none.
class_name TowerSprites
extends RefCounted

static var _cache: Dictionary = {}


static func frames_for(tower_id: String) -> SpriteFrames:
	if _cache.has(tower_id):
		return _cache[tower_id]
	_cache[tower_id] = SpriteAtlas.frames_for("towers", tower_id)
	return _cache[tower_id]
