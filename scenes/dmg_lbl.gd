extends Node2D
var dmg = 0

func _physics_process(delta: float) -> void:
	$lbl.text = str(dmg * 100)
	position.y -= 100 * delta
	modulate.a -= 1 * delta
	if modulate.a <= 0:
		queue_free()
