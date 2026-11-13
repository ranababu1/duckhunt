class_name SaveService
extends RefCounted

const SAVE_PATH := "user://duckhunt_arcade.cfg"
const SECTION_SETTINGS := "settings"
const SECTION_PROGRESS := "progress"

static func load_settings(path: String = SAVE_PATH) -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return {"music_volume": 0.7, "sfx_volume": 0.8, "haptics": true, "reduced_flash": false}
	return {
		"music_volume": clampf(config.get_value(SECTION_SETTINGS, "music_volume", 0.7), 0.0, 1.0),
		"sfx_volume": clampf(config.get_value(SECTION_SETTINGS, "sfx_volume", 0.8), 0.0, 1.0),
		"haptics": bool(config.get_value(SECTION_SETTINGS, "haptics", true)),
		"reduced_flash": bool(config.get_value(SECTION_SETTINGS, "reduced_flash", false))
	}

static func save_settings(settings: Dictionary, path: String = SAVE_PATH) -> Error:
	var config := _load_config(path)
	config.set_value(SECTION_SETTINGS, "music_volume", clampf(float(settings.get("music_volume", 0.7)), 0.0, 1.0))
	config.set_value(SECTION_SETTINGS, "sfx_volume", clampf(float(settings.get("sfx_volume", 0.8)), 0.0, 1.0))
	config.set_value(SECTION_SETTINGS, "haptics", bool(settings.get("haptics", true)))
	config.set_value(SECTION_SETTINGS, "reduced_flash", bool(settings.get("reduced_flash", false)))
	return config.save(path)

static func load_best_score(path: String = SAVE_PATH) -> int:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return 0
	return maxi(0, int(config.get_value(SECTION_PROGRESS, "best_score", 0)))

static func save_best_score(score: int, path: String = SAVE_PATH) -> Error:
	var config := _load_config(path)
	config.set_value(SECTION_PROGRESS, "best_score", maxi(score, load_best_score(path)))
	return config.save(path)

static func _load_config(path: String) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(path)
	return config
