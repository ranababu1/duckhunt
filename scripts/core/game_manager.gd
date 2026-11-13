class_name GameManager
extends Node

signal state_changed(previous_state: State, new_state: State)
signal round_started(config: Resource)
signal run_completed()

enum State { MENU, PLAYING, PAUSED, ROUND_CLEAR, GAME_OVER, RUN_COMPLETE }

var state := State.MENU
var round_configs: Array = []
var current_round_index := 0

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

func on_round_failed() -> void:
	if state == State.PLAYING:
		_transition_to(State.GAME_OVER)

func on_lives_depleted() -> void:
	if state == State.PLAYING:
		_transition_to(State.GAME_OVER)

func continue_round() -> void:
	if state != State.ROUND_CLEAR:
		return
	current_round_index += 1
	_start_current_round()

func pause_run() -> void:
	if state == State.PLAYING:
		_transition_to(State.PAUSED)

func resume_run() -> void:
	if state == State.PAUSED:
		_transition_to(State.PLAYING)

func return_to_title() -> void:
	if state != State.MENU:
		_transition_to(State.MENU)

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
