extends Control
class_name MapSelection

signal map_chosen(map_name: String)
signal back_pressed

@onready var info_map1: Control = $InfoPanelMap1
@onready var info_map2: Control = $InfoPanelMap2
# FlorestaBot não terá InfoPanel

func _ready() -> void:
	# Garantir que os painéis não bloqueiem o clique dos botões
	info_map1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_map2.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Começa escondido
	info_map1.visible = false
	info_map2.visible = false

	# Conectar hover dos botões
	_connect_hover($VBoxContainer/Espacobutton, info_map1, "Espaço")
	_connect_hover($VBoxContainer/Florestabutton, info_map2, "Floresta")

	# FlorestaBot não tem InfoPanel → só imprime no hover
	$VBoxContainer/Botbutton.mouse_entered.connect(func():
		print("Hover: FlorestaBot")
	)
	$VBoxContainer/Botbutton.mouse_exited.connect(func():
		pass) # não faz nada

# Função auxiliar para hover
func _connect_hover(button: Button, panel: Control, nome: String) -> void:
	button.mouse_entered.connect(func():
		print("Hover:", nome)
		panel.visible = true
	)
	button.mouse_exited.connect(func():
		panel.visible = false
	) # <-- aqui estava faltando fechar

# Métodos conectados via Editor ao sinal 'pressed' dos botões
func _on_espacobutton_pressed() -> void:
	print("Clique: Espaço")
	emit_signal("map_chosen", "Espaco")
	queue_free()

func _on_florestabutton_pressed() -> void:
	print("Clique: Floresta")
	emit_signal("map_chosen", "Floresta")
	queue_free()

func _on_botbutton_pressed() -> void:
	print("Clique: FlorestaBot")
	emit_signal("map_chosen", "main_florestabot")
	queue_free()

# Botão de voltar
func _on_backbutton_pressed() -> void:
	print("Clique: Voltar")
	emit_signal("back_pressed")
	queue_free()
