extends Control

const CONFIG_PATH = "user://settings.cfg"

@onready var volume_slider = $VBoxContainer/VolumeSlider
@onready var fullscreen_check = $VBoxContainer/FullscreenCheck
@onready var show_fps_check = $VBoxContainer/ShowFPSCheck
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	volume_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	fullscreen_check.process_mode = Node.PROCESS_MODE_ALWAYS
	show_fps_check.process_mode = Node.PROCESS_MODE_ALWAYS
	back_button.process_mode = Node.PROCESS_MODE_ALWAYS

	load_settings()

	back_button.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	show_fps_check.toggled.connect(_on_show_fps_toggled)

func _on_back_pressed():
	save_settings()
	visible = false
	if has_node("../Panel"):
		get_node("../Panel").visible = true
	elif has_node("../../VBoxContainer"):
		get_node("../../VBoxContainer").visible = true

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, value)

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
		var volume = config.get_value("audio", "volume_db", -10)
		volume_slider.value = volume
		AudioServer.set_bus_volume_db(0, volume)

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
	else:
		print("⚠️ Nenhuma configuração encontrada ou erro ao carregar:", err)
