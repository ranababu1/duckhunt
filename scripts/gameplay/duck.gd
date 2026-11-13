class_name Duck
extends Node2D

signal resolved_hit(duck: Node2D)
signal resolved_escape(duck: Node2D)
signal terminal_animation_finished(duck: Node2D)

enum State { ENTERING, FLYING, HIT, ESCAPING, OFFSCREEN }

const HIT_RADIUS := 26.0
const TERMINAL_ANIMATION_DURATION := 0.35
const REROUTE_MIN_SECONDS := 0.28
const REROUTE_MAX_SECONDS := 0.55

var state := State.ENTERING
var flight_velocity := Vector2(180.0, 0.0)
var playfield := Rect2(24.0, 76.0, 912.0, 420.0)
var flight_time := 0.0
var flight_speed := 180.0
var reroute_remaining := 0.0
var terminal_time := 0.0
var terminal_animation_duration := TERMINAL_ANIMATION_DURATION
var resolution_sent := false
var movement_pattern := "sine"
var base_y := 272.0
var reduced_flash := false
var visual_frames: SpriteFrames
var animated_visual: AnimatedSprite2D
var placeholder_visible := true
var hit_effect_texture: Texture2D

func set_sprite_frames(frames: SpriteFrames) -> void:
	visual_frames = frames
	if visual_frames == null:
		return
	animated_visual = AnimatedSprite2D.new()
	animated_visual.name = "AnimatedVisual"
	animated_visual.sprite_frames = visual_frames
	animated_visual.visible = false
	add_child(animated_visual)

func set_hit_effect_texture(texture: Texture2D) -> void:
	hit_effect_texture = texture

func start_flight(start_position: Vector2, new_playfield: Rect2, new_velocity: Vector2, new_pattern := "sine") -> void:
	position = start_position
	playfield = new_playfield
	flight_velocity = new_velocity
	flight_speed = new_velocity.length()
	reroute_remaining = randf_range(REROUTE_MIN_SECONDS, REROUTE_MAX_SECONDS)
	base_y = start_position.y
	movement_pattern = new_pattern
	flight_time = 0.0
	terminal_time = 0.0
	terminal_animation_duration = TERMINAL_ANIMATION_DURATION
	resolution_sent = false
	state = State.ENTERING
	_play_visual_animation("fly")
	queue_redraw()

func deactivate() -> void:
	state = State.OFFSCREEN
	resolution_sent = true
	set_process(false)
	if animated_visual != null:
		animated_visual.visible = false
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
			if movement_pattern == "sine":
				position += flight_velocity * delta
				position.y = base_y + sin(flight_time * 3.0) * 42.0
			else:
				reroute_remaining -= delta
				if reroute_remaining <= 0.0:
					_reroute_course()
				position += flight_velocity * delta
				var top_edge := playfield.position.y + HIT_RADIUS
				var bottom_edge := playfield.end.y - HIT_RADIUS
				if position.y < top_edge:
					position.y = top_edge
					_reroute_course(1.0)
				elif position.y > bottom_edge:
					position.y = bottom_edge
					_reroute_course(-1.0)
			if not playfield.grow(HIT_RADIUS).has_point(position):
				_resolve_escape()
		State.HIT, State.ESCAPING:
			terminal_time += delta
			if state == State.HIT:
				position.y += 110.0 * delta
			if terminal_time >= terminal_animation_duration:
				state = State.OFFSCREEN
				set_process(false)
				if animated_visual != null:
					animated_visual.visible = false
				terminal_animation_finished.emit(self)
	queue_redraw()

func _reroute_course(vertical_direction := 0.0) -> void:
	var horizontal_direction := signf(flight_velocity.x)
	if randf() < 0.32:
		horizontal_direction *= -1.0
	var vertical_angle := randf_range(-0.88, 0.88)
	if vertical_direction != 0.0:
		vertical_angle = absf(vertical_angle) * signf(vertical_direction)
	flight_velocity = Vector2(horizontal_direction * cos(vertical_angle), sin(vertical_angle)) * flight_speed
	scale.x = horizontal_direction
	reroute_remaining = randf_range(REROUTE_MIN_SECONDS, REROUTE_MAX_SECONDS)

func _resolve_hit() -> void:
	if resolution_sent:
		return
	resolution_sent = true
	state = State.HIT
	terminal_time = 0.0
	_play_visual_animation("hit")
	resolved_hit.emit(self)

func _resolve_escape() -> void:
	if resolution_sent:
		return
	resolution_sent = true
	state = State.ESCAPING
	terminal_time = 0.0
	_play_visual_animation("escape")
	resolved_escape.emit(self)

func _play_visual_animation(animation_name: String) -> void:
	var has_animation := visual_frames != null and visual_frames.has_animation(animation_name) and visual_frames.get_frame_count(animation_name) > 0
	placeholder_visible = not has_animation
	if animated_visual == null:
		return
	if animation_name == "hit" or animation_name == "escape":
		terminal_animation_duration = TERMINAL_ANIMATION_DURATION
		if has_animation:
			var animation_speed := visual_frames.get_animation_speed(animation_name)
			if animation_speed > 0.0:
				var animation_ticks := 0.0
				for frame_index in visual_frames.get_frame_count(animation_name):
					animation_ticks += visual_frames.get_frame_duration(animation_name, frame_index)
				terminal_animation_duration = animation_ticks / animation_speed
	animated_visual.visible = has_animation
	if has_animation:
		animated_visual.play(animation_name)

func _draw() -> void:
	if state == State.OFFSCREEN:
		return
	if state == State.HIT and not reduced_flash and hit_effect_texture != null:
		draw_texture_rect(hit_effect_texture, Rect2(Vector2(-32.0, -32.0), Vector2(64.0, 64.0)), false)
	if not placeholder_visible:
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
