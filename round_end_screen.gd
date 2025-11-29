extends CanvasLayer

@onready var portrait_display = $PortraitDisplay
@onready var result_label = $ResultLabel
@onready var score_label = $ScoreLabel

func show_result(winner_name: String, scores: Dictionary, image: Texture):
	# Atualiza textos
	result_label.text = "Vitória de " + winner_name + "!"
	score_label.text = "Placar:\n" + _format_scores(scores)

	# Verificações de imagem
	if image:
		portrait_display.texture = image
		portrait_display.visible = true
		print("Textura atribuída ao PortraitDisplay:", image)
	else:
		print("⚠️ Nenhuma imagem recebida para PortraitDisplay")
		portrait_display.visible = false

	# Verificações visuais
	print("Tamanho do PortraitDisplay:", portrait_display.size)
	print("Visível?", portrait_display.visible)

	# Torna a tela visível
	visible = true

func hide_screen():
	visible = false

func _format_scores(scores: Dictionary) -> String:
	var text := ""
	for player_name in scores.keys():
		text += player_name + ": " + str(scores[player_name]) + "\n"
	return text.strip_edges()
