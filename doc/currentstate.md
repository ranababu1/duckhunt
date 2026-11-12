# Current State

**Updated:** 2026-11-13

## Milestone and status

M0 (Project foundation) is in progress. The repository now has a Godot 4 project and a desktop-playable greybox prototype; Android/device validation remains outstanding.

## Branch and latest commit

- Branch: `main`
- Latest commit: none (repository has no commits yet)

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching and nearest texture filtering.
- Original code-drawn greybox range with a moving target.
- Tap/click shooting within the playfield, two-round magazine, automatic reload, and basic hit/miss counters.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- The prototype is a single temporary script, not the final M1 controller architecture.
- No Android build/device test, menus, persistence, audio, or final assets exist yet.
- The target loops rather than exercising escape/round rules.

## Tests run

- Not run: no Godot executable was detected in the shell environment.

## Current blockers

- Godot editor/headless executable and an Android test device are unavailable in this environment.

## Exact next actions

1. Open the project in Godot 4 and verify import, parse, and landscape rendering.
2. Verify touch input and safe bounds on a physical Android device.
3. Replace the M0 greybox script with separated duck, weapon, input, and run controllers for M1.

## Decisions awaiting approval

- Public game title requires legal clearance; “Duck Hunt Arcade” remains a working title.
