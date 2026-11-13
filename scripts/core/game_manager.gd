class_name GameManager
extends Node

signal state_changed(previous_state: State, new_state: State)
signal round_started(config: Resource)
signal run_completed()

enum State { MENU, PLAYING, ROUND_CLEAR, GAME_OVER, RUN_COMPLETE }

const ROUND_TRANSITION_DURATION := 0.8

var state := State.MENU
var round_configs: Array = []
var current_round_index := 0
var transition_remaining := 0.0

func configure(new_round_configs: Array) -> void:
	round_configs = new_round_configs

func start_run() -> void:
	current_round_index = 0
	_start_current_round()

func on_round_cleared() -> void:
	if state != State.PLAYING:
		return
	if current_round_index + 1 >= round_configs.size():
		_transition_to(State.RUN_COMPLETE)
		run_completed.emit()
		return
	_transition_to(State.ROUND_CLEAR)
	transition_remaining = ROUND_TRANSITION_DURATION

func on_round_failed() -> void:
	if state == State.PLAYING:
		_transition_to(State.GAME_OVER)

func _process(delta: float) -> void:
	if state != State.ROUND_CLEAR:
		return
	transition_remaining -= delta
	if transition_remaining <= 0.0:
		current_round_index += 1
		_start_current_round()

func current_config() -> Resource:
	if round_configs.is_empty():
		return null
	return round_configs[current_round_index]

func _start_current_round() -> void:
	if round_configs.is_empty():
		push_error("GameManager requires at least one round configuration.")
		_transition_to(State.MENU)
		return
	_transition_to(State.PLAYING)
	round_started.emit(current_config())

func _transition_to(new_state: State) -> void:
	if state == new_state:
		return
	var previous_state := state
	state = new_state
	state_changed.emit(previous_state, state)
