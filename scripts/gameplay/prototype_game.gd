extends Node2D

## Greybox scene composition. Gameplay rules live in dedicated controllers.

const PLAYFIELD := Rect2(24.0, 76.0, 912.0, 420.0)
const DUCK_RADIUS := 26.0
const DuckScript = preload("res://scripts/gameplay/duck.gd")
const WeaponControllerScript = preload("res://scripts/gameplay/weapon_controller.gd")
const RunControllerScript = preload("res://scripts/gameplay/run_controller.gd")
const RoundControllerScript = preload("res://scripts/gameplay/round_controller.gd")
const GameManagerScript = preload("res://scripts/core/game_manager.gd")
const RoundCatalogScript = preload("res://scripts/data/round_catalog.gd")
const ScoreServiceScript = preload("res://scripts/gameplay/score_service.gd")
const GameUIScript = preload("res://scripts/ui/game_ui.gd")
const SaveServiceScript = preload("res://scripts/core/save_service.gd")
const InputControllerScript = preload("res://scripts/gameplay/input_controller.gd")

var ui
var audio
var input_controller
var ducks: Array = []
var weapon
var run
var round
var game_manager
var active_round_config
var feedback := "TAP THE DUCK"
var feedback_time := 0.0
var shot_marker := Vector2.ZERO
var shot_marker_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	weapon = WeaponControllerScript.new()
	run = RunControllerScript.new()
	round = RoundControllerScript.new()
	game_manager = GameManagerScript.new()
	ui = GameUIScript.new()
	audio = get_node("AudioManager")
	input_controller = InputControllerScript.new()
	add_child(weapon)
	add_child(run)
	add_child(round)
	add_child(game_manager)
	add_child(ui)
	add_child(input_controller)
	weapon.process_mode = Node.PROCESS_MODE_PAUSABLE
	round.process_mode = Node.PROCESS_MODE_PAUSABLE
	game_manager.process_mode = Node.PROCESS_MODE_ALWAYS
	for _index in 2:
		_create_duck()
	weapon.shot_fired.connect(_resolve_shot)
	weapon.reload_started.connect(func() -> void:
		audio.play_event("reload")
		_show_feedback("RELOADING")
	)
	weapon.reload_finished.connect(func() -> void: _show_feedback("RELOADED"))
	round.round_cleared.connect(_on_round_cleared)
	round.round_failed.connect(_on_round_failed)
	round.spawn_wave.connect(_spawn_wave)
	run.life_depleted.connect(game_manager.on_lives_depleted)
	game_manager.round_started.connect(_apply_round_config)
	game_manager.state_changed.connect(_on_game_state_changed)
	input_controller.shot_requested.connect(_try_fire)
	ui.play_requested.connect(_start_run)
	ui.pause_requested.connect(_pause_run)
	ui.resume_requested.connect(_resume_run)
	ui.restart_requested.connect(_start_run)
	ui.return_title_requested.connect(_return_to_title)
	ui.continue_requested.connect(_continue_round)
	ui.tutorial_requested.connect(ui.show_tutorial)
	ui.setting_changed.connect(_on_setting_changed)
	ui.setting_changed.connect(audio.apply_setting)
	ui.ui_action.connect(func() -> void: audio.play_event("button"))
	weapon.shot_fired.connect(func(_position: Vector2) -> void: audio.play_event("shot"))
	game_manager.run_completed.connect(_on_run_completed)
	game_manager.configure(RoundCatalogScript.classic_mode())
	var saved_settings: Dictionary = ui.current_settings()
	audio.apply_setting("music_volume", saved_settings.music_volume)
	audio.apply_setting("sfx_volume", saved_settings.sfx_volume)
	audio.set_context("menu")
	ui.show_title(SaveServiceScript.load_best_score())
	queue_redraw()

func _process(delta: float) -> void:
	feedback_time = maxf(0.0, feedback_time - delta)
	shot_marker_time = maxf(0.0, shot_marker_time - delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_handle_back_navigation()

func _notification(what: int) -> void:
	if not is_inside_tree():
		return
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back_navigation()
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if game_manager != null and game_manager.state == game_manager.State.PLAYING:
			_pause_run()

func _handle_back_navigation() -> void:
	if ui.screens["settings"].visible:
		ui.back_from_settings()
	elif ui.screens["tutorial"].visible:
		ui.show_title(SaveServiceScript.load_best_score())
	elif game_manager.state == game_manager.State.PLAYING:
		_pause_run()
	elif game_manager.state == game_manager.State.PAUSED:
		_resume_run()
	elif game_manager.state == game_manager.State.ROUND_CLEAR or game_manager.state == game_manager.State.GAME_OVER or game_manager.state == game_manager.State.RUN_COMPLETE:
		_return_to_title()
	else:
		get_tree().quit()

func _try_fire(shot_position: Vector2) -> void:
	if not PLAYFIELD.has_point(shot_position):
		return
	if game_manager.state != game_manager.State.PLAYING:
		return
	if weapon.is_reloading:
		_show_feedback("RELOADING")
		return
	weapon.request_fire(shot_position)

func _resolve_shot(shot_position: Vector2) -> void:
	run.record_shot()
	shot_marker = shot_position
	shot_marker_time = 0.0 if bool(ui.current_settings().get("reduced_flash", false)) else 0.12
	var target = _closest_target(shot_position)
	if target == null or not target.try_hit(shot_position):
		audio.play_event("miss")
		run.record_miss()
		_trigger_haptic(8)
		_show_feedback("MISS")

func _on_duck_hit(_duck: Node2D) -> void:
	audio.play_event("hit")
	var points: int = ScoreServiceScript.points_for_hit(run.combo)
	run.record_hit(points)
	round.register_hit()
	_trigger_haptic(22)
	_show_feedback("HIT +%d" % points)

func _on_duck_escaped(_duck: Node2D) -> void:
	audio.play_event("escape")
	run.record_escape()
	round.register_escape()
	_trigger_haptic(12)
	_show_feedback("ESCAPED")

func _on_duck_terminal_finished(_duck: Node2D) -> void:
	round.register_terminal_animation_finished()

func _on_round_cleared() -> void:
	var remaining_escapes: int = round.allowed_escapes - round.escapes
	var bonus: int = ScoreServiceScript.round_clear_bonus(remaining_escapes, run.accuracy_percent())
	run.add_score(bonus)
	audio.play_event("round_clear")
	_trigger_haptic(28)
	game_manager.on_round_cleared()

func _on_round_failed() -> void:
	game_manager.on_round_failed()

func _apply_round_config(config: Resource) -> void:
	active_round_config = config
	for target in ducks:
		target.deactivate()
	round.start_round(config)
	weapon.configure(config.ammo_per_magazine, config.reload_duration)

func _on_game_state_changed(_previous_state: int, new_state: int) -> void:
	match new_state:
		game_manager.State.MENU:
			audio.set_context("menu")
			get_tree().paused = false
			for target in ducks:
				target.set_process(false)
			weapon.set_process(false)
			round.set_process(false)
			ui.show_title(SaveServiceScript.load_best_score())
		game_manager.State.PLAYING:
			audio.set_context("gameplay")
			get_tree().paused = false
			for target in ducks:
				if target.state != DuckScript.State.OFFSCREEN:
					target.set_process(true)
			weapon.set_process(true)
			round.set_process(true)
			ui.show_gameplay()
		game_manager.State.PAUSED:
			get_tree().paused = true
			ui.show_pause()
		game_manager.State.ROUND_CLEAR:
			get_tree().paused = true
			ui.show_round_clear(active_round_config.round_number, run.score)
		game_manager.State.GAME_OVER:
			audio.play_event("game_over")
			get_tree().paused = true
			_show_results("GAME OVER")
		game_manager.State.RUN_COMPLETE:
			get_tree().paused = true
			_show_results("CLASSIC MODE COMPLETE")

func _start_run() -> void:
	get_tree().paused = false
	run.reset_run()
	game_manager.start_run()

func _pause_run() -> void:
	game_manager.pause_run()

func _resume_run() -> void:
	game_manager.resume_run()

func _continue_round() -> void:
	game_manager.continue_round()

func _return_to_title() -> void:
	get_tree().paused = false
	SaveServiceScript.save_best_score(run.score)
	game_manager.return_to_title()

func _show_results(heading: String) -> void:
	var best := maxi(run.score, SaveServiceScript.load_best_score())
	SaveServiceScript.save_best_score(best)
	var rounds_cleared: int = game_manager.current_round_index
	if game_manager.state == game_manager.State.RUN_COMPLETE:
		rounds_cleared = game_manager.round_configs.size()
	ui.show_results(heading, run.score, best, rounds_cleared, run.shots_fired, run.hits, run.accuracy_percent())

func _on_run_completed() -> void:
	pass

func _on_setting_changed(key: String, value: Variant) -> void:
	if key == "reduced_flash" and bool(value):
		shot_marker_time = 0.0
	if key == "reduced_flash":
		for target in ducks:
			target.set_reduced_flash(bool(value))

func _create_duck():
	var duck = DuckScript.new()
	duck.process_mode = Node.PROCESS_MODE_PAUSABLE
	duck.state = DuckScript.State.OFFSCREEN
	duck.set_reduced_flash(bool(ui.current_settings().get("reduced_flash", false)))
	duck.set_process(false)
	duck.resolved_hit.connect(_on_duck_hit)
	duck.resolved_escape.connect(_on_duck_escaped)
	duck.terminal_animation_finished.connect(_on_duck_terminal_finished)
	add_child(duck)
	ducks.append(duck)
	return duck

func _spawn_wave(count: int) -> void:
	var spawned := 0
	for _index in count:
		var duck = _find_available_duck()
		if duck == null:
			duck = _create_duck()
		var pattern_pool: Array = active_round_config.movement_pattern_pool
		var pattern: String = pattern_pool[randi_range(0, pattern_pool.size() - 1)]
		var direction := 1.0 if (spawned % 2) == 0 else -1.0
		var y := 205.0 + float(spawned) * 150.0
		var start_x := PLAYFIELD.position.x - DUCK_RADIUS if direction > 0.0 else PLAYFIELD.end.x + DUCK_RADIUS
		var speed := randf_range(active_round_config.min_flight_speed, active_round_config.max_flight_speed)
		var vertical_speed := 0.0
		if pattern == "diagonal":
			vertical_speed = -70.0 if spawned % 2 == 0 else 70.0
		duck.scale.x = direction
		duck.start_flight(Vector2(start_x, y), PLAYFIELD, Vector2(speed * direction, vertical_speed), pattern)
		duck.set_process(true)
		spawned += 1

func _find_available_duck():
	for duck in ducks:
		if duck.state == DuckScript.State.OFFSCREEN:
			return duck
	return null

func _closest_target(shot_position: Vector2):
	var selected = null
	var selected_distance := INF
	for duck in ducks:
		if duck.state != DuckScript.State.ENTERING and duck.state != DuckScript.State.FLYING:
			continue
		var distance: float = shot_position.distance_to(duck.global_position)
		if distance <= DuckScript.HIT_RADIUS and distance < selected_distance:
			selected = duck
			selected_distance = distance
	return selected

func _trigger_haptic(duration_ms: int) -> void:
	if bool(ui.current_settings().get("haptics", true)) and OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms)

func _show_feedback(message: String) -> void:
	feedback = message
	feedback_time = 0.65

func _draw() -> void:
	# Original geometric greybox environment; final pixel artwork is deferred.
	draw_rect(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)), Color("79c8e8"))
	draw_circle(Vector2(808.0, 136.0), 42.0, Color("ffe59a"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 270), Vector2(180, 168), Vector2(370, 270), Vector2(550, 154), Vector2(760, 270), Vector2(960, 182), Vector2(960, 370), Vector2(0, 370)]), Color("5d9f75"))
	draw_rect(Rect2(0, 366, 960, 174), Color("4c8243"))
	draw_rect(PLAYFIELD, Color("173b4b"), false, 3.0)
	_draw_hud()
	if shot_marker_time > 0.0:
		draw_arc(shot_marker, 18.0, 0.0, TAU, 16, Color("fff4b5"), 3.0)
	if feedback_time > 0.0:
		_draw_centered_text(feedback, Vector2(480.0, 122.0), 24, Color("fff4b5"))

func _draw_hud() -> void:
	draw_rect(Rect2(18, 14, 924, 50), Color("18334d"))
	_draw_text("SCORE %05d" % run.score, Vector2(34, 47), 22, Color("fff4b5"))
	var round_label := "ROUND -- / 10" if active_round_config == null else "ROUND %d / 10" % active_round_config.round_number
	_draw_centered_text(round_label, Vector2(480, 47), 18, Color("d9f0ff"))
	_draw_text("AMMO", Vector2(726, 47), 18, Color("fff4b5"))
	for index in weapon.magazine_capacity:
		var bullet_color := Color("ffd35c") if index < weapon.current_ammo else Color("6d8291")
		draw_rect(Rect2(818 + index * 34, 27, 20, 20), bullet_color)
	if weapon.is_reloading:
		_draw_centered_text("RELOADING", Vector2(480, 520), 16, Color("fff4b5"))
	else:
		_draw_centered_text("HITS %d/%d  COMBO %d  LIVES %d" % [round.round_hits, round.required_hits, run.combo, run.lives], Vector2(480, 520), 16, Color("d9f0ff"))

func _draw_text(text: String, position: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_centered_text(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_draw_text(text, position - Vector2(width * 0.5, 0.0), font_size, color)
