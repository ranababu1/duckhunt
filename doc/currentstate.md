# Current State

**Updated:** 2026-11-13

## Milestone and status

M3 (Menus, UX, and persistence) is in progress. The game now starts at a title screen and includes tutorial, pause, round-clear, results, and settings flows. Android/device validation remains outstanding.

## Branch and latest commit

- Branch: `main`
- Latest implementation commit: pending commit for M3 UI and persistence flow.

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching and nearest texture filtering.
- Original code-drawn greybox range with a moving target.
- Duck terminal-state handling that resolves a target exactly once as hit or escaped before respawn.
- Separate weapon, run, and round controllers for two-round magazines, automatic reload, counters, score, hit quota, and escape allowance.
- Tap/click shooting within the playfield with one-target-per-shot resolution and basic hit/miss/reload feedback.
- A 10-round Classic Mode configuration catalog and a game manager that owns playing, round-clear, game-over, and run-complete transitions.
- Three run lives, capped combo scoring, and round-clear/perfect-round bonuses.
- Title screen, accessible tutorial, pause menu, return-to-title confirmation, round-clear continue screen, results/retry flow, and settings screen.
- Local persistence for music/SFX volume, haptics, reduced-flash preference, and best score.
- Back/escape navigation for pause, settings, and tutorial; gameplay timers pause behind modal screens.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- Presentation uses replaceable code-created art and UI; production art/audio assets have been deferred until provided.
- Music and SFX volume values persist, but audio playback integration is deferred until original audio assets are supplied.
- Round transitions are greybox-only; results/menu screens and full multi-target waves are not implemented.
- No Android build/device test has been performed.

## Tests run

- Passed: Godot 4.7.2 headless project import.
- Passed: Godot 4.7.2 headless game launch for two seconds, with no parse or runtime errors after the controller split.
- Passed: headless gameplay logic tests for reload behavior, zero-shot accuracy, round completion/failure, one-time duck terminal states, 10-round progression, scoring, and lives.
- Passed: pause/resume/title state checks and headless project launch after UI flow implementation.
- Passed: settings and high-score save/load cycle using an isolated temporary file that is removed after the test.
- GUI smoke test was attempted, but the launched process did not remain visible for inspection in this environment.

## Current blockers

- An Android test device is not available in this environment.

## Exact next actions

1. Implement simultaneous targets/waves and configured movement patterns.
2. Connect audio buses and event playback, ready for provided audio assets.
3. Verify touch input and safe bounds on physical Android devices and common landscape ratios.

## Decisions awaiting approval

- Public game title requires legal clearance; “Duck Hunt Arcade” remains a working title.
