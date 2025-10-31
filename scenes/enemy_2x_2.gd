extends Area2D
var life = Global.ENEMY_BASE_LIFE * 2
var hit_tll = 0.0
var grow_ttl = 5.0

func _ready():
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	grow_ttl -= 1 * delta
	if grow_ttl <= 0:
		queue_free()
	
	if hit_tll >= 0:
		hit_tll -= 1 * delta
		if hit_tll <= 0:
			$sprite.material.set_shader_parameter("on", 0)

func die():
	Global.occupied_cells.remove_at(Global.occupied_cells.find(global_position))
	queue_free()

func hit(dmg):
	if hit_tll <= 0:
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		if life <= 0:
			die()
