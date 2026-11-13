class_name ArtAssetSet
extends Resource

## Original art assigned to the prototype scene. Background layers use 960x540
## transparent PNG compositions so they can be stacked without code changes.
@export var sky: Texture2D
@export var far_hills: Texture2D
@export var tree_line: Texture2D
@export var foreground: Texture2D
@export var shot_effect: Texture2D
@export var hit_spark: Texture2D

## SpriteFrames animations are named `fly`, `hit`, and `escape`.
@export var duck_frames: SpriteFrames

## Optional Godot Theme for menu, HUD controls, and typography.
@export var ui_theme: Theme
