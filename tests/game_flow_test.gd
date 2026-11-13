extends SceneTree

const MainScene = preload("res://scenes/main/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run_flow")

func _run_flow() -> void:
	var test_save_path := "/tmp/duckhunt_flow_test_%d.cfg" % OS.get_process_id()
	var main = MainScene.instantiate()
	main.save_path = test_save_path
	root.add_child(main)
	await process_frame
	_assert(main.art_assets != null, "main scene should expose an ArtAssetSet for future original art")
	_assert(main.art_assets.get("sky") == null, "empty art slots should preserve the geometric fallback")
	_assert(not main._draw_art_background(), "incomplete background layers should keep the geometric fallback")
	_assert(main.game_manager.state == main.game_manager.State.MENU, "game should open on title")
	_assert(main.ui.screens["title"].visible, "title screen should be visible on launch")
	for screen_name in ["title", "tutorial", "pause", "round_clear", "results", "settings"]:
		var card := main.ui.screens[screen_name].get_child(0) as PanelContainer
		var content := card.get_child(0) as VBoxContainer
		var required_height: float = content.get_combined_minimum_size().y
		_assert(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)).encloses(card.get_rect()), "%s panel should stay inside the base landscape viewport" % screen_name)
		_assert(required_height <= card.size.y - 44.0, "%s content should fit inside its panel" % screen_name)
	var title_text := ""
	for label in main.ui.screens["title"].find_children("*", "Label", true, false):
		title_text += label.text + " "
	_assert(title_text.contains("OPEN RANGE"), "placeholder title should remain visible when no logo is assigned")
	main.ui.tutorial_requested.emit()
	_assert(main.ui.screens["tutorial"].visible, "How to Play should open from the title screen")
	var tutorial_text := ""
	for label in main.ui.screens["tutorial"].find_children("*", "Label", true, false):
		tutorial_text += label.text + " "
	_assert(tutorial_text.contains("allowance") and tutorial_text.contains("run ends"), "tutorial should explain the round escape limit")
	main.ui.play_requested.emit()
	_assert(main.game_manager.state == main.game_manager.State.PLAYING, "Play should start a run")
	_assert(main.round.active_ducks == 1, "first round should spawn its opening target")
	_assert(main.ducks[0].placeholder_visible, "duck should use its geometric fallback until animation frames are assigned")
	_assert(main._hud_status_text() == "HITS 0/2   ESCAPES 0/2   LEFT 3   COMBO 0   LIVES 3", "HUD should show the current escape allowance and remaining targets")
	var duck = main.ducks[0]
	duck.position = Vector2(420.0, 280.0)
	var overlapping_duck = main.ducks[1]
	overlapping_duck.position = Vector2(428.0, 280.0)
	overlapping_duck.state = overlapping_duck.State.FLYING
	_assert(main._closest_target(Vector2(427.0, 280.0)) == overlapping_duck, "overlapping targets should select the closest hit area")
	overlapping_duck.deactivate()
	_assert(main.weapon.request_fire(duck.global_position), "weapon should accept the test shot")
	_assert(main.run.hits == 1 and main.run.score == 100, "shot should resolve through the main scene")
	_assert(main._hud_status_text().begins_with("HITS 1/2   ESCAPES 0/2   LEFT 2"), "HUD should update quota and remaining targets after a hit")
	duck._process(duck.TERMINAL_ANIMATION_DURATION)
	_assert(not duck.is_processing(), "retired target should stop processing after its terminal animation")
	main.round._process(main.round.spawn_interval)
	_assert(main.round.active_ducks == 1, "completed target should be replaced by the next scheduled target")
	main.ui.pause_requested.emit()
	_assert(main.game_manager.state == main.game_manager.State.PAUSED and paused, "pause should freeze the game tree")
	main.ui.show_settings()
	main.ui.back_from_settings()
	_assert(main.game_manager.state == main.game_manager.State.PAUSED, "returning from pause settings should remain paused")
	main.ui.resume_requested.emit()
	_assert(main.game_manager.state == main.game_manager.State.PLAYING and not paused, "resume should restore play")
	main._notification(main.NOTIFICATION_APPLICATION_PAUSED)
	_assert(main.game_manager.state == main.game_manager.State.PAUSED and paused, "backgrounding should automatically pause active play")
	main.ui.resume_requested.emit()
	main.run.record_shot()
	main.round.register_shot()
	main._on_duck_hit(null)
	_assert(main.game_manager.state == main.game_manager.State.ROUND_CLEAR, "meeting quota should enter round clear")
	_assert(main.ui.screens["round_clear"].visible and paused, "round clear should present its screen and freeze gameplay")
	main.ui.continue_requested.emit()
	_assert(main.game_manager.current_round_index == 1, "Continue should advance to round two")
	_assert(main.game_manager.state == main.game_manager.State.PLAYING and not paused, "next round should resume play")
	_assert(main.round.active_ducks == 1 and main.round.ducks_remaining_to_spawn == 2, "new round should reset finite wave state without stale targets")
	for _progression_step in 9:
		var quota_remaining: int = main.round.required_hits - main.round.round_hits
		for _hit_index in quota_remaining:
			main.run.record_shot()
			main.round.register_shot()
			main._on_duck_hit(null)
		if main.game_manager.state == main.game_manager.State.RUN_COMPLETE:
			break
		_assert(main.game_manager.state == main.game_manager.State.ROUND_CLEAR, "meeting each round quota should present the round-clear screen")
		main.ui.continue_requested.emit()
	_assert(main.game_manager.state == main.game_manager.State.RUN_COMPLETE, "prototype game should complete all ten rounds")
	_assert(main.ui.screens["results"].visible, "full ten-round run should present the results screen")
	_assert(main.ui.screens["results"].find_child("results_summary", true, false).text.contains("ROUNDS  10 / 10"), "complete-run results should report all ten rounds")
	paused = false
	main.queue_free()
	await process_frame
	var failed_game = MainScene.instantiate()
	failed_game.save_path = test_save_path
	root.add_child(failed_game)
	await process_frame
	failed_game.ui.play_requested.emit()
	failed_game.run.lives = 5
	failed_game._on_duck_escaped(null)
	failed_game._on_duck_escaped(null)
	_assert(failed_game.game_manager.state == failed_game.game_manager.State.PLAYING, "using the full escape allowance should not fail the round")
	failed_game._on_duck_escaped(null)
	_assert(failed_game.game_manager.state == failed_game.game_manager.State.GAME_OVER, "exceeding escape allowance should end the run even with lives remaining")
	_assert(failed_game.run.lives == 2 and failed_game.ui.screens["results"].visible, "escape-limit failure should preserve remaining lives and show results")
	paused = false
	failed_game.queue_free()
	await process_frame
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(test_save_path))
	if failures.is_empty():
		print("PASS: full game flow smoke test")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
