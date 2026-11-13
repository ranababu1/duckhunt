class_name AudioManager
extends Node

@export var menu_music: AudioStream
@export var gameplay_music: AudioStream
@export var shot_sound: AudioStream
@export var hit_sound: AudioStream
@export var miss_sound: AudioStream
@export var escape_sound: AudioStream
@export var reload_sound: AudioStream
@export var round_clear_sound: AudioStream
@export var game_over_sound: AudioStream
@export var button_sound: AudioStream

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var active_context := "menu"
var sfx_index := 0
var music_volume := 0.7
var sfx_volume := 0.8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music")
	_ensure_bus("SFX")
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.finished.connect(_loop_music)
	add_child(music_player)
	for _index in 4:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)
	apply_setting("music_volume", music_volume)
	apply_setting("sfx_volume", sfx_volume)
	set_context(active_context)

func apply_setting(key: String, value: Variant) -> void:
	if key == "music_volume":
		music_volume = clampf(float(value), 0.0, 1.0)
		_set_bus_volume("Music", music_volume)
	elif key == "sfx_volume":
		sfx_volume = clampf(float(value), 0.0, 1.0)
		_set_bus_volume("SFX", sfx_volume)

func set_context(context: String) -> void:
	active_context = context
	var desired_stream: AudioStream = menu_music if context == "menu" else gameplay_music
	if music_player.stream == desired_stream and music_player.playing:
		return
	music_player.stop()
	music_player.stream = desired_stream
	if desired_stream != null and music_volume > 0.0:
		music_player.play()

func play_event(event_name: String) -> void:
	var stream: AudioStream = _event_stream(event_name)
	if stream == null or sfx_volume <= 0.0:
		return
	var player := sfx_players[sfx_index]
	sfx_index = (sfx_index + 1) % sfx_players.size()
	player.stop()
	player.stream = stream
	player.play()

func _event_stream(event_name: String) -> AudioStream:
	match event_name:
		"shot": return shot_sound
		"hit": return hit_sound
		"miss": return miss_sound
		"escape": return escape_sound
		"reload": return reload_sound
		"round_clear": return round_clear_sound
		"game_over": return game_over_sound
		"button": return button_sound
	return null

func _loop_music() -> void:
	if music_player.stream != null and music_volume > 0.0:
		music_player.play()

func _ensure_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return index
	index = AudioServer.bus_count
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")
	return index

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_volume_linear(index, volume)
		AudioServer.set_bus_mute(index, volume <= 0.0)
