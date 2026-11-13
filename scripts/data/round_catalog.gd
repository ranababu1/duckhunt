class_name RoundCatalog
extends RefCounted

const RoundConfigScript = preload("res://scripts/data/round_config.gd")

static func classic_mode() -> Array:
	var rounds: Array = []
	var definitions := [
		[3, 1, 0.85, 170.0, 2, 2], [3, 1, 0.80, 180.0, 2, 2],
		[4, 1, 0.75, 190.0, 3, 2], [4, 1, 0.70, 205.0, 3, 2],
		[5, 1, 0.65, 220.0, 3, 2], [5, 1, 0.60, 235.0, 4, 2],
		[6, 2, 0.58, 245.0, 4, 2], [6, 2, 0.55, 255.0, 4, 1],
		[7, 2, 0.52, 270.0, 5, 1], [8, 2, 0.50, 285.0, 6, 1]
	]
	for index in definitions.size():
		var definition: Array = definitions[index]
		var config = RoundConfigScript.new()
		config.round_number = index + 1
		config.duck_count = definition[0]
		config.ducks_per_wave = definition[1]
		config.spawn_interval = definition[2]
		config.min_flight_speed = definition[3]
		config.max_flight_speed = definition[3] + 20.0
		config.required_hits = definition[4]
		config.allowed_escapes = definition[5]
		config.movement_pattern_pool.clear()
		config.movement_pattern_pool.append("sine")
		if index >= 3:
			config.movement_pattern_pool.append("diagonal")
		rounds.append(config)
	return rounds
