extends CharacterBody2D

enum BossState {
	walk,
	attack,
	stagger,
	defeated
}

const SPINNING_BONE = preload("res://entities/spinning_bone.tscn")

@export var level_id: String = ""
@export var max_hp: int = 4
@export var move_speed: float = 22.0
@export var attack_speed_mul: float = 2.2
@export var tint: Color = Color(1.0, 0.55, 0.45, 1.0)
@export var stagger_duration: float = 0.35
@export var knockback_velocity: float = -260.0
@export var external_run_base: String = ""
@export var external_run_count: int = 0
@export var external_idle_base: String = ""
@export var external_idle_count: int = 0
@export var external_frame_speed: float = 6.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var hp_bar: Node2D = $HpBar
@onready var hp_fill: ColorRect = $HpBar/Fill
@onready var hp_back: ColorRect = $HpBar/Back

var status: BossState
var direction: int = 1
var can_throw: bool = true
var current_hp: int = 0
var _stagger_t: float = 0.0

func _ready() -> void:
	current_hp = max_hp
	_apply_external_frames()
	anim.modulate = tint
	scale = Vector2(1.5, 1.5)
	_refresh_hp_bar()
	if level_id != "":
		GameState.report_boss_hp(level_id, current_hp, max_hp)
	go_to_walk_state()

func _apply_external_frames() -> void:
	var run_frames: Array[Texture2D] = _load_frames(external_run_base, external_run_count)
	var idle_frames: Array[Texture2D] = _load_frames(external_idle_base, external_idle_count)
	if run_frames.is_empty() and idle_frames.is_empty():
		return
	if run_frames.is_empty():
		run_frames = idle_frames
	if idle_frames.is_empty():
		idle_frames = run_frames
	var sf := SpriteFrames.new()
	# walk uses run frames (loops)
	sf.add_animation("walk")
	sf.set_animation_loop("walk", true)
	sf.set_animation_speed("walk", external_frame_speed)
	for tex in run_frames:
		sf.add_frame("walk", tex)
	# attack uses idle frames (loops slow — boss stops to "wind up" projectile)
	sf.add_animation("attack")
	sf.set_animation_loop("attack", false)
	sf.set_animation_speed("attack", external_frame_speed * 0.7)
	for tex in idle_frames:
		sf.add_frame("attack", tex)
	# hurt uses first idle frame
	sf.add_animation("hurt")
	sf.set_animation_loop("hurt", false)
	sf.set_animation_speed("hurt", external_frame_speed)
	sf.add_frame("hurt", idle_frames[0])
	if sf.has_animation("default"):
		sf.remove_animation("default")
	anim.sprite_frames = sf

func _load_frames(base: String, count: int) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	if base == "" or count <= 0:
		return out
	for i in range(count):
		var path: String = "%s%d.png" % [base, i]
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path) as Texture2D
		if tex != null:
			out.append(tex)
	return out

func _physics_process(delta: float) -> void:
	if status == BossState.defeated:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		BossState.walk:
			walk_state(delta)
		BossState.attack:
			attack_state(delta)
		BossState.stagger:
			stagger_state(delta)

	move_and_slide()

func go_to_walk_state() -> void:
	status = BossState.walk
	anim.play("walk")
	anim.speed_scale = 1.0

func go_to_attack_state() -> void:
	status = BossState.attack
	anim.play("attack")
	anim.speed_scale = attack_speed_mul
	velocity = Vector2.ZERO
	can_throw = true

func go_to_stagger_state() -> void:
	status = BossState.stagger
	anim.play("hurt")
	anim.speed_scale = 1.0
	velocity = Vector2(0, knockback_velocity * 0.5)
	_stagger_t = stagger_duration

func go_to_defeated_state() -> void:
	status = BossState.defeated
	anim.stop()
	anim.play("hurt")
	anim.speed_scale = 0.6
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	hp_bar.visible = false
	if level_id != "":
		GameState.defeat_boss(level_id)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)

func walk_state(_delta: float) -> void:
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = move_speed * direction
	else:
		velocity.x = 0

	if wall_detector.is_colliding():
		_flip()

	if not ground_detector.is_colliding():
		_flip()

	if player_detector.is_colliding():
		go_to_attack_state()

func attack_state(_delta: float) -> void:
	if anim.frame == 2 and can_throw:
		_throw_bone()
		can_throw = false

func stagger_state(delta: float) -> void:
	_stagger_t -= delta
	if _stagger_t <= 0.0:
		if current_hp <= 0:
			go_to_defeated_state()
		else:
			go_to_walk_state()

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
	go_to_stagger_state()

func _flip() -> void:
	scale.x *= -1
	direction *= -1

func _throw_bone() -> void:
	var new_bone := SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	if new_bone.has_method("set_direction"):
		new_bone.set_direction(direction)

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
	tween.tween_property(anim, "modulate", original, 0.18)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
