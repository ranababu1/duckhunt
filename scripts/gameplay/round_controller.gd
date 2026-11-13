class_name RoundController
extends Node

signal quota_changed(hits: int, required_hits: int)
signal duck_escaped(escapes: int, allowed_escapes: int)
signal spawn_wave(count: int)
signal round_cleared()
signal round_failed()

@export var required_hits := 3
@export var allowed_escapes := 2

var round_hits := 0
var escapes := 0
var is_finished := false
var total_ducks := 3
var ducks_per_wave := 1
var spawn_interval := 0.8
var ducks_remaining_to_spawn := 3
var active_ducks := 0
var spawn_timer := 0.0

func _ready() -> void:
	set_process(false)

func start_round(config: Resource) -> void:
	required_hits = config.required_hits
	allowed_escapes = config.allowed_escapes
	total_ducks = config.duck_count
	ducks_per_wave = config.ducks_per_wave
	spawn_interval = config.spawn_interval
	round_hits = 0
	escapes = 0
	is_finished = false
	ducks_remaining_to_spawn = total_ducks
	active_ducks = 0
	spawn_timer = 0.0
	quota_changed.emit(round_hits, required_hits)
	set_process(true)
	_spawn_available_wave()

func _process(delta: float) -> void:
	if is_finished or ducks_remaining_to_spawn <= 0:
		return
	spawn_timer = maxf(0.0, spawn_timer - delta)
	if spawn_timer == 0.0 and active_ducks < ducks_per_wave:
		_spawn_available_wave()

func register_hit() -> void:
	if is_finished:
		return
	round_hits += 1
	quota_changed.emit(round_hits, required_hits)
	if round_hits >= required_hits:
		is_finished = true
		set_process(false)
		round_cleared.emit()
	else:
		_check_for_exhaustion()

func register_escape() -> void:
	if is_finished:
		return
	escapes += 1
	duck_escaped.emit(escapes, allowed_escapes)
	if escapes > allowed_escapes:
		is_finished = true
		set_process(false)
		round_failed.emit()
	else:
		_check_for_exhaustion()

func register_terminal_animation_finished() -> void:
	active_ducks = maxi(active_ducks - 1, 0)
	_check_for_exhaustion()
	if not is_finished:
		_process(0.0)

func _spawn_available_wave() -> void:
	if is_finished or ducks_remaining_to_spawn <= 0 or active_ducks >= ducks_per_wave:
		_check_for_exhaustion()
		return
	var count := mini(ducks_per_wave - active_ducks, ducks_remaining_to_spawn)
	ducks_remaining_to_spawn -= count
	active_ducks += count
	spawn_timer = spawn_interval
	spawn_wave.emit(count)

func _check_for_exhaustion() -> void:
	if is_finished or ducks_remaining_to_spawn > 0 or active_ducks > 0:
		return
	is_finished = true
	set_process(false)
	round_failed.emit()
