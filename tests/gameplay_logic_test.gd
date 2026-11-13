extends SceneTree

const DuckScript = preload("res://scripts/gameplay/duck.gd")
const WeaponControllerScript = preload("res://scripts/gameplay/weapon_controller.gd")
const RunControllerScript = preload("res://scripts/gameplay/run_controller.gd")
const RoundControllerScript = preload("res://scripts/gameplay/round_controller.gd")
const RoundCatalogScript = preload("res://scripts/data/round_catalog.gd")
const GameManagerScript = preload("res://scripts/core/game_manager.gd")
const ScoreServiceScript = preload("res://scripts/gameplay/score_service.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_weapon_reload_rules()
	_test_accuracy_with_zero_shots()
	_test_round_outcomes()
	_test_duck_terminal_states()
	_test_classic_round_progression()
	_test_scoring_and_lives()
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
	cleared_round.register_hit()
	_assert(cleared_round.is_finished, "hit quota should finish the round")
	_assert(cleared_round.round_hits == 1, "finished round must retain its hit count")
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
	duck.free()

func _test_classic_round_progression() -> void:
	var configs: Array = RoundCatalogScript.classic_mode()
	_assert(configs.size() == 10, "classic mode must provide ten rounds")
	_assert(configs[0].round_number == 1 and configs[9].round_number == 10, "round numbers must span one through ten")
	_assert(configs[9].min_flight_speed > configs[0].min_flight_speed, "later rounds must increase flight speed")
	var manager = GameManagerScript.new()
	manager.configure(configs)
	manager.start_run()
	_assert(manager.state == manager.State.PLAYING, "starting a configured run should enter playing state")
	manager.on_round_cleared()
	manager._process(manager.ROUND_TRANSITION_DURATION)
	_assert(manager.current_round_index == 1, "cleared round should advance to the next round")
	manager.free()

func _test_scoring_and_lives() -> void:
	_assert(ScoreServiceScript.points_for_hit(0) == 100, "first hit must award standard points")
	_assert(ScoreServiceScript.points_for_hit(99) == 200, "combo bonus must be capped")
	_assert(ScoreServiceScript.round_clear_bonus(2, 100.0) == 300, "perfect round bonus should be applied")
	var run = RunControllerScript.new()
	run.reset_run()
	run.record_hit(ScoreServiceScript.points_for_hit(run.combo))
	run.record_hit(ScoreServiceScript.points_for_hit(run.combo))
	_assert(run.score == 225, "consecutive hits should receive a combo bonus")
	run.record_escape()
	_assert(run.combo == 0 and run.lives == 2, "escape should reset combo and consume one life")
	run.free()

func _assert(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
