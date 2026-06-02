extends Area2D

const SPRITE_BY_TYPE := {
	"plastic": preload("res://sprites/Items/bin_plastic.png"),
	"organic": preload("res://sprites/Items/bin_organic.png"),
	"glass":   preload("res://sprites/Items/bin_glass.png"),
}

@export var accepts: String = "plastic"
@export var tint: Color = Color(0.46, 0.80, 1.00, 1.0)
@export var label_text: String = "PLÁSTICO"

@onready var sprite: Sprite2D = $Sprite2D
@onready var glow: ColorRect = $Glow
@onready var label: Label = $Label

var _can_interact: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_sprite()
	glow.color = Color(tint.r, tint.g, tint.b, 0.85)
	label.text = label_text
	label.modulate = tint

func _apply_sprite() -> void:
	var tex: Texture2D = SPRITE_BY_TYPE.get(accepts, null)
	if tex == null:
		return
	sprite.texture = tex

func _on_body_entered(body: Node2D) -> void:
	if not _can_interact:
		return
	if not body.is_in_group("Player"):
		return
	if not body.has_method("get_carried_trash"):
		return
	var trash = body.get_carried_trash()
	if trash == null:
		return
	if trash.get_type_id() == accepts:
		body.deposit_trash()
		GameState.collect(GameState.current_level_id)
		GameState.play_sfx("deposit")
		_pulse(Color(0.40, 0.92, 0.62, 1.0))
	else:
		GameState.play_sfx("hurt", -14.0)
		_pulse(Color(1.0, 0.34, 0.42, 1.0))
		_can_interact = false
		await get_tree().create_timer(0.6).timeout
		_can_interact = true

func _pulse(color: Color) -> void:
	var original = glow.color
	var tween := create_tween()
	tween.tween_property(glow, "color", color, 0.1)
	tween.tween_property(glow, "color", original, 0.4)
	var scale_tween := create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.1)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
