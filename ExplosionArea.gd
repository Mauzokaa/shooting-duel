extends Area2D

@export var damage := 20
var shooter = null

func _ready():
	monitoring = true
	monitorable = true
	connect("body_entered", _on_body_entered)

	print("monitoring:", monitoring)
	print("shape disabled:", get_node("CollisionShape2D").disabled)
	print("shape radius:", get_node("CollisionShape2D").shape.radius)
	print("collision mask:", collision_mask)

	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_body_entered(body):
	if body == shooter:
		return
	if body.has_method("take_damage"):
		print("Explosão atingiu via sinal:", body.name)
		body.take_damage(damage)
