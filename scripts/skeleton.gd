extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	hurt
}

const SPINNING_BONE = preload("res://entities/spinning_bone.tscn")
const KENNEY_ATLAS_PATH := "res://kenney_pixel-platformer/Tilemap/tilemap-characters_packed.png"

@export var enemy_sprite_region: Rect2 = Rect2(0, 0, 0, 0)
@export var enemy_tint: Color = Color(1, 1, 1, 1)
@export var enemy_sprite_offset_y: float = 4.0
@export var external_frame_base: String = ""
@export var external_frame_count: int = 0
@export var external_frame_speed: float = 6.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

const SPEED = 7.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState

var direction = 1
var can_throw = true

func _ready() -> void:
	_apply_enemy_sprite()
	go_to_walk_state()

func _apply_enemy_sprite() -> void:
	if external_frame_base != "" and external_frame_count > 0:
		_apply_external_frames()
		return
	if enemy_sprite_region.size == Vector2.ZERO:
		return
	_apply_kenney_atlas()

func _apply_kenney_atlas() -> void:
	if not ResourceLoader.exists(KENNEY_ATLAS_PATH):
		return
	var atlas: Texture2D = load(KENNEY_ATLAS_PATH)
	if atlas == null:
		return
	var sf := SpriteFrames.new()
	for anim_name in ["walk", "attack", "hurt"]:
		sf.add_animation(anim_name)
		sf.set_animation_loop(anim_name, anim_name == "walk")
		sf.set_animation_speed(anim_name, 4.0 if anim_name == "walk" else 5.0)
		var tex := AtlasTexture.new()
		tex.atlas = atlas
		tex.region = enemy_sprite_region
		tex.filter_clip = true
		sf.add_frame(anim_name, tex)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	anim.sprite_frames = sf
	anim.position.y += enemy_sprite_offset_y
	anim.modulate = enemy_tint
	# Static sprite — fake "alive" feel with vertical bobbing.
	var tween := create_tween().set_loops()
	tween.tween_property(anim, "position:y", anim.position.y - 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(anim, "position:y", anim.position.y, 0.4).set_trans(Tween.TRANS_SINE)

func _apply_external_frames() -> void:
	var frames: Array[Texture2D] = []
	for i in range(external_frame_count):
		var path: String = "%s%d.png" % [external_frame_base, i]
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path) as Texture2D
		if tex != null:
			frames.append(tex)
	if frames.is_empty():
		return
	var sf := SpriteFrames.new()
	for anim_name in ["walk", "attack", "hurt"]:
		sf.add_animation(anim_name)
		sf.set_animation_loop(anim_name, anim_name != "hurt")
		sf.set_animation_speed(anim_name, external_frame_speed)
		for tex in frames:
			sf.add_frame(anim_name, tex)
	if sf.has_animation("default"):
		sf.remove_animation("default")
	anim.sprite_frames = sf
	anim.position.y += enemy_sprite_offset_y
	anim.modulate = enemy_tint

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.hurt:
			hurt_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")
	
func go_to_attack_state():
	status = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	
func go_to_hurt_state():
	status = SkeletonState.hurt
	anim.play("hurt")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding():
		go_to_attack_state()
		return

func attack_state(_delta):
	if anim.frame == 2 && can_throw:
		throw_bone()
		can_throw = false

func hurt_state(_delta):
	pass
	
func take_damage():
	go_to_hurt_state()
	
func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return
