extends Area2D

const SPRITE_BY_TYPE := {
	"plastic": preload("res://sprites/Items/item_plastic.png"),
	"organic": preload("res://sprites/Items/item_organic.png"),
	"glass":   preload("res://sprites/Items/item_glass.png"),
}
const ITEM_SCALE: float = 0.035

@export var type_id: String = "plastic"
@export var tint: Color = Color(0.46, 0.80, 1.00, 1.0)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _picked: bool = false
var _carrier: Node = null
var _time: float = 0.0
var _start_y: float = 0.0

func _ready() -> void:
	_start_y = position.y
	var has_textured: bool = _apply_sprite()
	# Tint only the legacy fallback sprite; real per-type textures carry their own color.
	if not has_textured:
		sprite.modulate = tint
	body_entered.connect(_on_body_entered)
	var radius_mul: float = float(GameState.get_character_modifier("collect_radius_mul", 1.0))
	collision_shape.scale = Vector2(radius_mul, radius_mul)

func _apply_sprite() -> bool:
	var tex: Texture2D = SPRITE_BY_TYPE.get(type_id, null)
	if tex == null:
		return false
	sprite.texture = tex
	sprite.region_enabled = false
	sprite.scale = Vector2(ITEM_SCALE, ITEM_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return true

func _process(delta: float) -> void:
	if _picked and is_instance_valid(_carrier):
		global_position = _carrier.global_position + Vector2(0, -14)
		return
	_time += delta
	position.y = _start_y + sin(_time * 3.0) * 1.5
	sprite.rotation = sin(_time * 2.0) * 0.1

func _on_body_entered(body: Node2D) -> void:
	if _picked:
		return
	if not body.is_in_group("Player"):
		return
	if not body.has_method("can_pickup_trash") or not body.can_pickup_trash():
		return
	_picked = true
	_carrier = body
	body.set_carried_trash(self)
	collision_shape.set_deferred("disabled", true)
	sprite.rotation = 0.0
	GameState.play_sfx("pickup")

func get_type_id() -> String:
	return type_id
