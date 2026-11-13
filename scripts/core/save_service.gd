class_name SaveService
extends RefCounted

const SAVE_PATH := "user://duckhunt_arcade.cfg"
const SECTION_SETTINGS := "settings"
const SECTION_PROGRESS := "progress"

static func load_settings(path: String = SAVE_PATH) -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return _default_settings()
	return {
		"music_volume": _read_volume(config, "music_volume", 0.7),
		"sfx_volume": _read_volume(config, "sfx_volume", 0.8),
		"haptics": _read_bool(config, "haptics", true),
		"reduced_flash": _read_bool(config, "reduced_flash", false)
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
	var value: Variant = config.get_value(SECTION_PROGRESS, "best_score", 0)
	if typeof(value) != TYPE_INT:
		return 0
	return maxi(0, value)

static func save_best_score(score: int, path: String = SAVE_PATH) -> Error:
	var config := _load_config(path)
	config.set_value(SECTION_PROGRESS, "best_score", maxi(score, load_best_score(path)))
	return config.save(path)

static func _load_config(path: String) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(path)
	return config

static func _default_settings() -> Dictionary:
	return {"music_volume": 0.7, "sfx_volume": 0.8, "haptics": true, "reduced_flash": false}

static func _read_volume(config: ConfigFile, key: String, fallback: float) -> float:
	var value: Variant = config.get_value(SECTION_SETTINGS, key, fallback)
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return fallback
	return clampf(float(value), 0.0, 1.0)

static func _read_bool(config: ConfigFile, key: String, fallback: bool) -> bool:
	var value: Variant = config.get_value(SECTION_SETTINGS, key, fallback)
	return value if typeof(value) == TYPE_BOOL else fallback
