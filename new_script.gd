extends CharacterBody2D
# Adicione a palavra-chave "class_name" para facilitar a referência a este script
class_name Player

# Define a velocidade de movimento do personagem
@export var speed = 300.0

# Define a força do pulo
@export var jump_velocity = -400.0

# Define a gravidade (para a física do Godot)
var gravity = 980.0

# A função "_ready()" é chamada uma vez quando o nó é iniciado
func _ready():
	# Define a gravidade para usar a mesma do projeto
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# A função "_physics_process" é chamada a cada quadro de física
func _physics_process(delta):
	# Aplica a gravidade à velocidade vertical
	# A gravidade é multiplicada por "delta" para garantir que o movimento seja suave
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo: verifica se o botão de pulo (configurado como "ui_up") foi pressionado
	# e se o personagem está no chão
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity

	# Movimento lateral: verifica as teclas "esquerda" e "direita"
	# Obtemos o valor do eixo para saber se é positivo (direita) ou negativo (esquerda)
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Usa a função nativa do Godot para mover e gerenciar colisões
	move_and_slide()
