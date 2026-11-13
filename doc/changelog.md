# Changelog

## 2026-11-13 — `0d30f84`

### Tests

- Expanded the integrated game-flow test to clear all ten configured rounds through `PrototypeGame` and verify the completed-run results screen reports 10/10.
- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.

### Follow-up

- Complete manual gameplay and Android device QA when a device and export environment are available.

## 2026-11-13 — `67b888b`

### Changed

- Gameplay HUD now shows unresolved targets remaining, including active and not-yet-spawned ducks.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.
- Flow test verifies the remaining count starts at the configured total and decreases after a hit.

### Follow-up

- Verify HUD text sizing with final UI art on common landscape device ratios.

## 2026-11-13 — `47c9670`

### Added

- Optional title-logo texture in `ArtAssetSet`; the placeholder text remains visible when no logo is assigned.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.
- Flow test confirms the placeholder title remains available without supplied branding.

### Follow-up

- Assign legally cleared original branding when provided and review the title-screen layout visually.

## 2026-11-13 — `80f8bf4`

### Added

- Optional shot-flash and hit-spark textures to `ArtAssetSet`.
- Existing geometric feedback remains active when textures are absent; reduced-flash continues to suppress the effects.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.

### Follow-up

- Assign original action-effect textures when supplied and inspect their visual scale on device.

## 2026-11-13 — `6af1611`

### Added

- Optional Theme assignment through `ArtAssetSet`, applied to generated menus and HUD controls.
- Default code styles remain active until a custom Theme is assigned.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.

### Follow-up

- Apply the supplied original UI Theme/art when available and verify its layout visually.

## 2026-11-13 — `8a5a32c`

### Added

- `ArtAssetSet` resource with sky, distant hills, tree line, foreground, and duck `SpriteFrames` slots.
- Main-scene wiring for the art resource, named `fly`/`hit`/`escape` duck animations, and geometric fallbacks for unassigned or incomplete art.
- Asset handoff notes describing resource assignment and expected animation names.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.
- Flow test confirms the resource loads and incomplete background art keeps the fallback.

### Follow-up

- Assign the user's original art and audio files when provided, then complete Android validation.

## 2026-11-13 — `f3b1192`

### Changed

- Tutorial now explains that escapes cost lives and exceeding the round allowance ends the run.
- Clarified that the round hit quota must be met before the configured targets are gone.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.
- Flow test confirms the tutorial opens from the title and states the escape limit.

### Follow-up

- Continue toward original art/audio integration and Android validation.

## 2026-11-13 — `ffb77a1`

### Fixed

- Retired ducks now stop processing and redrawing after their terminal animation finishes.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.
- Flow test confirms retired targets stop processing after animation completion.

### Follow-up

- Continue toward original art/audio integration and Android validation.

## 2026-11-13 — `60c6eac`

### Changed

- Added the current round's escape count and allowance to the gameplay HUD.
- Centralized the HUD status text so the live values can be checked in the game-flow test.

### Tests

- Passed gameplay logic tests, full game-flow smoke test, and three-second headless scene launch.

### Follow-up

- Continue toward original art/audio integration and Android validation.

## 2026-11-13 — `e295114`

### Changed

- Settings and saved scores now validate stored value types and use safe defaults for malformed fields.

### Tests

- Passed gameplay logic tests, including malformed preference and best-score recovery.
- Passed full game-flow smoke test and three-second headless scene launch.

### Follow-up

- Integrate the supplied original art/audio and complete Android validation.

## 2026-11-13 — `12a95fb`

### Changed

- Returning to title now records the run’s best score and the title screen displays the saved record.

### Tests

- Passed gameplay logic, end-to-end flow, and headless scene smoke tests.

### Follow-up

- Integrate the supplied original art/audio and Android validation.

## 2026-11-13 — `d4661dd` feedback settings

### Changed

- Reduced-flash settings now suppress target hit sparks as well as shot markers.
- Optional haptics now cover miss and round-clear feedback in addition to hits and escapes.

### Tests

- Passed gameplay, end-to-end game-flow, and full scene smoke tests.

### Follow-up

- Integrate the supplied original art/audio and validate the Android build on device.

## 2026-11-13 — `2d949f0`

### Added

- Dedicated input controller for touch/mouse shooting and viewport-to-canvas coordinate conversion.

### Tests

- Passed coordinate-conversion test, gameplay logic suite, end-to-end game-flow smoke test, and full scene smoke test.

### Follow-up

- Integrate provided art/audio and complete Android device validation when the release environment is available.

## 2026-11-13 — `d1df331`

### Added

- Local run, test, save-data, asset-assignment, and Android release-status notes in `README.md`.
- AudioManager scene node with Inspector-editable stream slots for original music and effects.

### Tests

- Passed the headless logic suite, end-to-end game-flow smoke test, and full scene smoke test after scene wiring.

### Follow-up

- Receive the user's original art/audio assets and prepare Android packaging when the public title is cleared.

## 2026-11-13 — `3904314`

### Added

- Regression checks for nearest target selection, paired waves, automatic background pause, and resume without duplicate wave starts.

### Tests

- Passed updated gameplay logic suite, full game-flow smoke test, and headless scene launch.

### Follow-up

- Integrate supplied art/audio and proceed to Android device QA.

## 2026-11-13 — `036b640`

### Added

- End-to-end game-flow smoke test covering title, first shot, pause/settings/resume, round clear, and next-round state.
- Automatic pause on mobile background and window focus loss.

### Fixed

- Remaining ducks are retired before a new round, preventing targets from leaking across round boundaries.
- Escape navigation prioritizes closing Settings/Tutorial before changing gameplay state.

### Tests

- Passed gameplay logic suite, complete game-flow test, and three-second headless scene smoke test.

### Follow-up

- Integrate original visual/audio assets when supplied and verify on physical Android devices.

## 2026-11-13 — `cc6d241`

### Added

- Finite target counts, configurable spawn intervals, and one- or two-target waves.
- Sine and diagonal duck movement patterns selected from each round’s configuration.
- Closest-hit resolution for overlapping target hit areas.
- Audio bus manager with event hooks for music, SFX, and UI feedback.
- Android back request behavior across gameplay, pause, settings, tutorial, results, and title.

### Changed

- The full ten-round campaign now progresses through configured target counts instead of respawning indefinitely.
- Music and SFX settings now control separate runtime audio buses.

### Tests

- Passed gameplay logic suite, including finite spawn counts and complete ten-round progression.
- Passed three-second headless scene smoke test with no script errors.

### Follow-up

- Integrate user-provided original art/audio; verify device behavior and aspect ratios on Android.

## 2026-11-13 — Uncommitted

### Added

- Title, tutorial, pause, round-clear, results, and settings screens with button navigation.
- Return-to-title confirmation from pause and retry flow from results.
- Local settings and best-score persistence using `ConfigFile`.
- Game pause/resume behavior for duck and weapon timers, including keyboard/back navigation.
- Haptics toggle connected to hit/escape feedback where mobile vibration is supported.

### Changed

- A run now begins from the title screen; round advancement waits for an explicit continue action.

### Tests

- Passed gameplay logic suite, including pause/resume/title state checks.
- Passed settings and best-score persistence round-trip check, including preserving the existing best score.
- Passed three-second headless game scene smoke test.

### Follow-up

- Add multi-target wave logic and connect audio buses for future provided assets.

## 2026-11-13 — `c7cc901`

### Added

- Three-life run tracking, capped combo scoring, and round-clear/perfect-round score bonuses.

### Changed

- Greybox HUD now displays combo and lives, and hit feedback reports the awarded points.

### Tests

- Extended headless gameplay tests to cover standard/capped combo scores, perfect-round bonus, and escape life loss.

### Follow-up

- Implement results/menu screens and multi-target waves.

## 2026-11-13 — `2f26197`

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
