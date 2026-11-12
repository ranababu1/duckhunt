# Duck Hunt Arcade
## Agent and Developer Instructions

These instructions are mandatory for anyone or any coding agent working on this project.

---

## 1. Project objective

Build an original retro pixel-art mobile arcade game for Android using Godot 4.x. The game is landscape-first and uses direct touchscreen taps to shoot moving targets. The first release is a polished 10-round Classic Mode.

Read these files before making changes:
1. `game_concept.md` (product intent and gameplay rules)
2. `plan.md` (scope, milestones, architecture, acceptance criteria)
3. `assets.md` (asset specifications and licensing rules)
4. `currentstate.md` (latest verified implementation state)
5. `changelog.md` (history of completed changes)

If `currentstate.md` or `changelog.md` does not exist, create it before implementation. Keep both updated throughout development.

## 2. Non-negotiable rules

### Scope and design
- Preserve retro pixel-art presentation and landscape orientation.
- Keep the game offline-first for MVP.
- Do not add online services, ads, analytics, accounts, multiplayer, or monetization without explicit approval.
- Do not expand MVP scope without documenting the impact and receiving approval.
- Do not copy Nintendo's Duck Hunt assets, characters, audio, branding, title treatment, or other protected expression.
- Treat “Duck Hunt Arcade” as a working title only. Flag public naming for legal clearance and original branding.

### Code quality
- Use Godot 4.x and GDScript unless a documented technical reason requires otherwise.
- Follow existing project conventions before introducing new patterns.
- Keep gameplay rules out of UI scripts.
- Use typed GDScript where practical.
- Prefer small, focused scripts and reusable scenes.
- Use signals for cross-system events where appropriate.
- Avoid global mutable state unless owned by a clearly documented autoload.
- Avoid premature abstraction and unnecessary dependencies.
- Do not add plugins or third-party packages without approval.
- Do not leave debug overlays, cheat controls, test assets, or temporary logging enabled in release builds.

### User work and Git safety
- Work on the intended branch unless the user explicitly authorizes a branch change.
- Inspect `git status` before editing.
- Preserve all uncommitted user changes. Never overwrite or discard them.
- Never run destructive commands such as `git reset --hard`, `git clean -fd`, forced checkout, or broad deletion commands.
- Never commit secrets, signing keys, keystores, passwords, local databases, build output, `.godot/`, temporary exports, or machine-specific files.
- Ensure `.gitignore` covers Godot editor/cache/import output and Android build/export artifacts.
- Push after every file change that leaves the solution buildable, or at minimum when approximately 50 lines of production code have changed since the last push, whichever comes first.
- Do not amend, rebase, force-push, or rewrite shared history unless explicitly authorized.
- Use descriptive commit messages.

## 3. Required documentation maintenance

### `currentstate.md`
Maintain a concise, factual snapshot containing:
- Current milestone and status.
- Current branch and latest known commit.
- Implemented features.
- Known bugs and limitations.
- Tests run and their results.
- Current blockers.
- Exact next actions.
- Any decisions awaiting user approval.

Update it whenever a milestone is completed or the implementation state materially changes. Never claim a test passed unless it was actually run.

### `changelog.md`
Maintain a chronological list of meaningful changes:
- Date.
- Commit or change reference, when available.
- Added, changed, fixed, removed.
- Tests performed.
- Known follow-up work.

Do not use the changelog as a substitute for `currentstate.md`.

### Other docs
- Update `plan.md` if approved scope or milestone acceptance criteria change.
- Update `game_concept.md` only when the product direction or gameplay rules change.
- Update `assets.md` when assets are added, replaced, approved, rejected, or their provenance changes.

## 4. Implementation workflow

For every task:

1. **Inspect**
   - Read the required docs.
   - Inspect repository status, branch, project structure, and relevant scenes/scripts.
   - Identify uncommitted changes and avoid touching unrelated files.

2. **Plan**
   - State the smallest safe implementation approach.
   - Identify affected files and relevant acceptance criteria.
   - Check whether the task changes scope or requires a new asset.

3. **Implement**
   - Make focused changes.
   - Keep gameplay state authoritative in the appropriate controller.
   - Keep tuning values data-driven.
   - Add or update tests where practical.
   - Do not fabricate asset paths or assume an asset exists; verify it.

4. **Validate**
   - Run Godot headless project import/check where supported.
   - Run automated tests.
   - Run the project in the editor or on device for gameplay/UI changes.
   - Check logs for parse errors, missing resources, and runtime errors.
   - Report tests that could not be run and why.

5. **Document**
   - Update `currentstate.md`.
   - Append to `changelog.md`.
   - Update other docs if the approved design or asset inventory changed.

6. **Commit and push**
   - Confirm only intended files are staged.
   - Check staged diff for secrets, generated files, and unrelated changes.
   - Commit and push following the required cadence.
   - Report commit SHA and push status accurately.

## 5. Gameplay implementation requirements

### Touch shooting
- Convert touch coordinates into the correct playfield coordinate space.
- Ignore touches on UI controls.
- A valid shot consumes exactly one round of ammunition.
- A single shot can hit no more than one duck.
- A miss consumes ammunition.
- If the weapon is reloading, firing is rejected and no ammunition is consumed.
- Do not use a frame-dependent hit test that can miss a fast-moving target unfairly. Resolve against the intended shot coordinate and current target state.

### Duck lifecycle
Use a clear state machine. Each duck must resolve exactly once as hit or escaped.
- Prevent duplicate hit events.
- Prevent a hit duck from also counting as escaped.
- Stop movement and disable hit detection after a terminal state.
- Release or recycle the duck only after its terminal animation is complete.
- Ensure round completion cannot wait forever for a duck that has already been removed.

### Round and run state
- Keep round configuration data-driven.
- Handle zero shots safely when calculating accuracy.
- Clamp combo bonuses and score values as specified in the concept.
- Reset run state on retry without clearing saved best score or settings.
- Pause must stop gameplay timers, duck movement, and spawning.
- Resume must restore the prior gameplay state without spawning duplicate waves.
- Returning to title must cleanly end the active run.

### UI and mobile
- Keep all critical HUD elements inside safe display bounds.
- Support common landscape aspect ratios.
- Keep tap targets comfortably sized.
- Provide visual feedback for hit, miss, reload, round clear, and game over.
- Handle Android back behaviour intentionally.
- Persist sound/music settings and best score.

## 6. Testing requirements

At minimum, test:
- One hit and one miss.
- Empty magazine and automatic reload.
- Shot during reload.
- Two overlapping target hitboxes.
- Duck hit followed by attempted escape.
- Duck escape followed by attempted hit.
- Round clear and round failure.
- Accuracy with zero shots.
- Pause during active duck movement.
- Resume without duplicate spawn.
- Restart and return-to-title flows.
- Save/load after app restart.
- Landscape layouts at multiple aspect ratios.
- App background/foreground transitions.

For a bug fix, add a regression test or document why a reliable automated test is not practical.

## 7. Asset agent instructions

- Follow `assets.md` exactly.
- Produce original artwork only.
- Maintain a consistent pixel grid, palette, outline weight, and lighting direction.
- Export transparent sprites as PNG.
- Provide sprite sheets with a documented frame order, cell size, and frame rate.
- Do not bake UI text into reusable background art.
- Include source files when the agreed workflow supports them.
- Record provenance and license for every third-party asset.
- Never use scraped game sprites, ROM extracts, game audio rips, or lookalike copies of protected characters.

## 8. Coding agent response format

At the end of each task, report:
1. Summary of implementation.
2. Files created or changed.
3. Tests actually run and results.
4. Any tests not run and reason.
5. Known bugs or risks.
6. Git branch, commit SHA, and push status.
7. Updated milestone and next actions.

Do not report “complete” when acceptance criteria remain unverified.
