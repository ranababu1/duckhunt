# Current State

**Updated:** 2026-11-13

## Milestone and status

M5 (Android MVP polish) is in progress. Gameplay, 10 rounds, menus, persistence, finite waves, original background/target/effect art, an arcade UI theme, synthesized music/effects, and a signed local Android debug export are implemented. Final branding and physical-device QA remain outstanding.

## Branch and latest commit

- Branch: `main`
- Latest implementation commit: pending commit for faster duck movement and package ID update.

## Implemented features

- Landscape 960 x 540 Godot project configuration with canvas-item stretching, nearest texture filtering, and Android ETC2/ASTC texture import enabled.
- Android debug export preset using the user-provided package ID `dev.imrn.duckhunter`; app label is `Open Range (Development)` while public naming is pending clearance.
- Android debug build version is `0.1.0-dev` (version code 1); increment the code before each store release upload.
- Locally installed Android SDK, JDK 17, and API 35 Pixel 6 emulator; Godot's local debug keystore is outside the repository.
- Original pixel-art daytime range background integrated through the replaceable `ArtAssetSet.background` slot; separate parallax-layer slots remain available for future supplied art.
- Original no-text development app icon assigned to Godot and the Android debug preset; public store branding remains provisional.
- Original range background is configured as the engine boot splash with nearest-neighbor scaling.
- Original 64 × 48 pixel-grid duck fly/hit/escape sprites, shot-flash/hit-spark effects, and a rectangular arcade Theme, assigned through the existing art resource.
- Original menu/gameplay chiptune loops and eight sound effects, generated deterministically from `tools/generate_audio.py` using only Python's standard library and wired into the scene's `AudioManager`.
- Original pixel-art target and feedback animation, with code-drawn fallbacks retained for unassigned resources.
- Faster duck flights ramp from 300 to 435 logical pixels/second across the 10 rounds, with instantaneous randomized course changes every 0.28–0.55 seconds.
- Duck terminal-state handling that resolves a target exactly once as hit or escaped before respawn.
- Retired targets stop processing after their terminal animation completes.
- Hit/escape target lifetime follows assigned SpriteFrames timing, with a 0.35 second placeholder fallback.
- Separate weapon, run, and round controllers for two-round magazines, automatic reload, counters, score, hit quota, and escape allowance.
- Tap/click shooting within the playfield with one-target-per-shot resolution and basic hit/miss/reload feedback.
- A 10-round Classic Mode configuration catalog and a game manager that owns playing, round-clear, game-over, and run-complete transitions.
- Three run lives, capped combo scoring, and round-clear/perfect-round bonuses.
- Gameplay HUD shows the active round's hit quota, escape allowance, and remaining targets alongside combo and lives.
- Round-clear bonuses use that round's shot accuracy, unused escape allowance, and a perfect-round bonus only when no targets escaped.
- Title screen, accessible tutorial, pause menu, return-to-title confirmation, round-clear continue screen, results/retry flow, and settings screen.
- Tutorial explains life loss, the per-round escape limit, automatic reload, and the hit quota.
- Title screen displays the locally saved best score; returning to title saves the run's current best.
- Local persistence for music/SFX volume, haptics, reduced-flash preference, and best score.
- Save-data loaders reject malformed preference types and retain safe defaults rather than coercing invalid values.
- Game and UI save paths are configurable; integration flow tests use a temporary file instead of modifying player data.
- Reduced-flash suppresses shot markers and hit sparks; optional haptics cover hits, misses, escapes, and round clears.
- Back/escape navigation for pause, settings, and tutorial; gameplay timers pause behind modal screens.
- Finite round duck counts, timed wave spawning, later-round simultaneous pairs, and sine/diagonal movement patterns.
- Closest-target shot resolution when hit areas overlap.
- Music and SFX buses with event playback hooks ready for provided original audio streams.
- Main scene exposes an `ArtAssetSet` resource for four background layers and named duck animation states, with geometric fallbacks until assets are assigned.
- Assigned art sets can supply an optional Godot Theme for menu and HUD control styling.
- Art sets also accept optional shot-flash and hit-spark textures, with existing effects retained as fallbacks and reduced-flash respected.
- Art sets accept an optional title-logo texture that replaces the working-title text while retaining it as a fallback.
- App background/window focus loss automatically pauses active play, and remaining targets are retired when a new round starts.
- Dedicated input controller converts viewport taps through the inverse canvas transform and emits shots only for unhandled playfield touches.
- Initial Godot-oriented folder layout and ignore rules.

## Known limitations

- Presentation uses original project art and audio, which remain replaceable by the user's final asset pack.
- No Android handset has been tested; the local Pixel emulator is the current Android device check.

## Tests run

- Passed: Godot 4.7.2 headless project import.
- Passed: Godot 4.7.2 headless game launch for two seconds, with no parse or runtime errors after the controller split.
- Passed: headless gameplay logic tests for reload behavior, zero-shot accuracy, round completion/failure, one-time duck terminal states, 10-round progression, scoring, and lives.
- Passed: sprite-backed duck test confirms terminal lifetime matches three 10 FPS animation frames before retirement.
- Passed: pause/resume/title state checks and headless project launch after UI flow implementation.
- Passed: settings and high-score save/load cycle using an isolated temporary file that is removed after the test.
- Passed: malformed settings values fall back to defaults while a valid best score remains readable; malformed best score safely loads as zero.
- Passed: NaN volume values fall back to a finite default before audio bus application.
- Passed: finite-wave spawn/count tests, explicit round continuation, and complete ten-round state progression.
- Passed: Godot headless project launch after audio bus and Android back-navigation integration.
- Passed: end-to-end headless flow from title through closest overlapping-target selection, shooting, pause/settings/resume, automatic background pause, round clear, and next-round reset.
- Passed: end-to-end prototype flow completes the configured quotas across all ten rounds and presents results with `10 / 10` rounds cleared.
- Passed: complete game-flow tests isolate settings and best-score writes to a temporary save file and remove it after the run.
- Passed: end-to-end flow confirms exceeding a round's escape allowance ends the run even when lives remain, while using the allowance itself is permitted.
- Passed: scoring checks cover round-local accuracy, the accuracy-scaled clear bonus, and suppression of the perfect bonus after an escape.
- Passed: end-to-end flow checks confirm the HUD updates hit progress and displays escapes used versus allowed.
- Passed: end-to-end flow confirms the remaining-target count decreases after a hit.
- Passed: end-to-end flow confirms the tutorial opens from title and explains the round escape limit.
- Passed: end-to-end flow confirms the main scene loads its configured full-scene background resource.
- Passed: generated menu panels and their content fit within their panel bounds and the 960×540 base viewport.
- Passed: end-to-end flow confirms a retired target stops processing after its terminal animation.
- Passed: simultaneous-pair wave configuration and resume without duplicate round-start signals.
- Passed: viewport-to-canvas touch coordinate conversion with translation and non-uniform scaling.
- Passed: the game-flow test loads the configured original full-scene background texture; Android export and emulator rendering were confirmed.
- Passed: the game-flow test loads all fly/hit/escape sprite frames and shot/hit effect textures.
- Passed: themed title and gameplay screens render in the Android emulator; square-corner panel/button states are visible.
- Passed: Android export and emulator launch display the original duck animation over the new background without startup script errors.
- Passed: flow test verifies all ten generated music/effect resources load, menu/gameplay music contexts switch, and an SFX event starts playback.
- Passed: audio-enabled Android APK exported, signed, installed, and launched in the Pixel 6 API 35 emulator without Godot startup errors.
- Passed: Android debug APK exported and signed with the configured development keystore; original launcher icon resources were included.
- Passed: exported APK requests no Android permissions, including network access.
- Passed: APK signature verified with Android v2/v3 schemes.
- Passed: APK installed and launched in the visible Pixel API 35 emulator; main loop started without script/runtime errors. Title screen visually reviewed at the emulator's wide landscape ratio.

## Current blockers

- No physical Android handset has been tested; emulator validation does not replace device coverage.
- No user-supplied final asset pack or legally cleared logo is available yet; the current app icon is an original no-text development mark.

## Exact next actions

1. Integrate any user-provided final logo/app icon/art/audio through the documented resource slots, updating `assets.md`.
2. Run the Android build on at least one physical handset and review touch, pause/background behavior, and common landscape aspect ratios.
3. Choose and clear the public title/branding; keep release signing credentials local and outside Git.

## Decisions awaiting approval

- `Open Range` is the provisional user-facing development title; complete a trademark clearance search before public release.
- The user selected package ID `dev.imrn.duckhunter`; confirm global store availability before publishing. Release signing setup remains pending and signing secrets must stay local.
