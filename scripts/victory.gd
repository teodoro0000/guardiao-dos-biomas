extends Control

@onready var continue_button: Button = $Layout/ContinueButton
@onready var chest: AnimatedSprite2D = $Center/Chest
@onready var coin_a: AnimatedSprite2D = $Center/CoinA
@onready var coin_b: AnimatedSprite2D = $Center/CoinB
@onready var coin_c: AnimatedSprite2D = $Center/CoinC

func _ready() -> void:
	GameState.apply_pixel_font(self)
	MusicPlayer.play("menu")
	continue_button.pressed.connect(_on_continue)
	_animate_intro()

func _animate_intro() -> void:
	modulate.a = 0.0
	chest.scale = Vector2(0.1, 0.1)
	coin_a.modulate.a = 0.0
	coin_b.modulate.a = 0.0
	coin_c.modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.5)
	t.tween_property(chest, "scale", Vector2(3.0, 3.0), 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Stagger coin fade-ins.
	var coins := [coin_a, coin_b, coin_c]
	for i in range(coins.size()):
		var c: AnimatedSprite2D = coins[i]
		var delay := 0.4 + i * 0.18
		var ct := create_tween()
		ct.tween_interval(delay)
		ct.tween_property(c, "modulate:a", 1.0, 0.4)
		# Bounce each coin
		var bt := create_tween().set_loops()
		bt.tween_interval(delay)
		bt.tween_property(c, "position:y", c.position.y - 6.0, 0.6).set_trans(Tween.TRANS_SINE)
		bt.tween_property(c, "position:y", c.position.y, 0.6).set_trans(Tween.TRANS_SINE)

func _on_continue() -> void:
	GameState.go_to_credits()
