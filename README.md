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

The project is currently validated with Godot 4.7.2 on desktop. Android export and device behavior have not been validated yet.

## Save data

Settings and the local best score are stored offline in `user://duckhunt_arcade.cfg`. No network, account, analytics, ads, or multiplayer services are used.

## Assets

The current scene uses original code-drawn placeholder art and has empty audio-stream slots. When supplying files, follow [doc/assets.md](doc/assets.md). Music and SFX can be assigned to the `AudioManager` child of the main scene in the Godot Inspector; keep all art and audio original or commercially licensed.

## Android release status

The viewport and landscape orientation are configured, but a physical Android test device, Android export environment, release package identity, signing credentials, and store branding still need to be prepared. Never commit signing keys or passwords.
