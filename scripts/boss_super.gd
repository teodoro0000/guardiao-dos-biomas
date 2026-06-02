extends CharacterBody2D

enum BossState {
	hover,
	charge,
	smash,
	recover,
	stagger,
	defeated
}

const ANIM_SPECS := [
	{"name": "idle",   "sheet": preload("res://sprites/Enemy3/Enemy3-No-Movement-In-Animation/Enemy3No-Move-Idle.png"),            "frames": 8,  "speed": 8.0,  "loop": true},
	{"name": "fly",    "sheet": preload("res://sprites/Enemy3/Enemy3-No-Movement-In-Animation/Enemy3No-Move-Fly.png"),             "frames": 8,  "speed": 10.0, "loop": true},
	{"name": "attack", "sheet": preload("res://sprites/Enemy3/Enemy3-No-Movement-In-Animation/Enemy3No-Move-AttackSmashLoop.png"), "frames": 3,  "speed": 10.0, "loop": true},
	{"name": "hurt",   "sheet": preload("res://sprites/Enemy3/Enemy3-No-Movement-In-Animation/Enemy3No-Move-Hit.png"),             "frames": 4,  "speed": 12.0, "loop": false},
	{"name": "die",    "sheet": preload("res://sprites/Enemy3/Enemy3-No-Movement-In-Animation/Enemy3No-Move-Die.png"),             "frames": 17, "speed": 14.0, "loop": false},
]

@export var level_id: String = "final"
@export var max_hp: int = 8
@export var altitude_y: float = 80.0
@export var floor_y: float = 165.0
@export var horizontal_speed: float = 42.0
@export var smash_speed: float = 320.0
@export var rise_speed: float = 140.0
@export var attack_cooldown: float = 1.7
@export var smash_vulnerable_time: float = 0.65
@export var stagger_duration: float = 0.4
@export var tint: Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hp_bar: Node2D = $HpBar
@onready var hp_fill: ColorRect = $HpBar/Fill
@onready var hp_back: ColorRect = $HpBar/Back

var status: BossState
var current_hp: int = 0
var _cooldown_t: float = 0.0
var _stagger_t: float = 0.0
var _vulnerable_t: float = 0.0
var _player_ref: Node2D = null

func _ready() -> void:
	current_hp = max_hp
	_build_sprite_frames()
	anim.modulate = tint
	_refresh_hp_bar()
	if level_id != "":
		GameState.report_boss_hp(level_id, current_hp, max_hp)
	_cooldown_t = attack_cooldown * 0.6
	_find_player()
	go_to_hover()

func _build_sprite_frames() -> void:
	var sf := SpriteFrames.new()
	for spec in ANIM_SPECS:
		var sheet: Texture2D = spec["sheet"]
		if sheet == null:
			continue
		sf.add_animation(spec["name"])
		sf.set_animation_speed(spec["name"], spec["speed"])
		sf.set_animation_loop(spec["name"], spec["loop"])
		for i in range(spec["frames"]):
			var tex := AtlasTexture.new()
			tex.atlas = sheet
			tex.region = Rect2(i * 64, 0, 64, 64)
			tex.filter_clip = true
			sf.add_frame(spec["name"], tex)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	anim.sprite_frames = sf

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		_player_ref = players[0]

func _physics_process(delta: float) -> void:
	if status == BossState.defeated:
		return
	if _player_ref == null or not is_instance_valid(_player_ref):
		_find_player()

	match status:
		BossState.hover:
			_hover_state(delta)
		BossState.charge:
			_charge_state(delta)
		BossState.smash:
			_smash_state(delta)
		BossState.recover:
			_recover_state(delta)
		BossState.stagger:
			_stagger_state(delta)

	move_and_slide()

func go_to_hover() -> void:
	status = BossState.hover
	anim.play("fly")
	velocity = Vector2.ZERO

func go_to_charge() -> void:
	status = BossState.charge
	anim.play("attack")
	velocity = Vector2.ZERO
	_cooldown_t = 0.6

func go_to_smash() -> void:
	status = BossState.smash
	anim.play("attack")

func go_to_recover() -> void:
	status = BossState.recover
	anim.play("fly")
	_vulnerable_t = 0.0

func go_to_stagger() -> void:
	status = BossState.stagger
	anim.play("hurt")
	velocity = Vector2(0, -120.0)
	_stagger_t = stagger_duration

func go_to_defeated() -> void:
	status = BossState.defeated
	anim.play("die")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	hp_bar.visible = false
	if level_id != "":
		GameState.defeat_boss(level_id)
	var tween := create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(_on_defeated_finished)

func _on_defeated_finished() -> void:
	GameState.complete_level(level_id)
	GameState.go_to_victory()
	queue_free()

func _hover_state(delta: float) -> void:
	_track_player_horizontally(delta)
	# Keep altitude.
	velocity.y = move_toward(velocity.y, (altitude_y - position.y) * 4.0, 200.0 * delta)
	_cooldown_t -= delta
	if _cooldown_t <= 0.0:
		go_to_charge()

func _charge_state(delta: float) -> void:
	velocity = Vector2.ZERO
	_cooldown_t -= delta
	if _cooldown_t <= 0.0:
		go_to_smash()

func _smash_state(delta: float) -> void:
	velocity.x = 0
	velocity.y = smash_speed
	if position.y >= floor_y:
		position.y = floor_y
		go_to_recover()

func _recover_state(delta: float) -> void:
	_vulnerable_t += delta
	if _vulnerable_t < smash_vulnerable_time:
		velocity = Vector2.ZERO
		return
	velocity.y = -rise_speed
	if position.y <= altitude_y:
		position.y = altitude_y
		velocity.y = 0
		_cooldown_t = attack_cooldown
		go_to_hover()

func _stagger_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 200.0 * delta)
	velocity.y += 200.0 * delta
	_stagger_t -= delta
	if _stagger_t <= 0.0:
		if current_hp <= 0:
			go_to_defeated()
		else:
			# Resume from where we are.
			if abs(position.y - altitude_y) < 6.0:
				go_to_hover()
			else:
				go_to_recover()

func _track_player_horizontally(delta: float) -> void:
	if _player_ref == null:
		velocity.x = 0
		return
	var dx: float = _player_ref.global_position.x - global_position.x
	var dir: float = sign(dx)
	if abs(dx) < 8.0:
		velocity.x = move_toward(velocity.x, 0, 200.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, dir * horizontal_speed, 120.0 * delta)
	if dir != 0:
		anim.flip_h = dir < 0

func take_damage() -> void:
	if status == BossState.defeated or status == BossState.stagger:
		return
	current_hp -= 1
	_refresh_hp_bar()
	if level_id != "":
		GameState.report_boss_hp(level_id, current_hp, max_hp)
	_flash_white()
	if current_hp <= 0:
		GameState.play_sfx("boss_defeat")
	else:
		GameState.play_sfx("boss_hit")
	go_to_stagger()

func _refresh_hp_bar() -> void:
	if hp_back == null or hp_fill == null:
		return
	var full_w: float = hp_back.size.x - 2.0
	var ratio: float = clamp(float(current_hp) / float(max(1, max_hp)), 0.0, 1.0)
	hp_fill.size.x = max(0.0, full_w * ratio)

func _flash_white() -> void:
	var original := anim.modulate
	anim.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_interval(0.08)
	tween.tween_property(anim, "modulate", original, 0.2)
