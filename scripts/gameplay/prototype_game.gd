extends Node2D

## M0 greybox: self-contained touch-to-shoot prototype.
## Gameplay values are intentionally grouped here until the M1 controllers exist.

const PLAYFIELD := Rect2(24.0, 76.0, 912.0, 420.0)
const MAGAZINE_SIZE := 2
const RELOAD_DURATION := 0.75
const DUCK_RADIUS := 26.0

var duck_position := Vector2(140.0, 260.0)
var duck_velocity := Vector2(180.0, 0.0)
var duck_is_active := true
var wing_time := 0.0
var ammo := MAGAZINE_SIZE
var is_reloading := false
var reload_remaining := 0.0
var shots_fired := 0
var hits := 0
var misses := 0
var feedback := "TAP THE DUCK"
var feedback_time := 0.0
var shot_marker := Vector2.ZERO
var shot_marker_time := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	wing_time += delta
	if duck_is_active:
		duck_position += duck_velocity * delta
		duck_position.y = 272.0 + sin(wing_time * 3.0) * 72.0
		if duck_position.x > PLAYFIELD.end.x + DUCK_RADIUS:
			duck_position.x = PLAYFIELD.position.x - DUCK_RADIUS
	elif not is_reloading:
		_respawn_duck()
	if is_reloading:
		reload_remaining -= delta
		if reload_remaining <= 0.0:
			is_reloading = false
			ammo = MAGAZINE_SIZE
			_show_feedback("RELOADED")
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
	if is_reloading:
		_show_feedback("RELOADING")
		return
	ammo -= 1
	shots_fired += 1
	shot_marker = shot_position
	shot_marker_time = 0.12
	if duck_is_active and shot_position.distance_to(duck_position) <= DUCK_RADIUS:
		duck_is_active = false
		hits += 1
		_show_feedback("HIT +100")
	else:
		misses += 1
		_show_feedback("MISS")
	if ammo == 0:
		is_reloading = true
		reload_remaining = RELOAD_DURATION

func _respawn_duck() -> void:
	duck_position = Vector2(PLAYFIELD.position.x - DUCK_RADIUS, 272.0)
	duck_is_active = true

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
	if duck_is_active:
		_draw_duck(duck_position)
	if shot_marker_time > 0.0:
		draw_arc(shot_marker, 18.0, 0.0, TAU, 16, Color("fff4b5"), 3.0)
	if feedback_time > 0.0:
		_draw_centered_text(feedback, Vector2(480.0, 122.0), 24, Color("fff4b5"))

func _draw_hud() -> void:
	draw_rect(Rect2(18, 14, 924, 50), Color("18334d"))
	_draw_text("SCORE %05d" % (hits * 100), Vector2(34, 47), 22, Color("fff4b5"))
	_draw_centered_text("GREYBOX RANGE", Vector2(480, 47), 18, Color("d9f0ff"))
	_draw_text("AMMO", Vector2(726, 47), 18, Color("fff4b5"))
	for index in MAGAZINE_SIZE:
		var bullet_color := Color("ffd35c") if index < ammo else Color("6d8291")
		draw_rect(Rect2(818 + index * 34, 27, 20, 20), bullet_color)
	if is_reloading:
		_draw_centered_text("RELOADING", Vector2(480, 520), 16, Color("fff4b5"))
	else:
		_draw_centered_text("HITS %d  MISSES %d  SHOTS %d" % [hits, misses, shots_fired], Vector2(480, 520), 16, Color("d9f0ff"))

func _draw_duck(center: Vector2) -> void:
	var flap := sin(wing_time * 12.0) * 8.0
	draw_circle(center, 19.0, Color("31475e"))
	draw_circle(center + Vector2(21, -8), 12.0, Color("f0c15b"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-6, -4), center + Vector2(-34, -20 + flap), center + Vector2(-26, 11)]), Color("f4e3bf"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(32, -7), center + Vector2(48, 0), center + Vector2(32, 5)]), Color("f08a45"))
	draw_circle(center + Vector2(25, -11), 2.5, Color("17212e"))

func _draw_text(text: String, position: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_centered_text(text: String, position: Vector2, font_size: int, color: Color) -> void:
	var width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_draw_text(text, position - Vector2(width * 0.5, 0.0), font_size, color)
