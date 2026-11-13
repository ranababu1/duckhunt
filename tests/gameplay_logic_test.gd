extends SceneTree

const DuckScript = preload("res://scripts/gameplay/duck.gd")
const WeaponControllerScript = preload("res://scripts/gameplay/weapon_controller.gd")
const RunControllerScript = preload("res://scripts/gameplay/run_controller.gd")
const RoundControllerScript = preload("res://scripts/gameplay/round_controller.gd")
const RoundCatalogScript = preload("res://scripts/data/round_catalog.gd")
const GameManagerScript = preload("res://scripts/core/game_manager.gd")
const ScoreServiceScript = preload("res://scripts/gameplay/score_service.gd")
const SaveServiceScript = preload("res://scripts/core/save_service.gd")
const InputControllerScript = preload("res://scripts/gameplay/input_controller.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_weapon_reload_rules()
	_test_accuracy_with_zero_shots()
	_test_round_outcomes()
	_test_duck_terminal_states()
	_test_sprite_animation_lifecycle()
	_test_duck_rerouting()
	_test_classic_round_progression()
	_test_finite_round_waves()
	_test_scoring_and_lives()
	_test_pause_navigation()
	_test_save_persistence()
	_test_input_coordinate_conversion()
	if failures.is_empty():
		print("PASS: gameplay logic tests")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_weapon_reload_rules() -> void:
	var weapon = WeaponControllerScript.new()
	weapon._ready()
	_assert(weapon.request_fire(Vector2.ZERO), "first shot should fire")
	_assert(weapon.request_fire(Vector2.ZERO), "second shot should fire")
	_assert(weapon.current_ammo == 0, "empty magazine should contain zero ammo")
	_assert(weapon.is_reloading, "empty magazine should start reload")
	_assert(not weapon.request_fire(Vector2.ZERO), "shot during reload must be rejected")
	_assert(weapon.current_ammo == 0, "rejected reload shot must not consume ammo")
	weapon._process(weapon.reload_duration)
	_assert(not weapon.is_reloading, "reload should finish after its duration")
	_assert(weapon.current_ammo == weapon.magazine_capacity, "reload should restore full ammo")
	weapon.free()

func _test_accuracy_with_zero_shots() -> void:
	var run = RunControllerScript.new()
	_assert(is_equal_approx(run.accuracy_percent(), 0.0), "zero shots must report zero accuracy")
	run.record_shot()
	run.record_hit(100)
	_assert(is_equal_approx(run.accuracy_percent(), 100.0), "one hit from one shot must report 100 percent")
	run.free()

func _test_round_outcomes() -> void:
	var cleared_round = RoundControllerScript.new()
	cleared_round.required_hits = 1
	_assert(is_equal_approx(cleared_round.accuracy_percent(), 0.0), "round accuracy should safely report zero before shots")
	cleared_round.register_shot()
	cleared_round.register_hit()
	_assert(cleared_round.is_finished, "hit quota should finish the round")
	_assert(cleared_round.round_hits == 1, "finished round must retain its hit count")
	_assert(is_equal_approx(cleared_round.accuracy_percent(), 100.0), "round accuracy should use only that round's shots")
	cleared_round.register_escape()
	_assert(cleared_round.escapes == 0, "finished round must ignore later escapes")
	cleared_round.free()

	var failed_round = RoundControllerScript.new()
	failed_round.allowed_escapes = 0
	failed_round.register_escape()
	_assert(failed_round.is_finished, "escape allowance exceeded should finish the round")
	failed_round.free()

func _test_duck_terminal_states() -> void:
	var duck = DuckScript.new()
	duck.start_flight(Vector2(120.0, 272.0), Rect2(0.0, 0.0, 960.0, 540.0), Vector2.ZERO)
	_assert(duck.try_hit(Vector2(120.0, 272.0)), "shot overlapping duck should hit")
	_assert(not duck.try_hit(Vector2(120.0, 272.0)), "hit duck must reject duplicate hits")
	duck._process(duck.TERMINAL_ANIMATION_DURATION)
	_assert(duck.state == duck.State.OFFSCREEN, "hit duck should finish terminal animation")

	duck.start_flight(Vector2(1000.0, 272.0), Rect2(0.0, 0.0, 960.0, 540.0), Vector2.ZERO)
	duck._process(0.01)
	_assert(duck.state == duck.State.ESCAPING, "offscreen flying duck should escape")
	_assert(not duck.try_hit(duck.position), "escaped duck must reject attempted hits")
	duck.deactivate()
	_assert(duck.state == duck.State.OFFSCREEN and not duck.try_hit(duck.position), "deactivated target must not move or accept hits")
	duck.free()

func _test_sprite_animation_lifecycle() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("hit")
	frames.set_animation_speed("hit", 10.0)
	for _index in 3:
		frames.add_frame("hit", PlaceholderTexture2D.new())
	var duck = DuckScript.new()
	duck.set_sprite_frames(frames)
	duck.start_flight(Vector2(120.0, 272.0), Rect2(0.0, 0.0, 960.0, 540.0), Vector2.ZERO)
	_assert(duck.try_hit(Vector2(120.0, 272.0)), "sprite-backed target should accept a valid hit")
	_assert(is_equal_approx(duck.terminal_animation_duration, 0.3), "terminal lifetime should match the supplied sprite animation")
	duck._process(0.29)
	_assert(duck.state == duck.State.HIT, "sprite-backed target should remain until its animation duration elapses")
	duck._process(0.02)
	_assert(duck.state == duck.State.OFFSCREEN, "sprite-backed target should retire after its animation completes")
	duck.free()

func _test_classic_round_progression() -> void:
	var configs: Array = RoundCatalogScript.classic_mode()
	_assert(configs.size() == 10, "classic mode must provide ten rounds")
	_assert(configs[0].round_number == 1 and configs[9].round_number == 10, "round numbers must span one through ten")
	_assert(configs[0].min_flight_speed >= 300.0, "first-round ducks should use the faster flight pace")
	_assert(configs[9].min_flight_speed > configs[0].min_flight_speed, "later rounds must increase flight speed")
	_assert(configs.all(func(config): return "zigzag" in config.movement_pattern_pool), "every round should allow instant zigzag course changes")
	var manager = GameManagerScript.new()
	manager.configure(configs)
	manager.start_run()
	_assert(manager.state == manager.State.PLAYING, "starting a configured run should enter playing state")
	manager.on_round_cleared()
	_assert(manager.state == manager.State.ROUND_CLEAR, "round clear should wait for player continuation")
	manager.continue_round()
	_assert(manager.current_round_index == 1, "cleared round should advance to the next round")
	for _round_index in 9:
		manager.on_round_cleared()
		manager.continue_round()
	_assert(manager.state == manager.State.RUN_COMPLETE, "clearing all ten rounds should complete the run")
	manager.free()

func _test_duck_rerouting() -> void:
	var duck = DuckScript.new()
	duck.start_flight(Vector2(480.0, 270.0), Rect2(-10000.0, 0.0, 20000.0, 540.0), Vector2(300.0, 0.0), "zigzag")
	duck._reroute_course()
	_assert(is_equal_approx(duck.flight_velocity.length(), 300.0), "instant course changes should preserve target speed")
	_assert(duck.reroute_remaining >= duck.REROUTE_MIN_SECONDS and duck.reroute_remaining <= duck.REROUTE_MAX_SECONDS, "reroutes should happen on a short interval")
	for _step in 20:
		duck._process(0.1)
		_assert(duck.position.y >= 26.0 and duck.position.y <= 514.0, "rerouting targets should stay inside the vertical playfield")
	_assert(duck.flight_speed >= 300.0, "flight speed should be retained through repeated course changes")
	duck.free()

func _test_finite_round_waves() -> void:
	var config = RoundCatalogScript.classic_mode()[0]
	var round = RoundControllerScript.new()
	var emitted_waves: Array[int] = []
	round.spawn_wave.connect(func(count: int) -> void: emitted_waves.append(count))
	round.start_round(config)
	_assert(emitted_waves == [1], "round should spawn the first configured wave")
	_assert(round.ducks_remaining_to_spawn == 2 and round.active_ducks == 1, "round should track finite remaining and active ducks")
	round.register_hit()
	round.register_terminal_animation_finished()
	round._process(config.spawn_interval)
	_assert(emitted_waves.size() == 2, "round should spawn the next duck after its interval and terminal animation")
	_assert(round.ducks_remaining_to_spawn == 1, "each wave should decrement the remaining duck count")
	round.register_hit()
	_assert(round.is_finished, "required quota should finish the finite round")
	round.free()
	var paired_round = RoundControllerScript.new()
	var paired_waves: Array[int] = []
	paired_round.spawn_wave.connect(func(count: int) -> void: paired_waves.append(count))
	paired_round.start_round(RoundCatalogScript.classic_mode()[6])
	_assert(paired_waves == [2], "later campaign rounds should spawn configured simultaneous pairs")
	paired_round.free()

func _test_scoring_and_lives() -> void:
	_assert(ScoreServiceScript.points_for_hit(0) == 100, "first hit must award standard points")
	_assert(ScoreServiceScript.points_for_hit(99) == 200, "combo bonus must be capped")
	_assert(ScoreServiceScript.round_clear_bonus(2, 100.0, 0) == 300, "clean, accurate round bonus should be applied")
	_assert(ScoreServiceScript.round_clear_bonus(1, 100.0, 1) == 225, "round with an escape must not receive the perfect-round bonus")
	_assert(ScoreServiceScript.round_clear_bonus(2, 50.0, 0) == 275, "round accuracy should contribute to its completion bonus")
	var run = RunControllerScript.new()
	run.reset_run()
	run.record_hit(ScoreServiceScript.points_for_hit(run.combo))
	run.record_hit(ScoreServiceScript.points_for_hit(run.combo))
	_assert(run.score == 225, "consecutive hits should receive a combo bonus")
	run.record_escape()
	_assert(run.combo == 0 and run.lives == 2, "escape should reset combo and consume one life")
	run.free()

func _test_pause_navigation() -> void:
	var manager = GameManagerScript.new()
	manager.configure(RoundCatalogScript.classic_mode())
	var started_rounds := [0]
	manager.round_started.connect(func(_config: Resource) -> void: started_rounds[0] += 1)
	manager.start_run()
	manager.pause_run()
	_assert(manager.state == manager.State.PAUSED, "pause request should enter paused state")
	manager.resume_run()
	_assert(manager.state == manager.State.PLAYING, "resume should restore playing state")
	_assert(started_rounds[0] == 1, "resume must not emit a duplicate round start")
	manager.return_to_title()
	_assert(manager.state == manager.State.MENU, "return-to-title request should enter menu state")
	manager.free()

func _test_save_persistence() -> void:
	var test_save_path := "/tmp/duckhunt_test_settings_%d.cfg" % OS.get_process_id()
	var expected_settings := {"music_volume": 0.35, "sfx_volume": 0.6, "haptics": false, "reduced_flash": true}
	_assert(SaveServiceScript.save_settings(expected_settings, test_save_path) == OK, "settings should save successfully")
	_assert(SaveServiceScript.load_settings(test_save_path) == expected_settings, "settings should survive a save/load cycle")
	_assert(SaveServiceScript.save_best_score(1200, test_save_path) == OK, "best score should save successfully")
	_assert(SaveServiceScript.save_best_score(900, test_save_path) == OK, "lower score should not replace the best")
	_assert(SaveServiceScript.load_best_score(test_save_path) == 1200, "best score should remain persistent and monotonic")
	var malformed_config := ConfigFile.new()
	_assert(malformed_config.load(test_save_path) == OK, "saved config should remain readable before corruption check")
	malformed_config.set_value("settings", "music_volume", NAN)
	_assert(is_equal_approx(SaveServiceScript._read_volume(malformed_config, "music_volume", 0.7), 0.7), "non-finite volume should fall back to its default")
	malformed_config.set_value("settings", "music_volume", "loud")
	malformed_config.set_value("settings", "haptics", "yes")
	_assert(malformed_config.save(test_save_path) == OK, "test should write malformed preference values")
	var recovered_settings: Dictionary = SaveServiceScript.load_settings(test_save_path)
	_assert(is_equal_approx(recovered_settings.music_volume, 0.7), "malformed volume should fall back to its default")
	_assert(recovered_settings.haptics, "malformed boolean preference should fall back to its default")
	_assert(SaveServiceScript.load_best_score(test_save_path) == 1200, "malformed preferences must not discard a valid best score")
	malformed_config.set_value("progress", "best_score", "many")
	_assert(malformed_config.save(test_save_path) == OK, "test should write a malformed best score")
	_assert(SaveServiceScript.load_best_score(test_save_path) == 0, "malformed best score should safely fall back to zero")
	if FileAccess.file_exists(test_save_path):
		var absolute_path := ProjectSettings.globalize_path(test_save_path)
		DirAccess.remove_absolute(absolute_path)

func _test_input_coordinate_conversion() -> void:
	var canvas_transform := Transform2D(0.0, Vector2(100.0, 50.0))
	var playfield_position := InputControllerScript.viewport_to_canvas(Vector2(420.0, 300.0), canvas_transform)
	_assert(playfield_position == Vector2(320.0, 250.0), "viewport touch should be converted through the inverse canvas transform")
	var scaled_transform := Transform2D(Vector2(2.0, 0.0), Vector2(0.0, 1.5), Vector2(100.0, 50.0))
	var scaled_viewport_position := scaled_transform * Vector2(320.0, 250.0)
	var scaled_playfield_position := InputControllerScript.viewport_to_canvas(scaled_viewport_position, scaled_transform)
	_assert(scaled_playfield_position.is_equal_approx(Vector2(320.0, 250.0)), "touch coordinate conversion should account for viewport scaling")

func _assert(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
