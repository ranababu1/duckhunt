class_name InputController
extends Node

signal shot_requested(playfield_position: Vector2)

@export var playfield := Rect2(24.0, 76.0, 912.0, 420.0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _unhandled_input(event: InputEvent) -> void:
	var viewport_position := Vector2.ZERO
	var is_shot := false
	if event is InputEventScreenTouch and event.pressed:
		viewport_position = event.position
		is_shot = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		viewport_position = event.position
		is_shot = true
	if not is_shot:
		return
	var playfield_position := viewport_to_canvas(viewport_position, get_viewport().get_canvas_transform())
	if playfield.has_point(playfield_position):
		shot_requested.emit(playfield_position)

static func viewport_to_canvas(viewport_position: Vector2, canvas_transform: Transform2D) -> Vector2:
	return canvas_transform.affine_inverse() * viewport_position
