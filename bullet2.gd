extends Area2D
class_name Bullet2

@export var explosion_area_scene: PackedScene
@export var explosion_radius := 50.0
@export var damage := 20
@export var speed := 600.0
@export var bullet_gravity := 500.0

var velocity := Vector2.ZERO
var shooter = null

func _ready():
	add_to_group("bullets")

	# Aplica rotação inicial
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()

	print("Bala explosiva criada em:", global_position)
	print("Velocidade inicial:", velocity)

	# Tempo de vida da bala
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	if velocity == Vector2.ZERO:
		return

	# Aplica gravidade e movimento
	velocity.y += bullet_gravity * delta
	position += velocity * delta

	# Atualiza rotação conforme trajetória
	rotation = velocity.angle()

func _on_body_entered(body):
	if body == shooter:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
	elif body.get_owner() and body.get_owner().has_method("take_damage"):
		body.get_owner().take_damage(damage)

	spawn_explosion_area()
	queue_free()

	if body.is_in_group("walls"):
		spawn_explosion_area()
		queue_free()

func spawn_explosion_area():
	if explosion_area_scene == null:
		return

	var explosion = explosion_area_scene.instantiate()
	explosion.global_position = global_position
	explosion.damage = damage
	explosion.shooter = shooter

	var shape = explosion.get_node("CollisionShape2D").shape
	if shape is CircleShape2D:
		shape.radius = explosion_radius

	get_parent().add_child(explosion)
