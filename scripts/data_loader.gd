class_name DataLoader
extends RefCounted


## Loads every `.tres` in `dir` and returns them keyed by their `id`.
static func load_all(dir: String) -> Dictionary:
	var out: Dictionary = {}
	for file in DirAccess.get_files_at(dir):
		var name := file.trim_suffix(".remap")
		if not name.ends_with(".tres"):
			continue
		var res := load(dir.path_join(name))
		if res != null:
			out[res.id] = res
	return out
