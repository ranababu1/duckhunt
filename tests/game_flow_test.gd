extends SceneTree

const MainScene = preload("res://scenes/main/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run_flow")

func _run_flow() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	_assert(main.game_manager.state == main.game_manager.State.MENU, "game should open on title")
	_assert(main.ui.screens["title"].visible, "title screen should be visible on launch")
	main.ui.play_requested.emit()
	_assert(main.game_manager.state == main.game_manager.State.PLAYING, "Play should start a run")
	_assert(main.round.active_ducks == 1, "first round should spawn its opening target")
	_assert(main._hud_status_text() == "HITS 0/2   ESCAPES 0/2   COMBO 0   LIVES 3", "HUD should show the current escape allowance")
	var duck = main.ducks[0]
	duck.position = Vector2(420.0, 280.0)
	var overlapping_duck = main.ducks[1]
	overlapping_duck.position = Vector2(428.0, 280.0)
	overlapping_duck.state = overlapping_duck.State.FLYING
	_assert(main._closest_target(Vector2(427.0, 280.0)) == overlapping_duck, "overlapping targets should select the closest hit area")
	overlapping_duck.deactivate()
	_assert(main.weapon.request_fire(duck.global_position), "weapon should accept the test shot")
	_assert(main.run.hits == 1 and main.run.score == 100, "shot should resolve through the main scene")
	_assert(main._hud_status_text().begins_with("HITS 1/2   ESCAPES 0/2"), "HUD should update hit quota after a successful shot")
	duck._process(duck.TERMINAL_ANIMATION_DURATION)
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
	main.round.register_hit()
	_assert(main.game_manager.state == main.game_manager.State.ROUND_CLEAR, "meeting quota should enter round clear")
	_assert(main.ui.screens["round_clear"].visible and paused, "round clear should present its screen and freeze gameplay")
	main.ui.continue_requested.emit()
	_assert(main.game_manager.current_round_index == 1, "Continue should advance to round two")
	_assert(main.game_manager.state == main.game_manager.State.PLAYING and not paused, "next round should resume play")
	_assert(main.round.active_ducks == 1 and main.round.ducks_remaining_to_spawn == 2, "new round should reset finite wave state without stale targets")
	paused = false
	main.queue_free()
	await process_frame
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
