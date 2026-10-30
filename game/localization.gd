## The languages of the game and the helpers to switch between them. The texts are in localization/translations.csv
## (English text as the key, one column per language); a missing translation shows the English text.
class_name Localization
extends RefCounted

const LANGUAGES := [
	{"code": "en", "name": "English"},
	{"code": "pt_BR", "name": "Português"},
	{"code": "fr", "name": "Français"},
	{"code": "es", "name": "Español"},
	{"code": "it", "name": "Italiano"},
	{"code": "zh_CN", "name": "中文"},
	{"code": "ja", "name": "日本語"},
]
const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"


static func codes() -> Array:
	return LANGUAGES.map(func(entry: Dictionary) -> String: return entry["code"])


static func is_supported(code: String) -> bool:
	return codes().has(code)


static func name_of(code: String) -> String:
	for entry in LANGUAGES:
		if entry["code"] == code:
			return entry["name"]
	return code


static func apply(code: String) -> void:
	TranslationServer.set_locale(code if is_supported(code) else "en")


## The language of the phone when the game supports it, otherwise English.
static func from_os() -> String:
	var locale := OS.get_locale()
	if is_supported(locale):
		return locale
	match locale.substr(0, 2):
		"pt":
			return "pt_BR"
		"zh":
			return "zh_CN"
	return locale.substr(0, 2) if is_supported(locale.substr(0, 2)) else "en"


## The pixel font has no Chinese or Japanese characters: the system font fills the gaps.
static func prepare_font() -> void:
	if not ResourceLoader.exists(FONT_PATH):
		return
	var font := load(FONT_PATH) as FontFile
	if font == null or not font.fallbacks.is_empty():
		return
	var system := SystemFont.new()
	system.font_names = PackedStringArray(["Noto Sans CJK SC", "Noto Sans CJK JP", "Noto Sans SC", "Noto Sans JP", "Droid Sans Fallback", "sans-serif"])
	font.fallbacks = [system]
