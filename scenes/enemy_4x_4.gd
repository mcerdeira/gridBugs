extends Area2D
var life = Global.ENEMY_BASE_LIFE * 3

func _ready():
	add_to_group("enemy")

func die():
	Global.occupied_cells.remove_at(Global.occupied_cells.find(global_position))
	queue_free()

func hit(dmg):
	life -= dmg
	if life <= 0:
		die()
