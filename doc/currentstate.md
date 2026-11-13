# Current State

**Updated:** 2026-11-13

## Milestone and status

M2 (Complete Classic Mode loop) is in progress. The repository has a controller-based greybox shooting range with a data-driven 10-round Classic Mode progression; Android/device validation remains outstanding.

## Branch and latest commit

- Branch: `main`
- Latest implementation commit: `c7cc901` (`Add scoring and run lives`)

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching and nearest texture filtering.
- Original code-drawn greybox range with a moving target.
- Duck terminal-state handling that resolves a target exactly once as hit or escaped before respawn.
- Separate weapon, run, and round controllers for two-round magazines, automatic reload, counters, score, hit quota, and escape allowance.
- Tap/click shooting within the playfield with one-target-per-shot resolution and basic hit/miss/reload feedback.
- A 10-round Classic Mode configuration catalog and a game manager that owns playing, round-clear, game-over, and run-complete transitions.
- Three run lives, capped combo scoring, and round-clear/perfect-round bonuses.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- The presentation script remains a temporary M1 greybox; menus, persistence, audio, final assets, and full run state are not implemented.
- Round transitions are greybox-only; results/menu screens and full multi-target waves are not implemented.
- No Android build/device test has been performed.

## Tests run

- Passed: Godot 4.7.2 headless project import.
- Passed: Godot 4.7.2 headless game launch for two seconds, with no parse or runtime errors after the controller split.
- Passed: headless gameplay logic tests for reload behavior, zero-shot accuracy, round completion/failure, one-time duck terminal states, 10-round progression, scoring, and lives.
- GUI smoke test was attempted, but the launched process did not remain visible for inspection in this environment.

## Current blockers

- An Android test device is not available in this environment.

## Exact next actions

1. Add results/menu screens to complete M2/M3 flow.
2. Add multi-target waves and movement-pattern execution.
3. Verify touch input and safe bounds on a physical Android device.

## Decisions awaiting approval

- Public game title requires legal clearance; “Duck Hunt Arcade” remains a working title.
