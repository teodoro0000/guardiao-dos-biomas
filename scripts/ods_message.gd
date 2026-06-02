extends Control

@onready var eyebrow: Label = $Layout/Content/Eyebrow
@onready var ods_number: Label = $Layout/Content/OdsNumber
@onready var ods_name: Label = $Layout/Content/OdsName
@onready var fact_1: Label = $Layout/Content/Fact1
@onready var fact_2: Label = $Layout/Content/Fact2
@onready var action_label: Label = $Layout/Content/Action
@onready var continue_button: Button = $Layout/Content/Buttons/ContinueButton
@onready var menu_button: Button = $Layout/Content/Buttons/MenuButton

func _ready() -> void:
	var data: Dictionary = GameState.get_current_level_data()
	eyebrow.text = "VOCÊ ACABOU DE EXPLORAR"
	ods_number.text = "ODS %02d" % data["ods_number"]
	ods_name.text = data["ods_name"]
	fact_1.text = "→  " + str(data["fact_1"])
	fact_2.text = "→  " + str(data["fact_2"])
	action_label.text = str(data["action"])

	var next_id: String = data.get("next_level", "")
	if next_id == "":
		continue_button.text = "FINALIZAR"
	else:
		continue_button.text = "PRÓXIMA FASE  →"

	continue_button.pressed.connect(_on_continue)
	menu_button.pressed.connect(func(): GameState.go_to_level_select())
	GameState.apply_pixel_font(self)
	_animate_in()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_continue() -> void:
	var data: Dictionary = GameState.get_current_level_data()
	var next_id: String = data.get("next_level", "")
	if next_id == "":
		GameState.go_to_credits()
	else:
		GameState.go_to_level(next_id)
