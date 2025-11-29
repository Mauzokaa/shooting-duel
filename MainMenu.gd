extends CanvasLayer

const CONFIG_PATH = "user://settings.cfg"

@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var exit_button = $VBoxContainer/ExitButton

@onready var settings_panel = $SettingsPanel
@onready var volume_slider = $SettingsPanel/VBoxContainer/VolumeSlider
@onready var fullscreen_check = $SettingsPanel/VBoxContainer/FullscreenCheck
@onready var show_fps_check = $SettingsPanel/VBoxContainer/ShowFPSCheck
@onready var back_button = $SettingsPanel/VBoxContainer/BackButton

@onready var mode_selector = $ModeSelector
@onready var vs_bot_button = $ModeSelector/VsBotButton
@onready var pvp_button = $ModeSelector/PvpButton
@onready var back_button_mode = $ModeSelector/BackButton

@onready var main_buttons = $VBoxContainer

@onready var video_player = $VideoStreamPlayer
@onready var menu_music = $MenuMusic

func _ready():
	print("MainMenu carregado")

	# Silencia o áudio do vídeo e toca a nova música
	video_player.volume_db = -80
	menu_music.play()

	load_settings()

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	back_button.pressed.connect(_on_back_pressed)
	back_button_mode.pressed.connect(_on_back_from_mode_pressed)

	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	show_fps_check.toggled.connect(_on_show_fps_toggled)

	vs_bot_button.pressed.connect(_on_vs_bot_pressed)
	pvp_button.pressed.connect(_on_pvp_pressed)

	settings_panel.visible = false
	mode_selector.visible = false

# ---------------- MENU PRINCIPAL ----------------

func _on_play_pressed():
	main_buttons.visible = false
	mode_selector.visible = true

func _on_vs_bot_pressed():
	GameSettings.mode = "vs_bot"
	main_buttons.visible = false
	mode_selector.visible = false

	var shooter_selection = preload("res://ShooterSelection.tscn").instantiate()
	add_child(shooter_selection)
	shooter_selection.set_mode("vs_bot")
	shooter_selection.connect("shooters_chosen", Callable(self, "_on_shooters_chosen"))
	shooter_selection.connect("back_pressed", Callable(self, "_on_shooter_back"))

func _on_pvp_pressed():
	GameSettings.mode = "pvp"
	main_buttons.visible = false
	mode_selector.visible = false

	var shooter_selection = preload("res://ShooterSelection.tscn").instantiate()
	add_child(shooter_selection)
	shooter_selection.set_mode("pvp")
	shooter_selection.connect("shooters_chosen", Callable(self, "_on_shooters_chosen"))
	shooter_selection.connect("back_pressed", Callable(self, "_on_shooter_back"))

func _on_shooter_back():
	# Reabre o menu de modos
	mode_selector.visible = true
	main_buttons.visible = false

# ---------------- SHOOTER + MAP SELECTION ----------------

func _on_shooters_chosen(selected_shooters: Dictionary):
	print("Atiradores escolhidos:", selected_shooters)

	# Salva globalmente
	GameSettings.selected_shooters = selected_shooters

	var map_selection = preload("res://MapSelection.tscn").instantiate()
	add_child(map_selection)
	map_selection.connect("map_chosen", Callable(self, "_on_map_chosen"))
	map_selection.connect("back_pressed", Callable(self, "_on_map_back"))

func _on_map_back():
	# Volta para o menu de modos
	mode_selector.visible = true

func _on_map_chosen(map_name: String):
	GameSettings.selected_map = map_name
	print("Mapa escolhido:", map_name)
	print("Atiradores escolhidos:", GameSettings.selected_shooters)

	var target_scene := ""
	if map_name == "Espaco":
		target_scene = "res://main.tscn"
	elif map_name == "Floresta":
		target_scene = "res://main_floresta.tscn"
	elif map_name == "main_florestabot":
		target_scene = "res://main_florestabot.tscn"
	else:
		print("Nome de mapa desconhecido:", map_name)
		return

	var exists := ResourceLoader.exists(target_scene)
	print("Verificando cena:", target_scene, "existe?", exists)
	if not exists:
		push_error("Cena não encontrada: " + target_scene)
		return

	var err := get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("Falha ao trocar cena: " + str(err))

# ---------------- CONFIGURAÇÕES ----------------

func _on_settings_pressed():
	main_buttons.visible = false
	settings_panel.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	save_settings()
	settings_panel.visible = false
	main_buttons.visible = true

func _on_back_from_mode_pressed():
	mode_selector.visible = false
	main_buttons.visible = true

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, value)
	menu_music.volume_db = value

func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_show_fps_toggled(button_pressed):
	var overlay = get_node_or_null("/root/FpsOverlay")
	if overlay:
		overlay.visible = button_pressed
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "volume_db", volume_slider.value)
	config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
	config.set_value("debug", "show_fps", show_fps_check.button_pressed)
	config.save(CONFIG_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		var volume = config.get_value("audio", "volume_db", -20)
		volume_slider.value = volume
		AudioServer.set_bus_volume_db(0, volume)
		menu_music.volume_db = volume

		var fullscreen = config.get_value("display", "fullscreen", false)
		fullscreen_check.button_pressed = fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		var show_fps = config.get_value("debug", "show_fps", false)
		show_fps_check.button_pressed = show_fps
		var overlay = get_node_or_null("/root/FpsOverlay")
		if overlay:
			overlay.visible = show_fps

# ---------------- INPUT ----------------

func _input(event):
	if event.is_action_pressed("pause"):
		if settings_panel.visible:
			settings_panel.visible = false
			main_buttons.visible = true
		elif mode_selector.visible:
			mode_selector.visible = false
			main_buttons.visible = true
