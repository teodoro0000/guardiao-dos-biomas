extends PanelContainer

signal focused(character_id: String)
signal chosen(character_id: String)

@onready var name_label: Label = $Margin/VBox/Name
@onready var portrait: TextureRect = $Margin/VBox/Portrait
@onready var indicator: ColorRect = $Margin/VBox/Indicator
@onready var button: Button = $Margin/VBox/PickButton

var character_id: String = ""
var _accent: Color = Color.WHITE

func setup(char_id: String, data: Dictionary, is_selected: bool) -> void:
	character_id = char_id
	if not is_node_ready():
		await ready
	name_label.text = data["display_name"]
	_accent = data["accent_color"]
	indicator.color = _accent
	name_label.modulate = _accent
	var portrait_tex: Texture2D = GameState.get_character_portrait(char_id)
	if portrait_tex != null:
		portrait.texture = portrait_tex
	set_selected(is_selected)
	button.pressed.connect(func():
		chosen.emit(character_id)
		focused.emit(character_id)
	)

func set_selected(is_selected: bool) -> void:
	if not is_node_ready():
		await ready
	indicator.visible = is_selected
	modulate = Color(1, 1, 1, 1) if is_selected else Color(0.65, 0.65, 0.70, 1.0)

func _on_mouse_entered() -> void:
	focused.emit(character_id)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 2, 0.15)

func _on_mouse_exited() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y + 2, 0.15)
