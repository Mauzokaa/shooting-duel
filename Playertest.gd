extends CharacterBody2D

func _ready():
	add_to_group("players")

func take_damage(amount):
	print("Jogador tomou", amount, "de dano")
