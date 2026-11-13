# Changelog

## 2026-11-13 — Uncommitted

### Added

- Data-driven configuration table for ten Classic Mode rounds.
- Game manager for high-level playing, round-clear, game-over, and run-complete state transitions.

### Changed

- Greybox HUD and spawn speed now follow the active round configuration.

### Tests

- Extended headless gameplay tests to verify the 10-round catalog and advancement after a round clear.

### Follow-up

- Implement lives, bonuses, menus/results, and multi-target waves.

## 2026-11-13 — `6297c59`, `7c45856`

### Added

- Focused `Duck`, `WeaponController`, `RunController`, and `RoundController` gameplay scripts.
- One-time duck hit/escape terminal transitions and terminal-animation completion before respawn.
- Round quota and escape accounting, plus controller-owned weapon reload and score counters.

### Changed

- Reworked the greybox scene to delegate gameplay ownership to the new controllers.

### Tests

- Passed Godot 4.7.2 headless import and two-second game-launch smoke test with no script errors.
- Passed headless gameplay logic tests for reload behavior, zero-shot accuracy, round outcomes, and duck terminal states.

### Follow-up

- Add data-driven rounds and high-level state transitions.

## 2026-11-13 — `b1deb71`

### Added

- Godot 4 project configuration with landscape viewport and pixel-friendly filtering.
- Main greybox scene and touch/click shooting prototype.
- Initial production folders and Godot/Android `.gitignore` entries.
- Current-state and changelog documentation required by project instructions.

### Tests

- Not run: the `godot`/`godot4` executable is not available from this shell.

### Follow-up

- Validate in Godot and on Android, then begin the M1 controller split.
