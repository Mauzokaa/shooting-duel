extends Control

@onready var restart_button = $RestartButton

func _ready():
	restart_button.pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed():
	print("Botão de teste clicado!")
