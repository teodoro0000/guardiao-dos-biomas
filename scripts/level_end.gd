extends Area2D

@export var require_all_collectibles: bool = false
@export var require_boss_defeated: bool = false

@onready var portal: Node2D = $Portal
@onready var portal_sprite: AnimatedSprite2D = $Portal/PortalSprite
@onready var label: Label = $Portal/Label

var _player_inside: bool = false
var _completed: bool = false

const LOCKED_COLOR := Color(0.55, 0.60, 0.68, 1.0)
const UNLOCKED_COLOR := Color(0.40, 0.92, 0.62, 1.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.collectible_picked.connect(_on_collectible_picked)
	GameState.boss_defeated.connect(_on_boss_defeated)
	_refresh_visual()
	_start_pulse()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_player_inside = true
	_try_complete()

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_player_inside = false

func _on_collectible_picked(_level_id: String, _total: int, _target: int) -> void:
	_refresh_visual()
	if _player_inside:
		_try_complete()

func _on_boss_defeated(_level_id: String) -> void:
	_refresh_visual()
	if _player_inside:
		_try_complete()

func _try_complete() -> void:
	if _completed:
		return
	var level_id: String = GameState.current_level_id
	if require_all_collectibles:
		if GameState.get_collected(level_id) < GameState.get_target(level_id):
			return
	if require_boss_defeated:
		if not GameState.is_boss_defeated(level_id):
			return
	_completed = true
	GameState.play_sfx("victory")
	GameState.complete_level(level_id)
	call_deferred("_go_to_message", level_id)

func _go_to_message(level_id: String) -> void:
	GameState.go_to_ods_message(level_id)

func _is_unlocked() -> bool:
	var level_id: String = GameState.current_level_id
	if require_all_collectibles:
		if GameState.get_collected(level_id) < GameState.get_target(level_id):
			return false
	if require_boss_defeated:
		if not GameState.is_boss_defeated(level_id):
			return false
	return true

func _refresh_visual() -> void:
	if portal == null:
		return
	var unlocked := _is_unlocked()
	var color := UNLOCKED_COLOR if unlocked else LOCKED_COLOR
	portal_sprite.modulate = color
	label.modulate = color
	label.text = _lock_label_text(unlocked)

func _lock_label_text(unlocked: bool) -> String:
	if unlocked:
		return "PORTAL"
	var level_id: String = GameState.current_level_id
	if require_boss_defeated and not GameState.is_boss_defeated(level_id):
		return "VENÇA O CHEFE"
	if require_all_collectibles and GameState.get_collected(level_id) < GameState.get_target(level_id):
		return "COLETE TUDO"
	return "TRANCADO"

func _start_pulse() -> void:
	if portal == null or portal_sprite == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(portal_sprite, "scale", Vector2(0.62, 0.62), 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(portal_sprite, "scale", Vector2(0.55, 0.55), 0.9).set_trans(Tween.TRANS_SINE)
