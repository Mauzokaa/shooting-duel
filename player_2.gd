extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -400.0
@export var max_health := 100
var current_health := 100

signal player_died(player_name)

var gravity := 980.0

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	current_health = max_health

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction = Input.get_axis("p2_left", "p2_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func take_damage(amount):
	current_health -= amount
	print(name, " levou dano! Vida restante:", current_health)
	if current_health <= 0:
		die()

func die():
	print(name, " morreu!")
	emit_signal("player_died", name)
	queue_free()
