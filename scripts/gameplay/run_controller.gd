class_name RunController
extends Node

signal counters_changed(shots: int, hits: int, misses: int, score: int)

var shots_fired := 0
var hits := 0
var misses := 0
var score := 0

func reset_run() -> void:
	shots_fired = 0
	hits = 0
	misses = 0
	score = 0
	_emit_counters()

func record_shot() -> void:
	shots_fired += 1
	_emit_counters()

func record_hit() -> void:
	hits += 1
	score += 100
	_emit_counters()

func record_miss() -> void:
	misses += 1
	_emit_counters()

func accuracy_percent() -> float:
	if shots_fired == 0:
		return 0.0
	return float(hits) / float(shots_fired) * 100.0

func _emit_counters() -> void:
	counters_changed.emit(shots_fired, hits, misses, score)
