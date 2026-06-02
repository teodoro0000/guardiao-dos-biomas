extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const MAX_LIVES: int = 5

var _start_y: float = 0.0
var _time: float = 0.0
var _taken: bool = false

func _ready() -> void:
	_start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if _taken:
		return
	_time += delta
	position.y = _start_y + sin(_time * 3.5) * 2.0
	sprite.rotation = sin(_time * 1.5) * 0.18

func _on_body_entered(body: Node2D) -> void:
	if _taken:
		return
	if not body.is_in_group("Player"):
		return
	if GameState.lives >= MAX_LIVES:
		# Player already at cap — leave the heart for later.
		return
	_taken = true
	GameState.lives += 1
	GameState.lives_changed.emit(GameState.lives)
	GameState.play_sfx("pickup")
	collision_shape.set_deferred("disabled", true)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.18)
	tween.tween_property(self, "modulate:a", 0.0, 0.28)
	tween.tween_property(self, "position:y", position.y - 14, 0.28)
	tween.chain().tween_callback(queue_free)
