# Current State

**Updated:** 2026-11-13

## Milestone and status

M1 (Core shooting prototype) is in progress. The repository has a Godot 4 project and a controller-based greybox shooting range; Android/device validation remains outstanding.

## Branch and latest commit

- Branch: `main`
- Latest commit: `405fdac` (`Update implementation state`)

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching and nearest texture filtering.
- Original code-drawn greybox range with a moving target.
- Duck terminal-state handling that resolves a target exactly once as hit or escaped before respawn.
- Separate weapon, run, and round controllers for two-round magazines, automatic reload, counters, score, hit quota, and escape allowance.
- Tap/click shooting within the playfield with one-target-per-shot resolution and basic hit/miss/reload feedback.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- The presentation script remains a temporary M1 greybox; menus, persistence, audio, final assets, and full run state are not implemented.
- Round clear/failure is reported but does not yet transition screens or load the next data-driven round.
- No Android build/device test has been performed.

## Tests run

- Passed: Godot 4.7.2 headless project import.
- Passed: Godot 4.7.2 headless game launch for two seconds, with no parse or runtime errors after the controller split.
- Passed: headless gameplay logic tests for reload behavior, zero-shot accuracy, round completion/failure, and one-time duck terminal states.
- GUI smoke test was attempted, but the launched process did not remain visible for inspection in this environment.

## Current blockers

- An Android test device is not available in this environment.

## Exact next actions

1. Add data-driven round configurations and high-level run states for the remainder of M1/M2.
2. Add automated gameplay logic tests for weapon, duck terminal states, and round outcomes.
3. Verify touch input and safe bounds on a physical Android device.

## Decisions awaiting approval

- Public game title requires legal clearance; “Duck Hunt Arcade” remains a working title.
