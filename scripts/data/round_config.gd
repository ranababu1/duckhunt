class_name RoundConfig
extends Resource

@export var round_number := 1
@export var duck_count := 3
@export var ducks_per_wave := 1
@export var spawn_interval := 0.8
@export var min_flight_speed := 180.0
@export var max_flight_speed := 180.0
@export var movement_pattern_pool: Array[String] = ["sine"]
@export var required_hits := 2
@export var allowed_escapes := 2
@export var ammo_per_magazine := 2
@export var reload_duration := 0.75
