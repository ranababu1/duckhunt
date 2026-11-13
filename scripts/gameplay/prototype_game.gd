extends Node2D

## M0 greybox: self-contained touch-to-shoot prototype.
## Gameplay values are intentionally grouped here until the M1 controllers exist.

const PLAYFIELD := Rect2(24.0, 76.0, 912.0, 420.0)
const DUCK_RADIUS := 26.0
const DuckScript = preload("res://scripts/gameplay/duck.gd")
const WeaponControllerScript = preload("res://scripts/gameplay/weapon_controller.gd")
const RunControllerScript = preload("res://scripts/gameplay/run_controller.gd")
const RoundControllerScript = preload("res://scripts/gameplay/round_controller.gd")
const GameManagerScript = preload("res://scripts/core/game_manager.gd")
const RoundCatalogScript = preload("res://scripts/data/round_catalog.gd")
const ScoreServiceScript = preload("res://scripts/gameplay/score_service.gd")

var duck
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
	weapon = WeaponControllerScript.new()
	run = RunControllerScript.new()
	round = RoundControllerScript.new()
	game_manager = GameManagerScript.new()
	duck = DuckScript.new()
	add_child(weapon)
	add_child(run)
	add_child(round)
	add_child(game_manager)
	add_child(duck)
	weapon.shot_fired.connect(_resolve_shot)
	weapon.reload_started.connect(func() -> void: _show_feedback("RELOADING"))
	weapon.reload_finished.connect(func() -> void: _show_feedback("RELOADED"))
	duck.resolved_hit.connect(_on_duck_hit)
	duck.resolved_escape.connect(_on_duck_escaped)
	duck.terminal_animation_finished.connect(_on_duck_terminal_finished)
	round.round_cleared.connect(_on_round_cleared)
	round.round_failed.connect(_on_round_failed)
	run.life_depleted.connect(game_manager.on_lives_depleted)
	game_manager.round_started.connect(_apply_round_config)
	game_manager.state_changed.connect(_on_game_state_changed)
	game_manager.configure(RoundCatalogScript.classic_mode())
	run.reset_run()
	game_manager.start_run()
	queue_redraw()

func _process(delta: float) -> void:
	feedback_time = maxf(0.0, feedback_time - delta)
	shot_marker_time = maxf(0.0, shot_marker_time - delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_try_fire(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_fire(event.position)
	elif event.is_action_pressed("pause"):
		_show_feedback("PAUSE WILL ARRIVE IN M3")

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
	shot_marker_time = 0.12
	if not duck.try_hit(shot_position):
		run.record_miss()
		_show_feedback("MISS")

func _on_duck_hit(_duck: Node2D) -> void:
	var points: int = ScoreServiceScript.points_for_hit(run.combo)
	run.record_hit(points)
	round.register_hit()
	_show_feedback("HIT +%d" % points)

func _on_duck_escaped(_duck: Node2D) -> void:
	run.record_escape()
	round.register_escape()
	_show_feedback("ESCAPED")

func _on_duck_terminal_finished(_duck: Node2D) -> void:
	if game_manager.state == game_manager.State.PLAYING and not round.is_finished:
		_spawn_duck()

func _on_round_cleared() -> void:
	var remaining_escapes: int = round.allowed_escapes - round.escapes
	var bonus: int = ScoreServiceScript.round_clear_bonus(remaining_escapes, run.accuracy_percent())
	run.add_score(bonus)
	game_manager.on_round_cleared()

func _on_round_failed() -> void:
	game_manager.on_round_failed()

func _apply_round_config(config: Resource) -> void:
	active_round_config = config
	round.start_round(config)
	weapon.configure(config.ammo_per_magazine, config.reload_duration)
	_spawn_duck()

func _on_game_state_changed(_previous_state: int, new_state: int) -> void:
	if new_state == game_manager.State.ROUND_CLEAR:
		_show_feedback("ROUND %d CLEAR" % active_round_config.round_number)
	elif new_state == game_manager.State.GAME_OVER:
		_show_feedback("GAME OVER")
	elif new_state == game_manager.State.RUN_COMPLETE:
		_show_feedback("CLASSIC MODE CLEAR")

func _spawn_duck() -> void:
	var speed: float = active_round_config.min_flight_speed
	duck.start_flight(Vector2(PLAYFIELD.position.x - DUCK_RADIUS, 272.0), PLAYFIELD, Vector2(speed, 0.0))

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
