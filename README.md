# Open Range

An offline-first, landscape arcade shooting game built with Godot 4 and GDScript. “Duck Hunt Arcade” is an internal working name only; public naming and store branding still need legal clearance.

## Run locally

Open this folder in Godot 4 or run:

```sh
godot --path .
```

Tap or click inside the playfield to shoot. Escape or Android Back pauses a run. The game includes a 10-round Classic Mode, title/tutorial/settings screens, pause/retry/title flows, round-clear screens, results, local best score, two-shot reloads, lives, combo scoring, and configurable target waves.

## Validate

```sh
godot --headless --path . --script res://tests/gameplay_logic_test.gd
godot --headless --path . --script res://tests/game_flow_test.gd
godot --headless --path . --quit-after 3
```

The project is currently validated with Godot 4.7.2 on desktop and in a local Pixel 6 API 35 Android emulator. Run the logic/flow checks above and a short headless launch after code changes.

## Save data

Settings and the local best score are stored offline in `user://duckhunt_arcade.cfg`. No network, account, analytics, ads, or multiplayer services are used.

## Assets

The current scene uses an original pixel-art daytime background with replaceable geometric target/effect fallbacks and empty audio-stream slots. When supplying files, follow [doc/assets.md](doc/assets.md). Assign the `ArtAssetSet` resource at `resources/art/open_range_art_set.tres` for a full background or separate parallax layers, duck animations, action effects, title logo, and an optional UI Theme; assign music/SFX on the `AudioManager` child of the main scene in the Godot Inspector. Keep all art and audio original or commercially licensed.

## Android debug build

The Android SDK/JDK paths are configured in the local Godot editor settings. Export the local debug APK with:

```sh
godot --headless --path . --export-debug "Android Debug" export/android/open_range_debug.apk
```

The preset uses package ID `dev.imrn.duckhunt` and the development label `Open Range (Development)`. The APK is signed with Godot's local debug key and is ignored by Git. It was installed and launched in a Pixel 6 API 35 emulator; a real-device test remains outstanding. No release signing key is configured. Public title and store branding still need legal clearance. Never commit signing keys or passwords.
