# Changelog

## 2026-11-13 — Android development version metadata

### Added

- Project version `0.1.0` and Android debug version name `0.1.0-dev` with version code `1`.

### Verification

- Re-exported and signed the Android debug APK; inspected its manifest and confirmed package `dev.imrn.duckhunt`, version name `0.1.0-dev`, and version code `1`.
- Installed and launched the new APK in the visible Pixel API 35 AVD.

## 2026-11-13 — `9829d05` Android development icon and boot splash

### Added

- Original no-text pixel-grid development icon assigned to the Godot project and Android launcher export.
- Original range background configured as the pixel-filtered engine boot splash.

### Verified

- Gameplay logic and full game-flow checks pass.
- Android debug APK exported and signed, installed, and launched in the Pixel API 35 emulator; Godot main loop started without script/runtime errors.

### Follow-up

- Replace provisional development branding after public title clearance and review on a physical Android device.

## 2026-11-13 — `444f8f8` Original rectangular arcade UI theme

### Added

- Original square-corner navy panel and gold-button Theme assigned through `ArtAssetSet.ui_theme`.
- Reduced the title subtitle's minimum height to fit the themed panel safely at the base landscape viewport.
- Updated the flow check to assert the assigned Theme is active.

### Tests

- Passed full game-flow and panel-bound checks with the Theme active.
- Exported and launched the Android build, then visually reviewed the themed title and gameplay HUD in the emulator.

### Follow-up

- Complete local icon/branding once the public title is cleared; review touch and device-specific layout on a physical handset.

## 2026-11-13 — `a1eab44` Original duck animation and effects

### Added

- Five original 64 × 48 duck poses with a three-frame wing-flap cycle, two-frame hit reaction, and escape animation, authored on a crisp four-pixel grid.
- Original shot-flash and hit-spark textures integrated into the art resource.
- Flow assertions covering target animation frame counts and effect texture loading.

### Tests

- Passed Godot import and game-flow checks for the new animation and effects resources.
- Passed Android export and emulator launch; the original target sprite rendered in Classic Mode with no startup script errors.

### Follow-up

- Review the target against final supplied art and tune visual hit feedback on a physical handset.

## 2026-11-13 — `b3d7e03` Procedural original music and effects

### Added

- Deterministic standard-library generator for original chiptune menu/gameplay loops and shot, hit, miss, escape, reload, round-clear, game-over, and button effects.
- Assigned all generated WAV streams to the main scene's `AudioManager`.
- Flow assertions for menu/gameplay music context switching and event-stream playback.
- Audio provenance and regeneration instructions in `assets.md`.

### Tests

- Passed audio generation, Godot asset import, gameplay logic tests, and game-flow test including music/SFX wiring.
- Passed Android debug export/signature and emulator install/launch with no Godot startup errors.

### Follow-up

- Listen-test and balance the sounds on physical device speakers; replace with user-provided cleared audio if desired.

## 2026-11-13 — `a33fea2` Original background art integration

### Added

- Original AI-generated pixel-art daytime landscape at `assets/backgrounds/open_range_day.png`, integrated as an optional full-scene background through `ArtAssetSet`.
- Asset provenance and the new complete-background resource slot are documented.
- Flow test now checks that the scene loads its configured original background without invoking draw functions outside Godot's render callback.

### Tests

- Passed Godot asset import and gameplay logic suite.
- Game-flow suite initially exposed an obsolete greybox-only assertion; updated it to verify the loaded background resource, then re-ran successfully.

### Follow-up

- Add original duck animation/effects and audio; supplied final assets can replace the temporary art at the existing resource slots.

## 2026-11-13 — `b0a67a9` Android debug export and emulator check

### Added

- Android Debug export preset for package `dev.imrn.duckhunt`, with landscape mode, ARM64, and a development display label.
- Android ETC2/ASTC texture import setting required for Android exports; corrected the project orientation value to landscape.
- README instructions for exporting a local debug APK.

### Verified

- Godot 4.7.2 exported a signed debug APK; package ID, API levels, signature, and landscape manifest were inspected.
- Installed and launched the APK in a Pixel 6 API 35 emulator, entered Classic Mode, and fired at a target. HUD hit/quota and automatic reload updates were visible; no Godot script errors appeared in startup logs.

### Follow-up

- Original art/audio and physical Android device validation remain outstanding. Public title/branding and release signing are not finalized.

## 2026-11-13 — `292e39e`

### Changed

- Game/UI save paths can be configured, with the normal production default unchanged.
- End-to-end tests persist settings and scores to a process-specific temporary file and remove it afterward.

### Tests

- Passed gameplay logic, complete ten-round and escape-failure flow, and headless launch checks.

### Follow-up

- Keep player profile data isolated from automated QA runs.

## 2026-11-13 — `7afa5f2`

### Tests

- Game-flow test now checks title/tutorial/pause/round-clear/results/settings panels stay within 960×540 and their content minimum height fits the cards.
- Passed gameplay logic, complete game-flow, and headless launch checks.

### Follow-up

- Visual review and physical landscape aspect-ratio checks remain outstanding.

## 2026-11-13 — `53a79eb`

### Fixed

- Non-finite volume values now use the safe default instead of reaching the audio server.

### Tests

- Passed a NaN volume regression check, gameplay logic, complete campaign flow, and headless scene launch.

### Follow-up

- Recheck Android export and audio settings once the missing SDK/JDK are available.

## 2026-11-13 — `3bfedb7`

### Tests

- Extended viewport-to-canvas conversion coverage to include non-uniform scaling plus translation.
- Passed gameplay logic tests, complete game-flow test, and headless scene launch.

### Follow-up

- Verify touch targets and safe margins on real Android aspect ratios when the SDK and devices are available.

## 2026-11-13 — `481b8ec`

### Changed

- Hit and escape lifetimes now follow assigned `SpriteFrames` frame durations and playback speed, with the existing 0.35 second fallback when animation data is absent.
- Empty animation states retain the geometric duck fallback.

### Tests

- Passed sprite-backed three-frame, 10 FPS lifecycle regression check, gameplay logic tests, ten-round game-flow test, and headless scene launch.

### Follow-up

- Verify the timing against supplied hit/escape artwork when available.

## 2026-11-13 — `bc07bfb`

### Tests

- Integrated flow confirms the round ends at the configured escape limit while lives remain, and the run ends only after that limit is exceeded.
- Re-ran gameplay logic tests, ten-round game-flow checks, and the headless scene launch successfully.

### Follow-up

- Android build remains unverified because this environment has no configured SDK or Java runtime.

## 2026-11-13 — `41dcd0b`

### Fixed

- Round accuracy now resets per round and contributes to the clear bonus.
- Perfect-round bonus now requires zero escapes, independent of earlier run accuracy.
- Documented the scoring formula in the game concept.

### Tests

- Passed logic tests for zero-shot round accuracy, accuracy-scaled bonus, and escape-gated perfect bonus.
- Passed full ten-round prototype flow and three-second headless scene launch.

### Follow-up

- Tune scoring values after playtesting with the finished art/audio.

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

## 2026-11-13 — `f50de2a`

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
