# Current State

**Updated:** 2026-11-13

## Milestone and status

M4 (Art, animation, and audio integration) is in progress. Gameplay, 10 rounds, menus, persistence, finite waves, and audio routing are implemented with replaceable greybox presentation; production assets and Android/device validation remain outstanding.

## Branch and latest commit

- Branch: `main`
- Latest commit: `1784f50` (`Record tutorial escape rule update`); art assignment slots are in progress.

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching and nearest texture filtering.
- Original code-drawn greybox range with a moving target.
- Duck terminal-state handling that resolves a target exactly once as hit or escaped before respawn.
- Retired targets stop processing after their terminal animation completes.
- Separate weapon, run, and round controllers for two-round magazines, automatic reload, counters, score, hit quota, and escape allowance.
- Tap/click shooting within the playfield with one-target-per-shot resolution and basic hit/miss/reload feedback.
- A 10-round Classic Mode configuration catalog and a game manager that owns playing, round-clear, game-over, and run-complete transitions.
- Three run lives, capped combo scoring, and round-clear/perfect-round bonuses.
- Gameplay HUD shows the active round's hit quota and escape allowance alongside combo and lives.
- Title screen, accessible tutorial, pause menu, return-to-title confirmation, round-clear continue screen, results/retry flow, and settings screen.
- Tutorial explains life loss, the per-round escape limit, automatic reload, and the hit quota.
- Title screen displays the locally saved best score; returning to title saves the run's current best.
- Local persistence for music/SFX volume, haptics, reduced-flash preference, and best score.
- Save-data loaders reject malformed preference types and retain safe defaults rather than coercing invalid values.
- Reduced-flash suppresses shot markers and hit sparks; optional haptics cover hits, misses, escapes, and round clears.
- Back/escape navigation for pause, settings, and tutorial; gameplay timers pause behind modal screens.
- Finite round duck counts, timed wave spawning, later-round simultaneous pairs, and sine/diagonal movement patterns.
- Closest-target shot resolution when hit areas overlap.
- Music and SFX buses with event playback hooks ready for provided original audio streams.
- Main scene exposes an `ArtAssetSet` resource for four background layers and named duck animation states, with geometric fallbacks until assets are assigned.
- App background/window focus loss automatically pauses active play, and remaining targets are retired when a new round starts.
- Dedicated input controller converts viewport taps through the inverse canvas transform and emits shots only for unhandled playfield touches.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- Presentation uses replaceable code-created art and UI; production art/audio assets have been deferred until provided.
- Audio playback hooks are connected but the project is silent until the original music and sound assets are supplied.
- Art and audio remain temporary/empty placeholders while waiting for the user-provided originals.
- The UI layout has only been headless-smoke-tested; native visual inspection did not complete in this environment.
- No Android build/device test has been performed.

## Tests run

- Passed: Godot 4.7.2 headless project import.
- Passed: Godot 4.7.2 headless game launch for two seconds, with no parse or runtime errors after the controller split.
- Passed: headless gameplay logic tests for reload behavior, zero-shot accuracy, round completion/failure, one-time duck terminal states, 10-round progression, scoring, and lives.
- Passed: pause/resume/title state checks and headless project launch after UI flow implementation.
- Passed: settings and high-score save/load cycle using an isolated temporary file that is removed after the test.
- Passed: malformed settings values fall back to defaults while a valid best score remains readable; malformed best score safely loads as zero.
- Passed: finite-wave spawn/count tests, explicit round continuation, and complete ten-round state progression.
- Passed: Godot headless project launch after audio bus and Android back-navigation integration.
- Passed: end-to-end headless flow from title through closest overlapping-target selection, shooting, pause/settings/resume, automatic background pause, round clear, and next-round reset.
- Passed: end-to-end flow checks confirm the HUD updates hit progress and displays escapes used versus allowed.
- Passed: end-to-end flow confirms the tutorial opens from title and explains the round escape limit.
- Passed: end-to-end flow confirms the main scene's art resource slot loads and incomplete art retains the geometric fallback.
- Passed: end-to-end flow confirms a retired target stops processing after its terminal animation.
- Passed: simultaneous-pair wave configuration and resume without duplicate round-start signals.
- Passed: viewport-to-canvas touch coordinate conversion using a non-zero canvas offset.
- GUI smoke test was attempted, but the launched process did not remain visible for inspection in this environment.

## Current blockers

- The agreed original art/audio files have not been supplied yet.
- No Android device or `adb` executable is available for physical-device validation.

## Exact next actions

1. Integrate the user-provided original art and audio files, assign them through the main scene's `AudioManager`, and update `assets.md`.
2. Prepare a legal-cleared package identity and Android export configuration after the product title is decided.
3. Verify touch input, pause/background behavior, and layouts on Android devices at common landscape ratios.

## Decisions awaiting approval

- Public game title requires legal clearance; “Duck Hunt Arcade” remains a working title.
- Android package identity and signing setup remain release decisions; signing secrets must stay local.
