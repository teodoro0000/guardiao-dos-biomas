extends Control

@onready var cards_container: HBoxContainer = $Layout/Content/Cards
@onready var back_button: Button = $Layout/Content/Footer/BackButton
@onready var confirm_button: Button = $Layout/Content/Footer/ConfirmButton
@onready var details_name: Label = $Layout/Content/Details/Name
@onready var details_tagline: Label = $Layout/Content/Details/Tagline
@onready var details_power: Label = $Layout/Content/Details/Power
@onready var details_bioma: Label = $Layout/Content/Details/Bioma

const CARD_SCENE := preload("res://ui/character_card.tscn")

var _hovered_id: String = ""
var _cards: Array = []

func _ready() -> void:
	back_button.pressed.connect(func(): GameState.go_to_main_menu())
	confirm_button.pressed.connect(_on_confirm)
	_populate_cards()
	_focus_character(GameState.selected_character)
	GameState.apply_pixel_font(self)

func _populate_cards() -> void:
	for char_id in GameState.CHARACTER_ORDER:
		var data: Dictionary = GameState.CHARACTERS[char_id]
		var card := CARD_SCENE.instantiate()
		card.setup(char_id, data, char_id == GameState.selected_character)
		card.focused.connect(_focus_character)
		card.chosen.connect(_choose_character)
		cards_container.add_child(card)
		_cards.append(card)

func _focus_character(char_id: String) -> void:
	_hovered_id = char_id
	var data: Dictionary = GameState.CHARACTERS[char_id]
	details_name.text = data["display_name"]
	details_tagline.text = data["tagline"]
	details_power.text = "→  " + str(data["description"])
	details_bioma.text = str(data.get("bioma", ""))
	details_name.modulate = data["accent_color"]
	details_bioma.modulate = data["accent_color"]

func _choose_character(char_id: String) -> void:
	GameState.select_character(char_id)
	for c in _cards:
		c.set_selected(c.character_id == char_id)

func _on_confirm() -> void:
	GameState.select_character(_hovered_id if _hovered_id != "" else GameState.selected_character)
	GameState.go_to_level_select()
