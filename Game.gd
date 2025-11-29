extends Node

@onready var pause_button = $PauseButton
@onready var pause_menu = $PauseMenu
@onready var game_manager = $gerenciamentogame
@onready var round_music = $RoundMusic  

func _ready():
	ConfigManager.load()

	# Aplica volume global
	AudioServer.set_bus_volume_db(0, linear_to_db(ConfigManager.volume))
	round_music.volume_db = linear_to_db(ConfigManager.volume)

	# Toca a música do round
	round_music.play()

	pause_button.pressed.connect(_on_pause_button_pressed)
	game_manager.start_round()

func _input(event):
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			if pause_menu.settings_panel.visible:
				pause_menu.settings_panel.visible = false
				pause_menu.get_node("Panel").visible = true
			else:
				pause_menu.hide_menu()
		else:
			pause_menu.show_menu()

func _on_pause_button_pressed():
	pause_menu.show_menu()
