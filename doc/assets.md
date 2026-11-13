# Duck Hunt Arcade
## Asset Production and Integration Specification

**Art direction:** Retro pixel art  
**Orientation:** Landscape  
**Engine:** Godot 4.x  
**Target:** Android  
**Asset policy:** Original artwork and audio only

---

## 1. Visual identity

Create a cohesive retro arcade world that evokes the broad visual language of early home-console games without copying any identifiable game, character, sprite, logo, sound, or composition.

### Art rules
- Use crisp pixel art with a consistent logical pixel scale.
- Use nearest-neighbour filtering for pixel textures.
- Avoid anti-aliased edges and sub-pixel sprite movement where it causes shimmer.
- Use a limited, coordinated palette with clear foreground/background contrast.
- Use consistent outline thickness and light direction.
- Keep gameplay targets readable against every background.
- Do not mix detailed high-resolution painted art with low-resolution pixel sprites.
- Export reusable art separately from UI text and layout.

### Palette direction
Suggested palette families:
- Sky: light cyan, medium blue, dusk blue.
- Ground: muted green, dark green, warm earth.
- Ducks: natural but exaggerated contrasting colours.
- UI: warm cream, dark navy/charcoal, bright accent yellow.
- Feedback: distinct hit sparkle and miss indicator colours.

Exact colour values should be consolidated into a palette reference image or palette file during production.

## 2. Required MVP asset inventory

### A. Gameplay environment

| Asset ID | Description | Suggested format | Notes |
|---|---|---|---|
| BG_SKY_DAY | Main daytime sky | PNG | Tileable or full-width |
| BG_HILLS_FAR | Distant hills | PNG | Parallax layer |
| BG_TREES_MID | Mid-distance tree line | PNG | Parallax layer |
| BG_GRASS_FRONT | Foreground grass | PNG | Duck entry/exit area |
| BG_GROUND_DETAIL | Optional ground details | PNG | Keep low contrast |
| BG_SKY_ALT | Optional alternate sky | PNG | Can be deferred |

Create the initial scene with at least three parallax layers: sky, distant landscape, and foreground.

### B. Duck character

| Asset ID | Description | Suggested format | Notes |
|---|---|---|---|
| DUCK_FLY_LEFT | Duck flying left | Sprite sheet PNG | Wing cycle |
| DUCK_FLY_RIGHT | Duck flying right | Sprite sheet PNG | Mirror only if silhouette remains correct |
| DUCK_HIT | Hit reaction | Sprite sheet PNG | Short, readable animation |
| DUCK_ESCAPE | Escape/fly-away | Sprite sheet PNG | Optional if normal flight can be reused |
| DUCK_SHADOW | Optional shadow | PNG | Only if useful against background |

**Animation proposal**
- Idle/wing flap: 3–4 frames.
- Hit: 2–4 frames.
- Escape: 2–4 frames.
- Target frame rate: 8–12 FPS for wing flap; tune hit effects for readability.

Provide separate left/right versions if mirroring makes the sprite anatomically incorrect or changes key markings.

### C. Original companion character (optional for MVP)

If included, create a completely original arcade companion. Do not recreate the famous dog or any distinctive copyrighted character.

| Asset ID | Description | Suggested format | Notes |
|---|---|---|---|
| COMPANION_IDLE | Neutral pose | PNG | Distinct silhouette |
| COMPANION_CELEBRATE | Success reaction | Sprite sheet PNG | Short loop |
| COMPANION_LAUGH | Miss reaction | Sprite sheet PNG | Original expression |
| COMPANION_GAMEOVER | Game-over reaction | PNG or sheet | Optional |

This character is lower priority than gameplay readability and may be deferred.

### D. Effects

| Asset ID | Description | Suggested format | Notes |
|---|---|---|---|
| FX_MUZZLE_FLASH | Small firing flash | Sprite sheet PNG | Brief |
| FX_HIT_SPARK | Hit confirmation | Sprite sheet PNG | High contrast |
| FX_SCORE_POP | Score feedback | Sprite sheet PNG | No baked-in numbers |
| FX_ROUND_CLEAR | Round-clear effect | Sprite sheet PNG | Reusable |
| FX_MISS | Miss feedback | PNG/sprite sheet | Subtle |
| FX_DUCK_FEATHERS | Optional hit/escape particles | Sprite sheet PNG | Keep lightweight |

### E. UI

| Asset ID | Description | Suggested format | Notes |
|---|---|---|---|
| UI_PANEL | Pixel panel | PNG / 9-slice | Reusable |
| UI_BUTTON_NORMAL | Button state | PNG | No baked-in label |
| UI_BUTTON_PRESSED | Pressed state | PNG | Match normal dimensions |
| UI_ICON_HEART | Life icon | PNG | Consistent pixel grid |
| UI_ICON_AMMO | Ammo icon | PNG | Readable at small size |
| UI_ICON_PAUSE | Pause icon | PNG | Simple silhouette |
| UI_ICON_SETTINGS | Settings icon | PNG | Simple silhouette |
| UI_ICON_SOUND | Sound icon | PNG | On/off variants |
| UI_ICON_HAPTIC | Haptic icon | PNG | On/off variants |
| UI_LOGO_WORKING | Temporary project logo | PNG | Replace after title clearance |
| UI_TUTORIAL_TAP | Touch instruction graphic | PNG | No platform-specific hand |

Prefer native Godot labels for text so localization, scaling, and accessibility remain possible.

### F. Fonts
- Use a pixel-style font with a clear license permitting commercial mobile-game use.
- Include font license and attribution requirements in the repository.
- Ensure numbers remain legible at small sizes.
- Avoid fonts that make `1`, `I`, `0`, and `O` difficult to distinguish.

### G. Audio

| Asset ID | Description | Format | Notes |
|---|---|---|---|
| SFX_SHOT | Arcade shot | WAV/OGG | Short, non-harsh |
| SFX_HIT | Successful hit | WAV/OGG | Positive confirmation |
| SFX_MISS | Miss | WAV/OGG | Subtle |
| SFX_ESCAPE | Duck escapes | WAV/OGG | Distinct |
| SFX_RELOAD | Reload | WAV/OGG | Short |
| SFX_ROUND_CLEAR | Round clear | WAV/OGG | Rewarding |
| SFX_GAME_OVER | Game over | WAV/OGG | Clear ending |
| SFX_BUTTON | UI click | WAV/OGG | Reusable |
| MUS_MENU | Menu loop | OGG | Original chiptune |
| MUS_GAMEPLAY | Gameplay loop | OGG | Non-distracting |

All music and sound must be original or properly licensed for commercial distribution. Do not sample or recreate audio from Nintendo games.

## 3. Technical export specifications

### Sprites
- PNG with transparency.
- Sprite sheets must use uniform cell dimensions.
- No inconsistent padding between frames.
- Document frame order, frame count, cell width/height, and intended FPS.
- Keep each animation's pivot/origin consistent.
- Provide a preview GIF or contact sheet for review, but keep the game-ready source as PNG.

### Backgrounds
- PNG, opaque unless transparency is required.
- Provide layer dimensions and intended parallax factor.
- Avoid baked-in gameplay UI or target sprites.
- Ensure horizontal edges tile cleanly if the layer scrolls.

### UI
- PNG with transparency where needed.
- Buttons must have matching dimensions across states.
- Avoid text baked into button art.
- Provide 9-slice margins for resizable panels where appropriate.

### Audio
- WAV for source/master files where practical.
- OGG for in-game delivery.
- Normalize levels consistently and avoid clipping.
- Include loop points for music where needed.

## 4. Suggested source dimensions

These are starting points, not rigid constraints. The asset agent should confirm them against the chosen logical viewport before final production.

| Asset | Starting dimensions |
|---|---:|
| Logical gameplay viewport | 960 × 540 |
| Full background composition | 960 × 540 |
| Duck sprite cell | 64 × 48 |
| Small effect cell | 32 × 32 |
| UI icon | 24 × 24 or 32 × 32 |
| Button base | 160 × 48 |
| Companion character cell | 96 × 96 |

Keep dimensions aligned to the chosen pixel grid. Do not upscale a tiny sprite and then paint detail into the enlarged version.

## 5. Asset naming convention

Use lowercase snake_case and stable IDs:
- `bg_sky_day.png`
- `bg_hills_far.png`
- `duck_fly_left.png`
- `duck_fly_right.png`
- `fx_hit_spark.png`
- `ui_icon_heart.png`
- `sfx_shot.ogg`
- `mus_gameplay.ogg`

For sprite sheets, include animation and direction:
- `duck_fly_left_sheet.png`
- `duck_hit_sheet.png`
- `companion_celebrate_sheet.png`

Avoid filenames such as `final2_realfinal.png`.

## 6. Asset folder convention

```text
assets/
├── backgrounds/
├── sprites/
│   ├── ducks/
│   ├── companion/
│   └── effects/
├── ui/
├── fonts/
└── audio/
    ├── music/
    └── sfx/
```

Keep editable source files in a separate `source/` directory only if the chosen art tool produces useful editable project files. Do not commit enormous temporary renders or unrelated source exports.

## 7. Asset agent delivery checklist

For each delivery:
1. Provide a manifest with asset ID, filename, dimensions, frame count, FPS, and intended use.
2. Provide a preview/contact sheet.
3. Confirm transparency and sprite-sheet cell alignment.
4. Confirm the asset matches the retro palette and pixel scale.
5. Confirm all art is original and identify any third-party licensed components.
6. Include license files or attribution text where required.
7. Do not change gameplay code or scene files unless explicitly assigned.
8. Do not overwrite approved assets without approval.
9. Report missing or deferred assets clearly.

## 8. Integration and QA checklist

### Godot assignment slots

- The main scene references `resources/art/open_range_art_set.tres`, an `ArtAssetSet` resource exposed as `art_assets` on the root `PrototypeGame` node.
- Assign `background` for one complete 960 × 540 composition, or use the separate sky/hills/tree/foreground layers below. The current original AI-generated daytime range composition is `assets/backgrounds/open_range_day.png` (1672 × 941 PNG); it is stretched to the logical viewport with pixel-friendly filtering. Its provenance is OpenAI image generation for this project; no third-party source assets are included.
- Original synthesized audio is generated reproducibly by `tools/generate_audio.py` and assigned on the main scene's `AudioManager`: two looping 22.05 kHz mono WAV chiptune themes plus eight short event effects. The generator uses Python's standard library, oscillator waveforms, and seeded noise; it contains no samples or third-party audio. Replace any of these streams with cleared supplied tracks when available.
- Assign `sky`, `far_hills`, `tree_line`, and `foreground` textures there. Each is drawn over a 960 × 540 canvas; the sky should be opaque and the three nearer layers should use transparency where needed. The game keeps the geometric range if any required background layer is missing.
- Assign optional 32 × 32 `shot_effect` and 64 × 64 `hit_spark` textures for tap and hit feedback. Missing textures keep the drawn shot ring and duck outline; reduced-flash hides both effects.
- Assign optional `title_logo` artwork to replace the text title on the title screen. Leave it empty to retain the working-title text.
- `duck_frames` is assigned to `resources/art/duck_sprite_frames.tres`: three 64 × 48 fly frames at 10 FPS, two hit frames at 12 FPS, and one escape pose at 5 FPS. The 64 × 48 source sprites are original SVG pixel art with a four-pixel grid. The duck keeps its geometric fallback for any missing or empty animation. Hit/escape lifetime follows the animation's frame durations and speed; without those animations it uses a 0.35 second fallback.
- `ui_theme` is assigned to `resources/art/open_range_ui_theme.tres`, which provides square-corner navy panels, cream borders, gold buttons, and matching interaction states. The fallback code styles remain available if the theme is removed; a supplied UI Theme can replace this resource later.
- Music and effect streams remain assigned on the main scene's `AudioManager` child. No asset paths are hard-coded into gameplay scripts.

- Verify every referenced asset path exists.
- Check import settings use nearest filtering for pixel art.
- Verify animation frame order and playback speed.
- Check duck silhouettes against every background.
- Check UI at multiple landscape aspect ratios.
- Confirm transparent edges do not contain halos.
- Confirm audio loops cleanly and does not clip.
- Confirm no placeholder assets remain in release scenes.
- Confirm asset provenance and licenses are recorded.

## 9. Production priority

**Priority 0: playable prototype**
- One duck flight sheet.
- Simple sky/ground background.
- Basic hit/miss effect.
- Temporary HUD.

**Priority 1: MVP completion**
- Final duck animations.
- Final environment layers.
- HUD and menu UI.
- Core sound effects.
- Menu and gameplay music.

**Priority 2: polish**
- Companion character.
- Additional environment variants.
- Extra effects and score feedback.
- Optional cosmetic duck variants.

Do not delay a playable prototype to produce optional character animations or decorative backgrounds.
