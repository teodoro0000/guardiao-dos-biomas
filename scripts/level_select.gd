extends Control

@onready var cards_container: HBoxContainer = $Layout/Content/Cards
@onready var back_button: Button = $Layout/Content/BackButton

const CARD_SCENE := preload("res://ui/level_card.tscn")

func _ready() -> void:
	back_button.pressed.connect(func(): GameState.go_to_main_menu())
	_populate_cards()
	GameState.apply_pixel_font(self)

func _populate_cards() -> void:
	for level_id in GameState.LEVEL_ORDER:
		var data: Dictionary = GameState.LEVELS[level_id]
		var card := CARD_SCENE.instantiate()
		card.setup(level_id, data, GameState.is_completed(level_id))
		card.selected.connect(_on_card_selected)
		cards_container.add_child(card)

func _on_card_selected(level_id: String) -> void:
	GameState.go_to_level(level_id)
