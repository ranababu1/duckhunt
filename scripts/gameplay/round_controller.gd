class_name RoundController
extends Node

signal quota_changed(hits: int, required_hits: int)
signal duck_escaped(escapes: int, allowed_escapes: int)
signal round_cleared()
signal round_failed()

@export var required_hits := 3
@export var allowed_escapes := 2

var round_hits := 0
var escapes := 0
var is_finished := false

func start_round(config: Resource) -> void:
	required_hits = config.required_hits
	allowed_escapes = config.allowed_escapes
	round_hits = 0
	escapes = 0
	is_finished = false
	quota_changed.emit(round_hits, required_hits)

func register_hit() -> void:
	if is_finished:
		return
	round_hits += 1
	quota_changed.emit(round_hits, required_hits)
	if round_hits >= required_hits:
		is_finished = true
		round_cleared.emit()

func register_escape() -> void:
	if is_finished:
		return
	escapes += 1
	duck_escaped.emit(escapes, allowed_escapes)
	if escapes > allowed_escapes:
		is_finished = true
		round_failed.emit()
