extends Area2D

@export var speed: float = 220.0
@export var lifetime: float = 1.8

@onready var sprite: Sprite2D = $Sprite2D

var direction: int = 1
var _alive: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func set_direction(d: int) -> void:
	direction = sign(d) if d != 0 else 1
	if sprite != null:
		sprite.flip_h = direction < 0

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	_alive += delta
	if _alive >= lifetime:
		queue_free()
	if sprite != null:
		sprite.rotation += delta * 8.0 * direction

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		var enemy: Node = area.get_parent()
		if enemy != null and enemy.has_method("take_damage"):
			enemy.take_damage()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Destroy on hitting solid terrain (collision_layer 1).
	if body is StaticBody2D or body is TileMapLayer:
		queue_free()
