class_name ScoreService
extends RefCounted

const STANDARD_HIT_POINTS := 100
const COMBO_STEP_POINTS := 25
const MAX_COMBO_BONUS := 100
const ROUND_CLEAR_BASE_POINTS := 150
const ROUND_ACCURACY_BONUS_MAX := 50
const PERFECT_ROUND_BONUS := 50

static func points_for_hit(current_combo: int) -> int:
	return STANDARD_HIT_POINTS + mini(current_combo * COMBO_STEP_POINTS, MAX_COMBO_BONUS)

static func round_clear_bonus(remaining_escapes: int, accuracy_percent: float, round_escapes: int) -> int:
	var accuracy_bonus := roundi(clampf(accuracy_percent, 0.0, 100.0) * ROUND_ACCURACY_BONUS_MAX / 100.0)
	var bonus := ROUND_CLEAR_BASE_POINTS + maxi(remaining_escapes, 0) * 25 + accuracy_bonus
	if round_escapes == 0:
		bonus += PERFECT_ROUND_BONUS
	return bonus
