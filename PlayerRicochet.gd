extends PlayerBase
class_name PlayerRicochet

@export var bullet_scene: PackedScene

func shoot():
	print("Disparo ricochete iniciado!")
	print("Posição do jogador:", global_position)
	print("Direção do mouse:", get_global_mouse_position())

	if bullet_scene == null:
		print("bullet_scene está nula")
		return

	can_shoot = false
	standing_sprite.play("attack")

	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - muzzle.global_position).normalized()

	facing_direction = Vector2.LEFT if shoot_direction.x < 0 else Vector2.RIGHT
	standing_sprite.flip_h = facing_direction == Vector2.LEFT
	crouching_sprite.flip_h = facing_direction == Vector2.LEFT

	var bullet = bullet_scene.instantiate()
	bullet.shooter = self
	bullet.shoot_direction = shoot_direction
	bullet.global_position = muzzle.global_position + shoot_direction * 10  #desloca um pouco para frente
	bullet.add_to_group("bullets")
	get_tree().root.add_child(bullet)

	print("Posição da bala:", bullet.global_position)
	print("Direção aplicada:", shoot_direction)

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
