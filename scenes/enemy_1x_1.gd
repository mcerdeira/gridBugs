extends Area2D
var life = Global.ENEMY_BASE_LIFE
var hit_tll = 0.0
var cangrow = true
var notify_death = null

func _ready():
	add_to_group("enemy")
	if !cangrow:
		$enemy_duplicator.queue_free()
		$enemy_duplicator2.queue_free()
		$enemy_duplicator3.queue_free()
		$enemy_duplicator4.queue_free()
		$enemy_duplicator5.queue_free()
		$enemy_duplicator6.queue_free()
		$enemy_duplicator7.queue_free()
		$enemy_duplicator8.queue_free()
	
func _physics_process(delta: float) -> void:	
	if hit_tll >= 0:
		hit_tll -= 1 * delta
		if hit_tll <= 0:
			$sprite.material.set_shader_parameter("on", 0)

func die():
	Global.occupied_cells.remove_at(Global.occupied_cells.find(global_position))
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	queue_free()

func hit(dmg):
	if hit_tll <= 0:
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		if life <= 0:
			die()
	
