extends Node2D

@export var level_id: String = ""
@export var extend_tilemaps: bool = false
@export var extension_offset_x: float = 540.0
@export var extension_count: int = 1

const HUD_SCENE := preload("res://ui/hud.tscn")

func _ready() -> void:
	if level_id == "":
		push_warning("Level: level_id não definido em " + scene_file_path)
		return

	if extend_tilemaps:
		_extend_tilemaps()

	GameState.enter_level(level_id)
	MusicPlayer.play(level_id)
	add_child(HUD_SCENE.instantiate())

func _extend_tilemaps() -> void:
	var tile_maps_node := get_node_or_null("TileMaps")
	if tile_maps_node == null:
		return
	var originals: Array = []
	for child in tile_maps_node.get_children():
		if child is TileMapLayer:
			originals.append(child)
	for i in range(extension_count):
		var step_offset := extension_offset_x * float(i + 1)
		for original in originals:
			var copy: TileMapLayer = original.duplicate()
			copy.position = original.position + Vector2(step_offset, 0)
			copy.name = original.name + "_ext%d" % (i + 1)
			tile_maps_node.add_child(copy)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.go_to_level_select()
