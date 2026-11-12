# Duck Hunt Arcade
## Game Concept Document

**Document status:** Initial concept baseline  
**Working title:** Duck Hunt Arcade  
**Target platform:** Android first, with iOS considered after the first release  
**Engine:** Godot 4.x  
**Presentation:** Retro 8-bit / early 16-bit arcade aesthetic  
**Orientation:** Landscape  
**Genre:** Arcade, reflex, score attack  
**Core promise:** A fast, instantly understandable shooting-gallery game that brings back the feel of classic television-console duck-shooting games, rebuilt for touchscreens.

> **IP note:** “Duck Hunt Arcade” is a working project name used for planning. Before public release, choose and clear an original title. Do not use Nintendo's Duck Hunt name, characters, dog, sprites, sound effects, music, logos, level layouts, or other protected assets. Build an original homage using broad genre conventions only.

---

## 1. Product vision

Create a small, polished mobile arcade game built around one simple loop:

1. Ducks enter the playfield.
2. The player taps to aim and fire.
3. The player earns points for successful hits.
4. Missed targets escape and reduce the round's remaining quota or lives.
5. The round ends when the quota is met or the player runs out of allowed misses.
6. Each new round increases speed, target count, and movement complexity.

The game should be easy to understand within five seconds, satisfying to play in short sessions, and challenging enough to encourage replaying for a better score.

## 2. Design pillars

- **Instant play:** No lengthy tutorial, account creation, or complicated menus.
- **Readable action:** Clear silhouettes, strong contrast, predictable hit feedback, and uncluttered HUD.
- **Arcade authenticity:** Pixel art, chunky UI, chiptune-inspired original music, and crisp sound effects.
- **Fair challenge:** Difficulty rises through speed, patterns, and target combinations rather than random unavoidable misses.
- **Touch-first:** Large touch targets, forgiving hit detection tuned through testing, and responsive feedback.
- **Small, finished scope:** Prioritize a stable, polished Classic Mode before adding modes or monetization.

## 3. Target audience and session

**Audience:** Casual mobile players, retro-game fans, and players who enjoy score-chasing arcade games.

**Session length target:** 1–4 minutes per run.

**Primary motivation:** Beat a personal best, clear another round, and improve accuracy.

## 4. Core game loop

### Classic Mode

- A run starts at Round 1 with a fixed number of lives.
- Each round spawns a defined number of ducks in timed waves.
- The player must hit the required number of ducks before too many escape.
- A successful hit awards score and triggers a visible hit effect.
- A duck that leaves the playfield counts as escaped.
- The round clears when the required hit quota is reached.
- The run ends when the player loses all lives or fails the round quota.
- The results screen shows score, best score, rounds cleared, shots fired, hits, and accuracy.

**Initial tuning proposal (subject to playtesting):**
- 3 lives per run.
- 2 shots available in the magazine, followed by a short automatic reload.
- 1 duck per wave in early rounds; later rounds can introduce two simultaneous ducks.
- 10 rounds in the first release.
- Accuracy = successful hits / shots fired × 100.
- A round's required hit quota and escape allowance are data-driven, not hard-coded into scene logic.

### Touch controls

- Tap anywhere inside the playfield to fire at that screen coordinate.
- The shot is evaluated against active duck hit areas at the tap location.
- A miss still consumes ammunition.
- Reload is automatic when the magazine is empty.
- Optional haptic feedback on hit, miss, and round completion; expose a settings toggle.
- No swipe-to-aim requirement in the initial release.

**Important mobile adaptation:** The original television light-gun behavior cannot be reproduced literally on a touchscreen. Use direct touch coordinates as the aim point. The game must communicate this clearly and make the hit area feel responsive.

## 5. Gameplay systems

### Duck behaviour
Each duck uses a small state machine:
- `ENTERING`
- `FLYING`
- `HIT`
- `ESCAPING`
- `OFFSCREEN`

Movement patterns should be authored as reusable behaviours:
- Straight horizontal flight.
- Diagonal ascent or descent.
- Gentle sine-wave movement.
- Short directional feints.
- Faster movement in later rounds.

Ducks should not change direction so abruptly that touch targeting feels unfair. Movement speed, spawn timing, path selection, and hitbox size should be tunable from data.

### Shooting and ammunition
- Store shots fired, hits, misses, and magazine state in the run controller.
- A shot should resolve once, even if hitboxes overlap.
- Choose the closest or highest-priority valid target when multiple hit areas overlap.
- Use a brief muzzle flash / screen flash and a distinct hit or miss sound.
- Reload automatically after the magazine is empty, with a short visual indicator.
- Avoid realistic weapon presentation; keep the tone playful and family-friendly.

### Scoring
Initial scoring proposal:
- Standard hit: 100 points.
- Consecutive hits: small combo bonus, capped to prevent runaway scoring.
- Round clear: completion bonus based on remaining escapes and accuracy.
- Optional perfect-round bonus when no duck escapes.

Keep score values in a central configuration resource.

### Difficulty progression
Increase challenge using controlled parameters:
- Flight speed.
- Number of ducks per wave.
- Spawn interval.
- Movement pattern complexity.
- Required hits.
- Simultaneous targets.

Do not increase every parameter at once. Each round should introduce at most one meaningful new difficulty step.

## 6. Game modes and release scope

### Version 1.0: required
- Classic Mode with 10 rounds.
- Title screen, pause screen, results screen, and settings.
- Local high score.
- Sound and music volume controls.
- Haptics toggle where supported.
- Tutorial overlay shown once or accessible from the menu.
- Landscape layout for common Android aspect ratios.
- Offline play.

### Post-launch candidates (not part of MVP)
- Endless Survival.
- Daily Challenge with a fixed seed / fixed rules.
- Challenge Mode with special target patterns.
- Additional original environments and duck variants.
- Achievements and leaderboards.
- Google Play Games integration.
- Rewarded ads, only after the core game is enjoyable and retention is measured.

## 7. Art and audio direction

**Visual style:** Deliberately retro pixel art, inspired by the broad era of 8-bit console arcade games without copying any specific game's art.

- Pixel-art landscape: layered sky, distant hills, trees, and grass.
- Original duck sprites with readable wing-flap animation.
- Original companion character, if included, with a distinct silhouette and personality.
- Pixelated HUD, score display, round indicator, ammo counter, and life icons.
- Limited palette with strong foreground/background separation.
- Consistent pixel scale; avoid mixing pixel art with smooth high-resolution effects.
- Nearest-neighbour texture filtering for crisp pixels.

**Audio:**
- Original chiptune-style menu and gameplay loops.
- Distinct fire, hit, miss, escape, reload, round-clear, and game-over sounds.
- Keep effects short and non-fatiguing.
- No sampled or recreated Nintendo audio.

## 8. UX and screens

1. **Boot / loading:** Fast transition to title screen.
2. **Title screen:** Original logo, Play, Settings, How to Play.
3. **Gameplay:** Playfield, score, round, remaining quota/lives, ammo.
4. **Pause:** Resume, restart run, return to title.
5. **Round clear:** Round result and continue.
6. **Game over:** Final score, best score, accuracy, rounds cleared, retry, title.
7. **Settings:** Music, SFX, haptics, optional reduced-flash setting, privacy/legal links.

Back navigation must always be predictable. During gameplay, pause must expose a clear route back to the title screen after a confirmation prompt.

## 9. Technical direction

- Godot 4.x, GDScript, 2D renderer.
- Landscape base viewport with stretch settings that preserve pixel-art proportions.
- Use a virtual resolution and integer-friendly scaling where practical.
- Keep gameplay data separate from presentation.
- Use signals for events such as duck hit, duck escaped, ammo changed, round cleared, and run ended.
- Save settings and best score using Godot's user data directory.
- Avoid network dependencies in the first release.
- Use object pooling only if profiling shows repeated spawn/free operations are a problem; do not add complexity prematurely.

## 10. Success criteria

The MVP is ready for release when:
- A new player can start a run without assistance.
- Touch aiming feels accurate and responsive across supported screen sizes.
- No duck can be counted as hit or escaped more than once.
- Round progression and game-over conditions are deterministic and tested.
- Pause, resume, restart, and return-to-title flows work.
- Audio and settings persist correctly.
- The game runs smoothly on a representative range of Android devices.
- No copyrighted game assets or sounds are included.
- A complete run can be played offline without crashes or softlocks.

## 11. Open decisions

These should be resolved during implementation, not allowed to block the initial project setup:
- Final public title and store branding.
- Exact round-by-round difficulty table.
- Whether a companion character appears in the MVP or is reserved for a later update.
- Exact magazine size and reload duration after playtesting.
- Minimum Android version and device test matrix.
