extends PanelContainer

signal selected(level_id: String)

@onready var ods_num: Label = $Margin/VBox/OdsNum
@onready var ods_name: Label = $Margin/VBox/OdsName
@onready var bioma: Label = $Margin/VBox/Bioma
@onready var status: Label = $Margin/VBox/Status
@onready var button: Button = $Margin/VBox/PlayButton

var _level_id: String = ""

func setup(level_id: String, data: Dictionary, completed: bool) -> void:
	_level_id = level_id
	# defer until @onready runs
	if not is_node_ready():
		await ready
	ods_num.text = "ODS %02d" % data["ods_number"]
	ods_name.text = data["ods_name"]
	bioma.text = data["display_name"]
	status.text = "✓ concluído" if completed else "—"
	status.modulate = Color(0.40, 0.92, 0.62) if completed else Color(0.45, 0.50, 0.58)
	button.pressed.connect(func(): selected.emit(_level_id))

func _on_mouse_entered() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 2, 0.15)

func _on_mouse_exited() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y + 2, 0.15)
