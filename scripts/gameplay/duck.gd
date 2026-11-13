class_name Duck
extends Node2D

signal resolved_hit(duck: Node2D)
signal resolved_escape(duck: Node2D)
signal terminal_animation_finished(duck: Node2D)

enum State { ENTERING, FLYING, HIT, ESCAPING, OFFSCREEN }

const HIT_RADIUS := 26.0
const TERMINAL_ANIMATION_DURATION := 0.35

var state := State.ENTERING
var flight_velocity := Vector2(180.0, 0.0)
var playfield := Rect2(24.0, 76.0, 912.0, 420.0)
var flight_time := 0.0
var terminal_time := 0.0
var resolution_sent := false
var movement_pattern := "sine"
var base_y := 272.0
var reduced_flash := false

func start_flight(start_position: Vector2, new_playfield: Rect2, new_velocity: Vector2, new_pattern := "sine") -> void:
	position = start_position
	playfield = new_playfield
	flight_velocity = new_velocity
	base_y = start_position.y
	movement_pattern = new_pattern
	flight_time = 0.0
	terminal_time = 0.0
	resolution_sent = false
	state = State.ENTERING
	queue_redraw()

func deactivate() -> void:
	state = State.OFFSCREEN
	resolution_sent = true
	set_process(false)
	queue_redraw()

func set_reduced_flash(enabled: bool) -> void:
	reduced_flash = enabled
	queue_redraw()

func try_hit(shot_position: Vector2) -> bool:
	if state != State.ENTERING and state != State.FLYING:
		return false
	if shot_position.distance_to(global_position) > HIT_RADIUS:
		return false
	_resolve_hit()
	return true

func _process(delta: float) -> void:
	match state:
		State.ENTERING, State.FLYING:
			flight_time += delta
			state = State.FLYING
			position += flight_velocity * delta
			if movement_pattern == "sine":
				position.y = base_y + sin(flight_time * 3.0) * 42.0
			if not playfield.grow(HIT_RADIUS).has_point(position):
				_resolve_escape()
		State.HIT, State.ESCAPING:
			terminal_time += delta
			if state == State.HIT:
				position.y += 110.0 * delta
			if terminal_time >= TERMINAL_ANIMATION_DURATION:
				state = State.OFFSCREEN
				terminal_animation_finished.emit(self)
	queue_redraw()

func _resolve_hit() -> void:
	if resolution_sent:
		return
	resolution_sent = true
	state = State.HIT
	terminal_time = 0.0
	resolved_hit.emit(self)

func _resolve_escape() -> void:
	if resolution_sent:
		return
	resolution_sent = true
	state = State.ESCAPING
	terminal_time = 0.0
	resolved_escape.emit(self)

func _draw() -> void:
	if state == State.OFFSCREEN:
		return
	var flap := sin(flight_time * 12.0) * 8.0
	var body_color := Color("31475e") if state != State.HIT else Color("ca5d58")
	draw_circle(Vector2.ZERO, 19.0, body_color)
	draw_circle(Vector2(21, -8), 12.0, Color("f0c15b"))
	draw_colored_polygon(PackedVector2Array([Vector2(-6, -4), Vector2(-34, -20 + flap), Vector2(-26, 11)]), Color("f4e3bf"))
	draw_colored_polygon(PackedVector2Array([Vector2(32, -7), Vector2(48, 0), Vector2(32, 5)]), Color("f08a45"))
	draw_circle(Vector2(25, -11), 2.5, Color("17212e"))
	if state == State.HIT and not reduced_flash:
		draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 12, Color("fff4b5"), 3.0)
