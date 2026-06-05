extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	wall,
	swimming,
	hurt
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector

@onready var reload_timer: Timer = $ReloadTimer

@export var max_speed = 180.0
@export var acceleration = 400
@export var deceleration = 400
@export var slide_deceleration = 100
@export var wall_acceleration = 40
@export var wall_jump_velocity = 240
@export var water_max_speed = 100
@export var water_acceleration = 200
@export var water_jump_force = -100

@export var jump_velocity: float = -300.0

var jump_count = 0
@export var max_jump_count = 2
var direction = 0
var status: PlayerState
var carried_trash: Node = null

const PROJECTILE = preload("res://entities/player_projectile.tscn")
const ATTACK_COOLDOWN := 0.35
const RESPAWN_INVULN_TIME := 3.0
var _facing: int = 1
var _attack_t: float = 0.0
var _invuln_t: float = 0.0

func _ready() -> void:
	_apply_character_modifiers()
	_apply_character_sprite()
	_apply_checkpoint_respawn()
	go_to_idle_state()

func _apply_checkpoint_respawn() -> void:
	var lvl := GameState.current_level_id
	if lvl == "" or not GameState.has_checkpoint(lvl):
		return
	global_position = GameState.get_checkpoint(lvl)
	_start_respawn_invulnerability()

func _start_respawn_invulnerability() -> void:
	_invuln_t = RESPAWN_INVULN_TIME
	var tween := create_tween().set_loops(int(RESPAWN_INVULN_TIME / 0.2))
	tween.tween_property(anim, "modulate:a", 0.35, 0.1)
	tween.tween_property(anim, "modulate:a", 1.0, 0.1)

func _apply_character_sprite() -> void:
	var sf: SpriteFrames = GameState.get_character_sprite_frames(GameState.selected_character)
	if sf == null:
		return
	anim.sprite_frames = sf
	# Pixel Adventure sprites are 32x32 vs original Penguin 16x16.
	# Offset by -8 so feet align with the existing 16x16 collider bottom.
	anim.offset = Vector2(0, -8)

func _apply_character_modifiers() -> void:
	max_speed *= GameState.get_character_modifier("max_speed_mul", 1.0)
	jump_velocity *= GameState.get_character_modifier("jump_velocity_mul", 1.0)

func _physics_process(delta: float) -> void:
	_attack_t = max(0.0, _attack_t - delta)
	_invuln_t = max(0.0, _invuln_t - delta)
	if _invuln_t == 0.0 and anim.modulate.a != 1.0:
		anim.modulate.a = 1.0
	if status != PlayerState.hurt and Input.is_action_just_pressed("attack") and _attack_t <= 0.0:
		_fire_projectile()

	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.wall:
			wall_state(delta)
		PlayerState.swimming:
			swimming_state(delta)
		PlayerState.hurt:
			hurt_state(delta)
			
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = jump_velocity
	jump_count += 1
	GameState.play_sfx("double_jump" if jump_count > 1 else "jump")
	
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	
func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	set_small_collider()
	
func exit_from_duck_state():
	set_large_collider()
	
func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	set_small_collider()
	
func exit_from_slide_state():
	set_large_collider()
	
func go_to_wall_state():
	status = PlayerState.wall
	anim.play("wall")
	velocity = Vector2.ZERO
	jump_count = 0
	
func go_to_swimming_state():
	status = PlayerState.swimming
	anim.play("swimming")
	velocity.y = min(velocity.y, 150)
	
func go_to_hurt_state():
	if status == PlayerState.hurt:
		return

	status = PlayerState.hurt
	anim.play("hurt")
	velocity.x = 0
	reload_timer.start()
	GameState.play_sfx("hurt")

func idle_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
	
func walk_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
		
func jump_state(delta):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if velocity.y > 0:
		go_to_fall_state()
		return
		
func fall_state(delta):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
		
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) && is_on_wall():
		go_to_wall_state()
		return
		
func duck_state(delta):
	apply_gravity(delta)
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
func slide_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return
		
func wall_state(delta):
	
	velocity.y += wall_acceleration * delta
	
	if left_wall_detector.is_colliding():
		anim.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return
	
	if is_on_floor():
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()
		return
		
func swimming_state(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, water_max_speed * direction, water_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)
		
	velocity.y += water_acceleration * delta
	velocity.y = min(velocity.y, water_max_speed)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = water_jump_force
		
func hurt_state(delta):
	apply_gravity(delta)

func move(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
		_facing = -1
	elif direction > 0:
		anim.flip_h = false
		_facing = 1

func _fire_projectile() -> void:
	_attack_t = ATTACK_COOLDOWN
	var p := PROJECTILE.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position + Vector2(_facing * 8.0, -2.0)
	if p.has_method("set_direction"):
		p.set_direction(_facing)
	GameState.play_sfx("attack")

func can_jump() -> bool:
	return jump_count < max_jump_count

func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3
	
func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		if _invuln_t > 0.0:
			return
		go_to_hurt_state()
	elif body.is_in_group("Water"):
		go_to_swimming_state()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		# inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	elif _invuln_t > 0.0:
		# respawn invulnerability — ignore damage
		return
	else:
		# player morre
		go_to_hurt_state()

func hit_lethal_area():
	if _invuln_t > 0.0:
		return
	go_to_hurt_state()

func _on_reload_timer_timeout() -> void:
	if GameState.lose_life():
		GameState.play_sfx("restart")
		GameState.reload_current_level()
	else:
		GameState.play_sfx("death")
		GameState.go_to_game_over()

func can_pickup_trash() -> bool:
	return carried_trash == null

func set_carried_trash(item: Node) -> void:
	carried_trash = item

func get_carried_trash() -> Node:
	return carried_trash

func deposit_trash() -> void:
	if carried_trash and is_instance_valid(carried_trash):
		carried_trash.queue_free()
	carried_trash = null

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		jump_count = 0
		go_to_jump_state()
