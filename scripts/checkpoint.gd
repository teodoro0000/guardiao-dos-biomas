extends Area2D

const BANNER_BY_COLOR := {
	"green":  "res://sprites/0x72_DungeonTilesetii_v1.7/frames/wall_banner_green.png",
	"blue":   "res://sprites/0x72_DungeonTilesetii_v1.7/frames/wall_banner_blue.png",
	"red":    "res://sprites/0x72_DungeonTilesetii_v1.7/frames/wall_banner_red.png",
	"yellow": "res://sprites/0x72_DungeonTilesetii_v1.7/frames/wall_banner_yellow.png",
}

const POLE_TOP_COLOR := {
	"green":  Color(0.55, 1.00, 0.66, 1.0),
	"blue":   Color(0.55, 0.85, 1.00, 1.0),
	"red":    Color(1.00, 0.55, 0.55, 1.0),
	"yellow": Color(1.00, 0.88, 0.42, 1.0),
}

@export var banner_color: String = "red"

@onready var banner: Sprite2D = $Banner
@onready var pole: ColorRect = $Pole
@onready var pole_top: ColorRect = $PoleTop
@onready var base_glow: ColorRect = $BaseGlow
@onready var glow: ColorRect = $Glow

var _active: bool = false
var _original_banner_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_original_banner_scale = banner.scale
	_apply_banner_texture()
	_apply_pole_top_color()
	# Pre-checkpoint: full vibrant + subtle idle pulse so it's always visible.
	modulate = Color(1, 1, 1, 1)
	glow.visible = true
	glow.modulate.a = 0.55
	_start_idle_pulse()
	if GameState.has_checkpoint(GameState.current_level_id):
		_set_already_taken()

func _apply_banner_texture() -> void:
	var path: String = BANNER_BY_COLOR.get(banner_color, BANNER_BY_COLOR["red"])
	if not ResourceLoader.exists(path):
		return
	var tex: Texture2D = load(path) as Texture2D
	if tex != null:
		banner.texture = tex

func _apply_pole_top_color() -> void:
	if pole_top == null:
		return
	pole_top.color = POLE_TOP_COLOR.get(banner_color, POLE_TOP_COLOR["red"])

func _start_idle_pulse() -> void:
	# Subtle bobbing on the pole-top "lamp" so it reads as alive even before being touched.
	if pole_top == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(pole_top, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(pole_top, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if _active:
		return
	if not body.is_in_group("Player"):
		return
	_activate(body)

func _activate(_body: Node2D) -> void:
	_active = true
	GameState.set_checkpoint(GameState.current_level_id, global_position)
	GameState.play_sfx("victory", -10.0)
	# Pop animation on the banner.
	var pop := _original_banner_scale * 1.4
	var tween := create_tween()
	tween.tween_property(banner, "scale", pop, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(banner, "scale", _original_banner_scale, 0.22)
	# Stronger glow when active.
	glow.modulate.a = 0.95
	var glow_tween := create_tween().set_loops()
	glow_tween.tween_property(glow, "modulate:a", 0.55, 0.7)
	glow_tween.tween_property(glow, "modulate:a", 0.95, 0.7)

func _set_already_taken() -> void:
	_active = true
	glow.modulate.a = 0.9
