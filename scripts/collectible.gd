extends Area2D

const SPRITE_BY_LEVEL := {
	"forest": preload("res://sprites/Items/seed.png"),
	"tropic": preload("res://sprites/Items/item_plastic.png"),
	"energy": preload("res://sprites/Items/battery.png"),
}
const COLLECTIBLE_SCALE: float = 0.035

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _start_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false

func _ready() -> void:
	_start_y = position.y
	body_entered.connect(_on_body_entered)
	var radius_mul: float = float(GameState.get_character_modifier("collect_radius_mul", 1.0))
	collision_shape.scale = Vector2(radius_mul, radius_mul)
	_apply_sprite()

func _apply_sprite() -> void:
	var tex: Texture2D = SPRITE_BY_LEVEL.get(GameState.current_level_id, null)
	if tex == null:
		return
	sprite.texture = tex
	sprite.region_enabled = false
	sprite.scale = Vector2(COLLECTIBLE_SCALE, COLLECTIBLE_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _process(delta: float) -> void:
	if _collected:
		return
	_time += delta
	position.y = _start_y + sin(_time * 3.0) * 1.5
	sprite.rotation = sin(_time * 2.0) * 0.1

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if not body.is_in_group("Player"):
		return
	_collected = true
	GameState.collect(GameState.current_level_id)
	GameState.play_sfx("pickup")
	_play_pickup_animation()

func _play_pickup_animation() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_property(self, "position:y", position.y - 8, 0.25)
	tween.chain().tween_callback(queue_free)
