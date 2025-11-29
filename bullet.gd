extends RigidBody2D
class_name Bullet

@export var speed := 700
@export var max_bounces := 2
var bounce_count := 0
var shooter: Node = null
var last_bounce_time := 0.0
var shoot_direction := Vector2.ZERO

func _ready():
	add_to_group("bullets")
	contact_monitor = true
	max_contacts_reported = 4

	# Aplica velocidade e rotação
	if shoot_direction != Vector2.ZERO:
		linear_velocity = shoot_direction.normalized() * speed
		rotation = linear_velocity.angle()
		print("Direção aplicada no ready:", shoot_direction)
		print("Velocidade inicial:", linear_velocity)

	# Ignora colisão com o jogador que disparou
	if shooter and shooter is PhysicsBody2D:
		PhysicsServer2D.body_add_collision_exception(get_rid(), shooter.get_rid())

func _integrate_forces(state):
	var current_time = Time.get_ticks_msec()

	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)
		var normal = state.get_contact_local_normal(0)

		# Evita colisão com o próprio jogador
		if collider == shooter:
			return

		# Aplica dano se o alvo tiver método take_damage
		if collider.has_method("take_damage"):
			collider.take_damage(25)
			queue_free()
			return

		# Evita múltiplos ricochetes no mesmo frame
		if current_time - last_bounce_time < 50:
			return

		# Corrige ricochete invertido
		if normal.dot(linear_velocity) > 0:
			normal = -normal

		var angle_factor = normal.dot(linear_velocity.normalized())
		if abs(angle_factor) < 0.2:
			return

		# Ricochete limitado
		if bounce_count < max_bounces:
			var random_angle = randf_range(-0.05, 0.05)
			var bounced = linear_velocity.rotated(random_angle).bounce(normal).normalized() * speed

			linear_velocity = bounced
			rotation = linear_velocity.angle()
			bounce_count += 1
			last_bounce_time = current_time
		else:
			queue_free()
