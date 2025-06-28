extends Node2D

@onready var player = $Player
var monster: Node = null

var current_floor: int = 1
var coins: int = 0
var damage: int = 1
var attack_cooldown: float = 0.6
var crit_chance: float = 0.1
var monsters_defeated_this_floor: int = 0

@onready var label_andar = $CanvasLayer/LabelAndar
@onready var label_moedas = $CanvasLayer/LabelMoedas
@onready var label_monstro = $CanvasLayer/LabelMonstro

@onready var loja_container = $CanvasLayer/LojaContainer
@onready var botao_dano = $CanvasLayer/LojaContainer/ButtonComprarDano
@onready var botao_velocidade = $CanvasLayer/LojaContainer/ButtonComprarVelocidade
@onready var botao_critico = $CanvasLayer/LojaContainer/ButtonComprarCritico
@onready var botao_avancar = $CanvasLayer/LojaContainer/ButtonAvancar

var monster_scenes: Array[PackedScene] = [
	preload("res://scenes/monsters/Goblin.tscn"),
	preload("res://scenes/monsters/Skeleton.tscn")
]

func _ready():
	# Conectar sinais
	player.attack_executed.connect(_on_attack)
	botao_dano.pressed.connect(_on_ButtonComprarDano_pressed)
	botao_velocidade.pressed.connect(_on_ButtonComprarVelocidade_pressed)
	botao_critico.pressed.connect(_on_ButtonComprarCritico_pressed)
	botao_avancar.pressed.connect(_on_ButtonAvancar_pressed)

	player.attack_cooldown = attack_cooldown
	loja_container.visible = false
	spawn_new_monster()
	update_ui()

func _on_attack():
	if monster:
		var is_crit = randf() < crit_chance
		var total_damage = damage
		if is_crit:
			total_damage *= 2
			print("🔥 CRÍTICO!")
		monster.call("take_damage", total_damage, is_crit)

func on_monster_defeated():
	coins += 5  # Moedas por monstro morto
	monsters_defeated_this_floor += 1

	if monsters_defeated_this_floor >= 5:
		# Boss derrotado, bônus de andar
		var bonus = current_floor * 10
		coins += bonus
		print("Andar %d concluído! Você ganhou %d moedas bônus!" % [current_floor, bonus])

		current_floor += 1
		monsters_defeated_this_floor = 0
		loja_container.visible = true
	else:
		# Próximo monstro
		spawn_new_monster()

	update_ui()

func spawn_new_monster():
	if monster and is_instance_valid(monster):
		monster.queue_free()

	var scene: PackedScene

	if monsters_defeated_this_floor < 4:
		# Monstro normal
		scene = monster_scenes.pick_random()
	else:
		# Boss
		scene = monster_scenes.pick_random()

	monster = scene.instantiate()
	add_child(monster)

	monster.position = Vector2(player.position.x + 200.0, player.position.y)

	var base_hp = 10 + current_floor * 5
	if "max_hp" in monster:
		if monsters_defeated_this_floor < 4:
			monster.set("max_hp", base_hp)
		else:
			monster.set("max_hp", base_hp * 2)

	if "monster_name" in monster:
		var nome = monster.get("monster_name")
		if monsters_defeated_this_floor < 4:
			label_monstro.text = "Monstro: %s (%d/5)" % [nome, monsters_defeated_this_floor + 1]
		else:
			label_monstro.text = "BOSS: %s (%d/5)" % [nome, monsters_defeated_this_floor + 1]
	else:
		label_monstro.text = "Monstro: ???"

func update_ui():
	label_andar.text = "Andar: %d" % current_floor
	label_moedas.text = "Moedas: %d" % coins

	if monster and is_instance_valid(monster):
		if "monster_name" in monster:
			var nome = monster.get("monster_name")
			if monsters_defeated_this_floor < 4:
				label_monstro.text = "Monstro: %s (%d/5)" % [nome, monsters_defeated_this_floor + 1]
			else:
				label_monstro.text = "BOSS: %s (%d/5)" % [nome, monsters_defeated_this_floor + 1]
		else:
			label_monstro.text = "Monstro: ???"
	else:
		label_monstro.text = "Monstro: ---"

func _on_ButtonComprarDano_pressed():
	if coins >= 10:
		coins -= 10
		damage += 1
		print("Dano aumentado para", damage)
	else:
		print("Moedas insuficientes.")
	update_ui()

func _on_ButtonComprarVelocidade_pressed():
	if coins >= 15:
		coins -= 15
		attack_cooldown = max(0.2, attack_cooldown - 0.1)
		player.attack_cooldown = attack_cooldown
		print("Velocidade de ataque aumentada! cooldown:", attack_cooldown)
	else:
		print("Moedas insuficientes.")
	update_ui()

func _on_ButtonComprarCritico_pressed():
	if coins >= 20:
		coins -= 20
		crit_chance = min(1.0, crit_chance + 0.05)
		print("Chance de crítico aumentada para", crit_chance * 100, "%")
	else:
		print("Moedas insuficientes.")
	update_ui()

func _on_ButtonAvancar_pressed():
	print("Avançar clicado!")
	loja_container.visible = false
	spawn_new_monster()
	update_ui()
