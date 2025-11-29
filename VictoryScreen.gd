extends CanvasLayer

@onready var winner_portrait_1 = $WinnerPortrait1
@onready var winner_portrait_2 = $WinnerPortrait2
@onready var victory_label = $VictoryLabel
@onready var final_score_label = $FinalScoreLabel
@onready var restart_button = $RestartButton
@onready var animation_player = $AnimationPlayer
@onready var fade_overlay = $FadeOverlay

func _ready():
	visible = false
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_victory(winner_name: String, scores: Dictionary, image: Texture):
	victory_label.text = "Vitória de " + winner_name + "!"
	final_score_label.text = "Placar final:\n" + _format_scores(scores)

	# Oculta ambos os retratos
	winner_portrait_1.visible = false
	winner_portrait_2.visible = false

	# Exibe o retrato correto com a imagem recebida
	if winner_name == "Player1":
		winner_portrait_1.texture = image
		winner_portrait_1.visible = true
	elif winner_name == "Player2":
		winner_portrait_2.texture = image
		winner_portrait_2.visible = true
	else:
		print("Nome do vencedor não reconhecido:", winner_name)

	visible = true
	animation_player.play("portrait_zoom")
	animation_player.play("fade_in")

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _format_scores(scores: Dictionary) -> String:
	var text := ""
	for player_name in scores.keys():
		text += player_name + ": " + str(scores[player_name]) + "\n"
	return text.strip_edges()
