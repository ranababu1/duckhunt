class_name RunController
extends Node

signal counters_changed(shots: int, hits: int, misses: int, score: int)
signal lives_changed(current_lives: int)
signal life_depleted()

@export var initial_lives := 3
var shots_fired := 0
var hits := 0
var misses := 0
var score := 0
var combo := 0
var lives := 3

func reset_run() -> void:
	shots_fired = 0
	hits = 0
	misses = 0
	score = 0
	combo = 0
	lives = initial_lives
	_emit_counters()
	lives_changed.emit(lives)

func record_shot() -> void:
	shots_fired += 1
	_emit_counters()

func record_hit(points: int) -> void:
	hits += 1
	score += points
	combo += 1
	_emit_counters()

func record_miss() -> void:
	misses += 1
	combo = 0
	_emit_counters()

func record_escape() -> void:
	combo = 0
	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)
	if lives == 0:
		life_depleted.emit()

func add_score(points: int) -> void:
	score += maxi(points, 0)
	_emit_counters()

func accuracy_percent() -> float:
	if shots_fired == 0:
		return 0.0
	return float(hits) / float(shots_fired) * 100.0

func _emit_counters() -> void:
	counters_changed.emit(shots_fired, hits, misses, score)
