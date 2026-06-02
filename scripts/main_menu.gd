extends Control

@onready var start_button: Button = $Layout/Content/StartButton
@onready var quit_button: Button = $Layout/Content/QuitButton
@onready var title_line_1: Label = $Layout/Content/TitleLine1
@onready var title_line_2: Label = $Layout/Content/TitleLine2

func _ready() -> void:
	GameState.apply_pixel_font(self)
	MusicPlayer.play("menu")
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	_animate_in()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)

	title_line_1.modulate.a = 0.0
	title_line_2.modulate.a = 0.0
	var t1 := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t1.tween_interval(0.15)
	t1.tween_property(title_line_1, "modulate:a", 1.0, 0.45)

	var t2 := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t2.tween_interval(0.30)
	t2.tween_property(title_line_2, "modulate:a", 1.0, 0.45)

func _on_start() -> void:
	GameState.reset_all()
	GameState.go_to_character_select()

func _on_quit() -> void:
	get_tree().quit()
