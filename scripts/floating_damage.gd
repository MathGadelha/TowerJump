extends Node2D

@onready var label = $Label

func show_damage(value: int, is_crit: bool):
	label.text = str(value)
	if is_crit:
		label.modulate = Color(1, 0, 0)  # Vermelho
	else:
		label.modulate = Color(1, 1, 1)  # Branco normal

	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 30, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.3)
	tween.connect("finished", Callable(self, "queue_free"))
