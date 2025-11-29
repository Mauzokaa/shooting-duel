extends CharacterBody2D
class_name PlayerBase

@export var is_bot := false
@export var speed := 300.0
@export var jump_velocity := -450
@export var max_health := 100
@export var control_prefix := ""
@export var dash_speed := 800.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0
@export var start_facing_left := false

var current_health := 100
var gravity := 980.0
var can_shoot := true
var shoot_cooldown := 1.5
var facing_direction := Vector2.RIGHT

var is_dashing := false
var can_dash := true
var is_crouching := false
var is_dead := false

var is_wall_grabbing := false
var wall_grab_time := 0.3
var wall_grab_timer := 0.0
var was_touching_wall := false

var bot_move_timer := 0.0
var bot_move_interval := 2.5
var bot_direction := Vector2.RIGHT

signal player_died(player_name)

@onready var standing_sprite = $StandingSprite
@onready var crouching_sprite = $CrouchingSprite
@onready var dash_effect = $DashEffect
@onready var standing_shape = $StandingShape
@onready var crouching_shape = $CrouchingShape
@onready var ground_check_left = $GroundCheckLeft
@onready var ground_check_right = $GroundCheckRight
@onready var platform_check = $PlatformCheck
@onready var muzzle = $Muzzle

func _ready():
	if has_node("Camera2D"):
		var cam = $Camera2D
		cam.make_current()
	add_to_group("players")
	#position = Vector2(960, 540)
	current_health = max_health

	standing_sprite.play("idle")
	crouching_sprite.visible = false
	standing_shape.disabled = false
	crouching_shape.disabled = true

	facing_direction = Vector2.RIGHT if global_position.x < get_viewport_rect().size.x / 2 else Vector2.LEFT
	standing_sprite.flip_h = facing_direction == Vector2.LEFT
	crouching_sprite.flip_h = facing_direction == Vector2.LEFT

func _physics_process(delta):
	if is_dead:
		return

	if is_bot:
		process_bot(delta)
	else:
		process_player(delta)

func process_player(delta):
	is_crouching = Input.is_action_pressed(control_prefix + "crouch")

	standing_sprite.visible = not is_crouching
	crouching_sprite.visible = is_crouching
	standing_shape.disabled = is_crouching
	crouching_shape.disabled = not is_crouching

	var touching_wall := is_on_wall() and not is_on_floor()
	if touching_wall and not was_touching_wall and velocity.y > 0:
		is_wall_grabbing = true
		wall_grab_timer = wall_grab_time
		velocity.y = 0

	if is_wall_grabbing:
		wall_grab_timer -= delta
		if wall_grab_timer <= 0 or is_on_floor():
			is_wall_grabbing = false

	was_touching_wall = touching_wall

	if is_crouching:
		velocity.x = 0
	else:
		var direction = Input.get_axis(control_prefix + "ui_left", control_prefix + "ui_right")
		if not is_dashing:
			if direction:
				velocity.x = direction * speed
				facing_direction = Vector2.RIGHT if direction > 0 else Vector2.LEFT
			else:
				velocity.x = move_toward(velocity.x, 0, speed)

	if not is_on_floor():
		if is_wall_grabbing and wall_grab_timer > 0:
			velocity.y = 0
		else:
			velocity.y += gravity * delta

	if Input.is_action_just_pressed(control_prefix + "ui_up") or Input.is_action_just_pressed(control_prefix + "jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif is_wall_grabbing and wall_grab_timer > 0:
			velocity.y = jump_velocity
			velocity.x = -facing_direction.x * speed
			is_wall_grabbing = false
			wall_grab_timer = 0

	if Input.is_action_just_pressed(control_prefix + "dash"):
		dash()

	move_and_slide()

	if Input.is_action_just_pressed(control_prefix + "shoot") and can_shoot and not is_crouching:
		shoot()

	if standing_sprite.animation == "die":
		return
	elif is_crouching:
		crouching_sprite.play("crouch")
	elif is_wall_grabbing and wall_grab_timer > 0:
		standing_sprite.play("wall_grab")
	elif standing_sprite.animation == "attack" and standing_sprite.is_playing():
		pass
	elif standing_sprite.animation == "dash" and standing_sprite.is_playing():
		pass
	elif not is_on_floor():
		standing_sprite.play("jump")
	elif abs(velocity.x) > 10:
		standing_sprite.play("run")
	else:
		standing_sprite.play("idle")

	standing_sprite.flip_h = facing_direction == Vector2.LEFT
	crouching_sprite.flip_h = facing_direction == Vector2.LEFT

func process_bot(delta):
	var target: CharacterBody2D = null
	for p in get_tree().get_nodes_in_group("players"):
		if p != self and not p.is_dead:
			target = p
			break
	if target == null:
		return

	var dir := (target.global_position - global_position).normalized()
	var dist := global_position.distance_to(target.global_position)

	# direção principal seguindo o alvo
	bot_direction = Vector2.RIGHT if dir.x >= 0.0 else Vector2.LEFT

	# raycasts alinhados à direção
	var ground_check = ground_check_right if bot_direction.x > 0 else ground_check_left
	ground_check.force_raycast_update()

	platform_check.position.x = 40 if bot_direction.x > 0 else -40
	platform_check.target_position = Vector2(10, 45) if bot_direction.x > 0 else Vector2(-10, 45)

	platform_check.force_raycast_update()

	# MOVIMENTO base: anda na direção do alvo
	velocity.x = bot_direction.x * speed

	# segurança: se não há chão à frente, para
	if not ground_check.is_colliding():
		velocity.x = 0

	# JUMP: degrau à frente ou decisão tática
	if is_on_floor():
		var should_jump_edge = (not ground_check.is_colliding()) and platform_check.is_colliding()
		var should_jump_tactical = (dist < 220.0 and randf() < 0.06)
		if should_jump_edge or should_jump_tactical:
			velocity.y = jump_velocity
			velocity.x = bot_direction.x * speed * 1.15

	# GRAVIDADE
	if not is_on_floor():
		velocity.y += gravity * delta

	# TIRO
	if can_shoot and dist < 500.0:
		facing_direction = Vector2.RIGHT if bot_direction.x > 0 else Vector2.LEFT
		shoot()

	# DASH
	if can_dash and dist < 180.0 and randf() < 0.05:
		dash()

	# ANIMAÇÕES
	if not is_on_floor():
		standing_sprite.play("jump")
	elif abs(velocity.x) > 10:
		standing_sprite.play("run")
	else:
		standing_sprite.play("idle")

	standing_sprite.flip_h = facing_direction == Vector2.LEFT
	crouching_sprite.flip_h = standing_sprite.flip_h

	move_and_slide()

func shoot():
	pass # será sobrescrito nos scripts específicos

func dash():
	if not can_dash or is_dashing:
		return

	is_dashing = true
	can_dash = false

	velocity.x = facing_direction.x * dash_speed
	standing_sprite.play("dash")

	if dash_effect and dash_effect.process_material:
		dash_effect.process_material.direction = Vector3(facing_direction.x, 0.0, 0.0)
		dash_effect.position = Vector2(-facing_direction.x * 30, 0)
	dash_effect.emitting = true

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func take_damage(amount):
	if current_health <= 0 or is_dead:
		return

	current_health -= amount
	current_health = max(current_health, 0)

	print(name, "tomou", amount, "de dano. Vida restante:", current_health)

	standing_sprite.modulate = Color.RED
	crouching_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	standing_sprite.modulate = Color.WHITE
	crouching_sprite.modulate = Color.WHITE

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	standing_sprite.play("die")
	set_physics_process(false)
	standing_shape.disabled = true
	crouching_shape.disabled = true

	await standing_sprite.animation_finished
	emit_signal("player_died", name)

	var alive_players = []
	for p in get_tree().get_nodes_in_group("players"):
		if not p.is_dead:
			alive_players.append(p)

	if alive_players.size() == 1:
		var winner = alive_players[0]
		if get_tree().has_method("_on_player_died"):
			get_tree().call("_on_player_died", name)

	await get_tree().process_frame
	queue_free()

func _on_standing_sprite_animation_finished(anim_name):
	if anim_name == "attack" or anim_name == "dash":
		standing_sprite.play("idle")
