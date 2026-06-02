extends Control

@onready var menu_button: Button = $Layout/Footer/MenuButton
@onready var replay_button: Button = $Layout/Footer/ReplayButton

func _ready() -> void:
	MusicPlayer.play("menu")
	menu_button.pressed.connect(_on_menu)
	replay_button.pressed.connect(_on_replay)
	GameState.apply_pixel_font(self)
	_animate_in()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

func _on_menu() -> void:
	GameState.reset_all()
	GameState.go_to_main_menu()

func _on_replay() -> void:
	GameState.reset_all()
	GameState.go_to_character_select()
