extends Node

@export var player1_scene: PackedScene
@export var player2_scene: PackedScene
@export var spawn_points: Array[Node2D]
@export var max_health := 100
@export var max_rounds := 5
@export var round_end_screen: PackedScene
@export var victory_screen: PackedScene

var scores := {}
var current_round := 1

func start_round():
	print("Rodada", current_round, "iniciada!")

	# Remove jogadores antigos
	for p in get_tree().get_nodes_in_group("players"):
		if is_instance_valid(p):
			p.queue_free()

	await get_tree().process_frame

	# Dicionário de shooters disponíveis
	var available_shooters := {
		"Yumi": preload("res://player.tscn"),
		"Gab": preload("res://PlayerBase.tscn")
		# adicione aqui outros personagens se tiver
	}

	# Instancia novos jogadores com base no GameSettings
	for i in range(spawn_points.size()):
		var player: CharacterBody2D
		var shooter_name = GameSettings.selected_shooters.get("Player" + str(i+1), "Yumi")

		if available_shooters.has(shooter_name):
			player = available_shooters[shooter_name].instantiate()
		else:
			player = player1_scene.instantiate() # fallback

		if GameSettings.mode == "vs_bot":
			if i == 0:
				# Player1 (você)
				player.control_prefix = ""   # usa os controles padrão
				player.is_bot = false
			else:
				# Player2 (computador)
				player.control_prefix = "p2_"  # prefixo opcional, se quiser separar
				player.is_bot = true

		elif GameSettings.mode == "pvp":
			player.control_prefix = "" if i == 0 else "p2_"
			player.is_bot = false

		player.name = "Player" + str(i + 1)
		player.position = spawn_points[i].position
		player.max_health = max_health
		player.current_health = max_health

		player.connect("player_died", Callable(self, "_on_player_died"))
		add_child(player)
		player.add_to_group("players")

		if not scores.has(player.name):
			scores[player.name] = 0


func _ready():
	for i in range(spawn_points.size()):
		print("Spawn", i, ":", spawn_points[i].position)


func _on_player_died(player_name):
	print("💀", player_name, "morreu!")

	# Atualiza placar
	for player_key in scores.keys():
		if player_key != player_name:
			scores[player_key] += 1

	print("Placar:", scores)
	var winner_node: Node = null
	for p in get_tree().get_nodes_in_group("players"):
		if is_instance_valid(p) and "is_dead" in p and not p.is_dead:
			winner_node = p
			break

	var winner_name: String = winner_node.name if winner_node else "Desconhecido"
	var winner_image: Texture = null
	if winner_node and winner_node.has_node("Portrait"):
		var portrait_node = winner_node.get_node("Portrait")
		if portrait_node is TextureRect or portrait_node is Sprite2D:
			winner_image = portrait_node.texture

	await get_tree().process_frame
	await get_tree().process_frame

	# Mostra tela de fim de rodada
	if _round_over():
		if round_end_screen:
			var screen = round_end_screen.instantiate()
			add_child(screen)
			if screen.has_method("show_result"):
				screen.show_result(winner_name, scores, winner_image)
			await get_tree().create_timer(2.5).timeout
			if screen.has_method("hide_screen"):
				screen.hide_screen()
			screen.queue_free()

		current_round += 1
		if current_round <= max_rounds:
			start_round()
		else:
			game_over()
	else:
		print("Rodada ainda não acabou.")

func _round_over() -> bool:
	var vivos := 0
	for p in get_tree().get_nodes_in_group("players"):
		if is_instance_valid(p) and "is_dead" in p and not p.is_dead:
			vivos += 1
	return vivos <= 1

func game_over():
	print("Jogo finalizado!")
	print("Placar final:", scores)

	var winner := ""
	var max_score := -1
	for player_key in scores.keys():
		if scores[player_key] > max_score:
			max_score = scores[player_key]
			winner = player_key

	# Descobre qual personagem o vencedor escolheu
	var shooter_name = GameSettings.selected_shooters.get(winner, "Yumi")

	# Carrega a imagem correta com base no personagem escolhido
	var winner_image: Texture = null
	var image_paths := {
		"Yumi": "res://personagens/yumi/yumi.png",
		"Gab": "res://personagens/gab/gab.png"
	}

	if image_paths.has(shooter_name):
		var path = image_paths[shooter_name]
		if ResourceLoader.exists(path):
			winner_image = load(path)

	# Instancia VictoryScreen e envia os dados
	if victory_screen:
		var screen = victory_screen.instantiate()
		add_child(screen)
		if screen.has_method("show_victory"):
			screen.show_victory(winner, scores, winner_image)
