extends CharacterBody2D

@export var monster_name: String = "Monstro"
@export var max_hp: int = 10
@export var gravity: float = 900.0
@export var damage_scene: PackedScene = preload("res://scenes/monsters/floatingDamage.tscn")

@onready var anim_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var label_nome = $LabelNomeMonstro
@onready var impact_particles = $ImpactParticles

var current_hp: int = 0
var is_dying: bool = false

func _ready():
	current_hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	label_nome.text = monster_name

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

func take_damage(amount: int, is_crit: bool = false):
	if is_dying:
		return

	current_hp -= amount
	show_damage(amount, is_crit)
	health_bar.value = current_hp
	show_impact()

	if current_hp > 0:
		anim_sprite.play("hurt")
		await anim_sprite.animation_finished
		anim_sprite.play("idle")
	else:
		die()

func show_damage(value: int, is_crit: bool):
	var dmg = damage_scene.instantiate()
	get_tree().current_scene.add_child(dmg)
	dmg.global_position = global_position + Vector2(0, -30)
	dmg.call("show_damage", value, is_crit)

func show_impact():
	impact_particles.restart()

func die():
	is_dying = true
	anim_sprite.play("death")
	await anim_sprite.animation_finished
	queue_free()
	get_tree().current_scene.call("on_monster_defeated")
