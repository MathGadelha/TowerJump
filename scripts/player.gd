extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
signal attack_executed

@export var gravity := 900.0
@export var attack_cooldown := 0.6
var can_attack := true

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		if can_attack:
			_do_attack()

func _do_attack():
	can_attack = false
	sprite.animation = "attack"

	# Ajusta a velocidade da animação com base no cooldown
	# Quanto menor o cooldown, mais rápida a animação
	sprite.speed_scale = 0.6 / attack_cooldown

	sprite.play()
	emit_signal("attack_executed")
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
