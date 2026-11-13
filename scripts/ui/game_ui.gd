extends CanvasLayer

signal play_requested()
signal pause_requested()
signal resume_requested()
signal restart_requested()
signal return_title_requested()
signal continue_requested()
signal tutorial_requested()
signal settings_requested()
signal settings_closed()
signal setting_changed(key: String, value: Variant)
signal ui_action()

const SCREEN_SIZE := Vector2(960.0, 540.0)
const SaveServiceScript = preload("res://scripts/core/save_service.gd")

var root: Control
var screens: Dictionary = {}
var settings: Dictionary = {}
var custom_theme: Theme
var settings_return_screen := "title"
var title_confirm_visible := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = SaveServiceScript.load_settings()
	root = Control.new()
	root.name = "Overlay"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = custom_theme
	add_child(root)
	_create_title()
	_create_tutorial()
	_create_pause()
	_create_round_clear()
	_create_results()
	_create_settings()
	_create_gameplay_hud()
	_show("title")

func show_title(best_score: int = 0) -> void:
	title_confirm_visible = false
	_set_label("title_best", "BEST SCORE  %06d" % best_score)
	_show("title")

func show_tutorial() -> void:
	_show("tutorial")

func show_pause() -> void:
	title_confirm_visible = false
	_set_title_confirmation(false)
	_show("pause")

func show_settings() -> void:
	settings_return_screen = _visible_screen()
	_show("settings")

func back_from_settings() -> void:
	SaveServiceScript.save_settings(settings)
	_show(settings_return_screen)

func show_gameplay() -> void:
	_show("gameplay")

func show_round_clear(round_number: int, score: int) -> void:
	_set_label("round_clear_summary", "ROUND %d COMPLETE   SCORE %06d" % [round_number, score])
	_show("round_clear")

func show_results(title: String, score: int, best_score: int, rounds: int, shots: int, hits: int, accuracy: float) -> void:
	_set_label("results_heading", title)
	_set_label("results_summary", "SCORE  %06d     BEST  %06d\nROUNDS  %d / 10\nSHOTS  %d     HITS  %d     ACCURACY  %0.1f%%" % [score, best_score, rounds, shots, hits, accuracy])
	_show("results")

func current_settings() -> Dictionary:
	return settings.duplicate(true)

func _create_title() -> void:
	var panel := _make_screen("title", "OPEN RANGE", "A quick arcade shooting game", "title_best")
	_add_button(panel, "PLAY CLASSIC", func() -> void: play_requested.emit())
	_add_button(panel, "HOW TO PLAY", func() -> void: tutorial_requested.emit())
	_add_button(panel, "SETTINGS", func() -> void: _open_settings())

func _create_tutorial() -> void:
	var panel := _make_screen("tutorial", "HOW TO PLAY", "Tap in the field to fire. Hits earn points.\nEscapes cost a life; exceed this round's allowance and the run ends.\nTwo shots per magazine, then automatic reload.\nHit the quota before all targets are gone.")
	_add_button(panel, "PLAY", func() -> void: play_requested.emit())
	_add_button(panel, "BACK", func() -> void: _show("title"))

func _create_pause() -> void:
	var panel := _make_screen("pause", "PAUSED", "Take a breather. The range is waiting.")
	panel.get_child(0).size = Vector2(460.0, 500.0)
	panel.get_child(0).position = Vector2(250.0, 20.0)
	_add_button(panel, "RESUME", func() -> void: resume_requested.emit())
	_add_button(panel, "RESTART RUN", func() -> void: restart_requested.emit())
	_add_button(panel, "SETTINGS", func() -> void: _open_settings())
	_add_button(panel, "RETURN TO TITLE", func() -> void: _set_title_confirmation(true))
	_add_button(panel, "END RUN AND RETURN", func() -> void:
		title_confirm_visible = false
		return_title_requested.emit()
	)
	_add_button(panel, "KEEP PLAYING", func() -> void: _set_title_confirmation(false))
	_set_title_confirmation(false)

func _create_round_clear() -> void:
	var panel := _make_screen("round_clear", "NICE SHOOTING!", "", "round_clear_summary")
	_add_button(panel, "NEXT ROUND", func() -> void: continue_requested.emit())

func _create_results() -> void:
	var panel := _make_screen("results", "RUN COMPLETE", "", "results_summary")
	_add_button(panel, "PLAY AGAIN", func() -> void: play_requested.emit())
	_add_button(panel, "TITLE", func() -> void: return_title_requested.emit())

func _create_settings() -> void:
	var panel := _make_screen("settings", "SETTINGS", "")
	_add_slider(panel, "Music volume", "music_volume")
	_add_slider(panel, "Sound effects", "sfx_volume")
	_add_toggle(panel, "Haptics", "haptics")
	_add_toggle(panel, "Reduced flashes", "reduced_flash")
	_add_button(panel, "BACK", func() -> void:
		SaveServiceScript.save_settings(settings)
		settings_closed.emit()
		_show(settings_return_screen)
	)

func _create_gameplay_hud() -> void:
	var overlay := Control.new()
	overlay.name = "gameplay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	screens["gameplay"] = overlay
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(886, 75)
	pause_button.size = Vector2(54, 48)
	pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if custom_theme == null:
		pause_button.add_theme_font_size_override("font_size", 26)
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	pause_button.pressed.connect(func() -> void: ui_action.emit())
	overlay.add_child(pause_button)

func _make_screen(screen_id: String, heading: String, subtitle: String, detail_name := "") -> Control:
	var dim := ColorRect.new()
	dim.name = screen_id
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.035, 0.09, 0.14, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(dim)
	screens[screen_id] = dim
	var card := PanelContainer.new()
	card.position = Vector2(250.0, 50.0)
	card.size = Vector2(460.0, 440.0)
	if custom_theme == null:
		card.add_theme_stylebox_override("panel", _panel_style())
	dim.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(content)
	var title := _label(heading, 32, Color("fff0b0"))
	if screen_id == "results":
		title.name = "results_heading"
	content.add_child(title)
	if not subtitle.is_empty():
		var subtitle_label := _label(subtitle, 20, Color("dbedf5"))
		subtitle_label.custom_minimum_size = Vector2(400, 100)
		subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(subtitle_label)
	if not detail_name.is_empty():
		var detail := _label("", 18, Color("fff0b0"))
		detail.name = detail_name
		detail.custom_minimum_size = Vector2(400, 100)
		content.add_child(detail)
	return dim

func _add_button(panel: Control, text: String, callback: Callable) -> void:
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(340.0, 44.0)
	if custom_theme == null:
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_color_override("font_color", Color("18334d"))
		button.add_theme_stylebox_override("normal", _button_style(Color("f0c15b")))
		button.add_theme_stylebox_override("hover", _button_style(Color("ffe49a")))
		button.add_theme_stylebox_override("pressed", _button_style(Color("d99545")))
	button.pressed.connect(callback)
	button.pressed.connect(func() -> void: ui_action.emit())
	content.add_child(button)

func _add_slider(panel: Control, title: String, key: String) -> void:
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	content.add_child(_label(title, 18, Color("dbedf5")))
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(330, 28)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(settings[key])
	slider.value_changed.connect(func(value: float) -> void:
		settings[key] = value
		SaveServiceScript.save_settings(settings)
		setting_changed.emit(key, value)
	)
	content.add_child(slider)

func _add_toggle(panel: Control, title: String, key: String) -> void:
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	var toggle := CheckButton.new()
	toggle.text = title
	toggle.button_pressed = bool(settings[key])
	toggle.add_theme_font_size_override("font_size", 18)
	toggle.toggled.connect(func(enabled: bool) -> void:
		settings[key] = enabled
		SaveServiceScript.save_settings(settings)
		setting_changed.emit(key, enabled)
	)
	content.add_child(toggle)

func _set_title_confirmation(visible: bool) -> void:
	title_confirm_visible = visible
	for button in (screens["pause"].get_child(0).get_child(0) as VBoxContainer).get_children():
		if button is Button and button.text in ["RETURN TO TITLE", "END RUN AND RETURN", "KEEP PLAYING"]:
			button.visible = (button.text == "END RUN AND RETURN" or button.text == "KEEP PLAYING") if visible else button.text == "RETURN TO TITLE"

func _open_settings() -> void:
	settings_return_screen = _visible_screen()
	settings_requested.emit()
	_show("settings")

func _visible_screen() -> String:
	for key in screens:
		if screens[key].visible:
			return key
	return "title"

func _set_label(label_name: String, text: String) -> void:
	for screen in screens.values():
		var label := screen.find_child(label_name, true, false) as Label
		if label != null:
			label.text = text
			return

func _show(screen_id: String) -> void:
	for key in screens:
		screens[key].visible = key == screen_id

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("18334d")
	style.border_color = Color("f0c15b")
	style.set_border_width_all(4)
	style.set_corner_radius_all(4)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	return style

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_border_width_all(2)
	style.border_color = Color("fff0b0")
	style.set_corner_radius_all(3)
	return style
