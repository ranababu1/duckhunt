# Duck Hunt Arcade
## Development Plan

**Status:** Initial implementation plan  
**Engine:** Godot 4.x  
**Platform:** Android first  
**Orientation:** Landscape  
**Visual direction:** Retro pixel art  
**Primary release:** Version 1.0 Classic Mode

---

## 1. Objective

Deliver a polished, offline-first, landscape Android arcade game with a simple touch-to-shoot loop, 10-round Classic Mode, local score persistence, responsive pixel-art presentation, and complete menu/pause/results flows.

The MVP should remain intentionally small. Do not start multiplayer, cloud saves, ads, online leaderboards, or additional modes until the Classic Mode is stable and fun.

## 2. Scope

### In scope
- Godot 4.x project setup.
- Landscape mobile configuration and responsive UI.
- Pixel-art environment and original duck animations.
- Touch aiming and shooting.
- Ammo, automatic reload, hit detection, escapes, lives, and scoring.
- Data-driven 10-round progression.
- Title, tutorial, gameplay, pause, round-clear, results, and settings screens.
- Local persistence for settings and best score.
- Audio and optional haptics.
- Android export, device testing, release checklist.

### Out of scope for MVP
- Online services and user accounts.
- Multiplayer.
- Cloud saves.
- Paid currency or upgrade economy.
- Ads and analytics SDKs.
- Procedural campaign generation.
- iOS release.
- Any copied Duck Hunt/Nintendo assets, names, characters, or audio.

## 3. Milestones

### M0: Project foundation
**Deliverables**
- Godot project created and opens cleanly.
- Main scene and folder structure established.
- Landscape orientation configured.
- Input actions and project settings documented.
- Placeholder art and a basic playable test scene.

**Acceptance**
- Project runs in editor and on an Android test device.
- Aspect ratio changes do not hide critical UI.
- Git repository is initialized with a suitable `.gitignore`.

### M1: Core shooting prototype
**Deliverables**
- Duck spawn and movement.
- Touch-coordinate aiming.
- Shooting and ammo consumption.
- Hit detection and escape handling.
- Basic hit/miss feedback.

**Acceptance**
- Tap hits a duck only when the tap point overlaps its valid hit area.
- One shot resolves at most one target.
- A duck can only transition to a terminal state once.
- Ammo and hit/miss counters remain consistent.

### M2: Complete Classic Mode loop
**Deliverables**
- Run controller and round controller.
- Lives and round quota.
- 10-round data table.
- Score, combo, round bonus, and accuracy.
- Round clear and game-over transitions.

**Acceptance**
- All 10 rounds can be completed.
- Failure conditions are deterministic.
- No round can softlock if a duck is hit, escapes, or is removed.
- Restarting a run resets run state without resetting saved best score.

### M3: Menus, UX, and persistence
**Deliverables**
- Title screen.
- How-to-play overlay.
- Pause/resume/restart/return-to-title.
- Round-clear screen.
- Game-over/results screen.
- Settings screen.
- Save settings and best score locally.

**Acceptance**
- Every screen has a clear next action.
- Android back behaviour is handled intentionally.
- Pause menu can return to title after confirmation.
- Settings and best score survive app restarts.
- No navigation path traps the player.

### M4: Retro art, animation, and audio
**Deliverables**
- Final original pixel-art environment.
- Duck animation states.
- Original UI sprites and icons.
- Original audio and music.
- Hit, miss, escape, reload, round-clear, and game-over feedback.
- Optional companion character, only if it does not delay core polish.

**Acceptance**
- Consistent pixel scale and palette.
- All sprites remain legible on common phone displays.
- Audio levels are balanced and can be adjusted independently.
- No placeholder or unlicensed assets remain in release scenes.

### M5: QA and Android release
**Deliverables**
- Device and aspect-ratio test matrix.
- Performance and memory checks.
- App icon, splash screen, store screenshots, privacy disclosures as applicable.
- Signed Android App Bundle.
- Release notes and rollback-ready source tag.

**Acceptance**
- No known blocker or critical bug.
- Full run, pause/resume, app background/foreground, and restart tested.
- Offline gameplay verified.
- Exported release build installed and tested on physical Android hardware.
- Package ID, version code, signing, and store listing reviewed before upload.

## 4. Proposed project structure

```text
duck-hunt-arcade/
├── project.godot
├── README.md
├── plan.md
├── instructions.md
├── assets.md
├── changelog.md
├── currentstate.md
├── .gitignore
├── scenes/
│   ├── main/
│   ├── menus/
│   ├── gameplay/
│   ├── ducks/
│   └── effects/
├── scripts/
│   ├── core/
│   ├── gameplay/
│   ├── ui/
│   └── data/
├── resources/
│   ├── rounds/
│   └── themes/
├── assets/
│   ├── sprites/
│   ├── backgrounds/
│   ├── ui/
│   ├── audio/
│   └── fonts/
├── tests/
└── export/
```

Adjust the structure if the project grows, but keep scenes, scripts, resources, and raw assets clearly separated.

## 5. Core architecture

### Main systems
- **GameManager:** Owns high-level state and screen transitions.
- **RunController:** Owns current run score, lives, shots, hits, misses, and best-score update.
- **RoundController:** Loads round configuration, spawns waves, tracks quota, and emits round completion/failure.
- **Duck:** Owns movement state, animation, hit area, and one-time terminal transition.
- **WeaponController:** Owns magazine size, shot consumption, reload timer/state, and shot events.
- **InputController:** Converts touch input into a playfield position and requests a shot.
- **ScoreService:** Calculates points and bonuses from gameplay events.
- **SaveService:** Persists settings and local best score.
- **AudioManager:** Controls music/SFX buses and plays event sounds.
- **UI scenes:** Display state; do not own authoritative gameplay rules.

### State model
High-level states:
- `BOOT`
- `MENU`
- `PLAYING`
- `PAUSED`
- `ROUND_CLEAR`
- `GAME_OVER`

Only the GameManager should authorize high-level state transitions. UI buttons should request transitions rather than independently changing multiple gameplay nodes.

### Event flow
1. InputController receives a touch.
2. WeaponController validates that firing is allowed and consumes a shot.
3. The shot is resolved against active duck hit areas.
4. A valid target receives `hit()`, otherwise a miss event is emitted.
5. RunController and RoundController update counters from events.
6. RoundController decides whether the round is cleared or failed.
7. GameManager transitions to the appropriate screen/state.

## 6. Data-driven round progression

Create a resource or configuration table for each round. Suggested fields:
- `round_number`
- `duck_count`
- `ducks_per_wave`
- `spawn_interval`
- `min_flight_speed`
- `max_flight_speed`
- `movement_pattern_pool`
- `required_hits`
- `allowed_escapes`
- `ammo_per_magazine`
- `reload_duration`

Avoid scattering difficulty constants across scripts. Tune rounds through data and test each round independently.

## 7. Testing strategy

### Unit / logic tests
- Score calculation and bonus caps.
- Accuracy calculation with zero-shot handling.
- Ammo consumption and reload transitions.
- Duck state transitions and duplicate event prevention.
- Round quota and escape rules.
- Save/load defaults and corrupted/missing save handling.

### Integration tests
- Full run from title to game over.
- Round clear to next round.
- Pause/resume.
- Restart run.
- Return to title.
- App background/foreground while playing and paused.
- Settings changes and persistence.

### Manual device matrix
Test at least:
- 16:9 landscape.
- 19.5:9 or 20:9 landscape.
- A lower-performance Android device.
- A modern Android device.
- Touch input near screen edges and UI boundaries.
- System navigation gestures and Android back behaviour.

## 8. Delivery and Git workflow

- Work on the intended branch unless explicitly authorized to change it.
- Preserve all existing uncommitted user changes.
- Never run destructive Git commands or reset user work.
- Never commit secrets, signing keys, local databases, build output, `.godot/`, temporary exports, or editor-generated files.
- Ensure `.gitignore` covers Godot cache/import artifacts and Android build artifacts.
- Compile/import and run relevant tests before considering a change complete.
- Push after every file change that leaves the solution buildable, or at minimum when approximately 50 lines of production code have changed since the last push, whichever comes first.
- Keep commits small and descriptive.

## 9. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Touch aiming feels inaccurate | Draw a debug hitbox mode; tune hitboxes on physical devices |
| Ducks feel unfairly fast | Use controlled speed curves and deterministic movement rules |
| Pixel art blurs on some screens | Configure nearest filtering and test multiple aspect ratios |
| UI is cropped in landscape | Use anchors/containers and safe-area-aware layout |
| Scope expands before core loop is fun | Freeze MVP scope; defer modes and monetization |
| Copyright confusion | Use original title, characters, sprites, audio, UI, and branding |
| State bugs cause duplicate scoring | Centralize transitions and make hit/escape resolution idempotent |

## 10. Definition of done

A milestone is complete only when:
- Its deliverables exist.
- The project imports and runs.
- Relevant automated or manual tests pass.
- No temporary debugging code is left enabled.
- Documentation and `currentstate.md` are updated.
- Changes are committed and pushed according to the Git workflow.

## 11. Immediate next actions

1. Create the Godot 4.x project and repository.
2. Add the documented folder structure and `.gitignore`.
3. Configure landscape viewport, stretch mode, and pixel filtering.
4. Build a greybox playfield with one duck and touch-to-shoot.
5. Validate the feel on a physical Android device before producing the full art set.
