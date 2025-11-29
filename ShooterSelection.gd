extends Control
class_name ShooterSelection

@export var yumi_scene: PackedScene
@export var gab_scene: PackedScene

var available_shooters := {}
var selected_mode := ""
var current_player := "Player1"
var selected_shooters := {}

signal shooters_chosen(selected_shooters: Dictionary)
signal back_pressed

@onready var info_yumi = $InfoPanel      # painel da Yumi
@onready var info_gab = $InfoPanel2      # painel do Gab

func _ready():
	available_shooters = {
		"Yumi": yumi_scene,
		"Gab": gab_scene
	}
	$Label.text = "Escolha do " + current_player

	# Conecta sinais de hover
	$VBoxContainer/YumiButton.mouse_entered.connect(func(): info_yumi.visible = true)
	$VBoxContainer/YumiButton.mouse_exited.connect(func(): info_yumi.visible = false)

	$VBoxContainer/GabButton.mouse_entered.connect(func(): info_gab.visible = true)
	$VBoxContainer/GabButton.mouse_exited.connect(func(): info_gab.visible = false)

	# começa escondido
	info_yumi.visible = false
	info_gab.visible = false

func set_mode(mode: String):
	selected_mode = mode

func _on_shooter_button_pressed(shooter_name: String):
	if not available_shooters.has(shooter_name):
		print("Shooter não encontrado:", shooter_name)
		return

	selected_shooters[current_player] = shooter_name
	print(current_player, "escolheu", shooter_name)

	if (selected_mode == "pvp" and current_player == "Player1") \
	or (selected_mode == "vs_bot" and current_player == "Player1"):
		# Depois da escolha do Player1, pede Player2 também
		current_player = "Player2"
		$Label.text = "Escolha do " + current_player
	else:
		emit_signal("shooters_chosen", selected_shooters)
		queue_free()


func _on_back_button_pressed():
	emit_signal("back_pressed")
	queue_free()

func _on_yumi_button_pressed():
	_on_shooter_button_pressed("Yumi")

func _on_gab_button_pressed():
	_on_shooter_button_pressed("Gab")
