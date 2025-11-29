extends CanvasLayer

@onready var continue_button = $Panel/VBoxContainer/ContinueButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var settings_panel = $SettingsPanel

func _ready():
	visible = false

	continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_panel.process_mode = Node.PROCESS_MODE_ALWAYS

	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_menu():
	get_tree().paused = true
	visible = true
	$Panel.visible = true
	settings_panel.visible = false

func hide_menu():
	get_tree().paused = false
	visible = false

func _on_continue_pressed():
	hide_menu()

func _on_settings_pressed():
	settings_panel.visible = true
	$Panel.visible = false

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
