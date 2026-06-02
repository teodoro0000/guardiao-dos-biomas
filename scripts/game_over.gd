extends Control

@onready var retry_button: Button = $Layout/Content/Buttons/RetryButton
@onready var menu_button: Button = $Layout/Content/Buttons/MenuButton

func _ready() -> void:
	GameState.apply_pixel_font(self)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	_animate_in()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_retry() -> void:
	var level_id := GameState.current_level_id
	GameState.lives = GameState.STARTING_LIVES
	GameState.lives_changed.emit(GameState.lives)
	if level_id == "":
		GameState.go_to_level_select()
	else:
		GameState.go_to_level(level_id)

func _on_menu() -> void:
	GameState.go_to_main_menu()
