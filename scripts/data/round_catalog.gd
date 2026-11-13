class_name RoundCatalog
extends RefCounted

const RoundConfigScript = preload("res://scripts/data/round_config.gd")

static func classic_mode() -> Array:
	var rounds: Array = []
	var definitions := [
		[3, 1, 0.85, 210.0, 2, 2], [3, 1, 0.80, 230.0, 2, 2],
		[4, 1, 0.75, 250.0, 3, 2], [4, 1, 0.70, 270.0, 3, 2],
		[5, 1, 0.65, 290.0, 3, 2], [5, 1, 0.60, 310.0, 4, 2],
		[6, 2, 0.58, 330.0, 4, 2], [6, 2, 0.55, 350.0, 4, 1],
		[7, 2, 0.52, 370.0, 5, 1], [8, 2, 0.50, 390.0, 6, 1]
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
		var difficulty := float(index) / float(definitions.size() - 1)
		config.min_reroute_interval = lerpf(0.72, 0.24, difficulty)
		config.max_reroute_interval = lerpf(0.95, 0.42, difficulty)
		config.required_hits = definition[4]
		config.allowed_escapes = definition[5]
		config.movement_pattern_pool.clear()
		config.movement_pattern_pool.append("zigzag")
		if index >= 3:
			config.movement_pattern_pool.append("diagonal")
		rounds.append(config)
	return rounds
