class_name WeaponController
extends Node

signal ammo_changed(current_ammo: int, capacity: int)
signal shot_fired(shot_position: Vector2)
signal reload_started()
signal reload_finished()

@export var magazine_capacity := 2
@export var reload_duration := 0.75

var current_ammo := 2
var is_reloading := false
var reload_remaining := 0.0

func _ready() -> void:
	current_ammo = magazine_capacity
	ammo_changed.emit(current_ammo, magazine_capacity)

func request_fire(shot_position: Vector2) -> bool:
	if is_reloading:
		return false
	if current_ammo <= 0:
		_start_reload()
		return false
	current_ammo -= 1
	ammo_changed.emit(current_ammo, magazine_capacity)
	shot_fired.emit(shot_position)
	if current_ammo == 0:
		_start_reload()
	return true

func _process(delta: float) -> void:
	if not is_reloading:
		return
	reload_remaining -= delta
	if reload_remaining <= 0.0:
		is_reloading = false
		current_ammo = magazine_capacity
		ammo_changed.emit(current_ammo, magazine_capacity)
		reload_finished.emit()

func _start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_remaining = reload_duration
	reload_started.emit()
