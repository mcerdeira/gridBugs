extends Area2D
var life = Global.ENEMY_BASE_LIFE * 4
var hit_tll = 0.0 
var notify_death = null
var shoot_ttl_total = 5.0
var shoot_ttl = shoot_ttl_total
var bullet_scene = load("res://scenes/enemy_bullet_a.tscn")
var crystal_scene = load("res://scenes/crystal.tscn")
var lbl_scene = load("res://scenes/dmg_lbl.tscn")
var ash_scene = load("res://scenes/Ash2x2.tscn")
var marked = false
var dead = false
var idx_s = []

func _ready():
	add_to_group("enemy")
	add_to_group("enemy4x4")

func mark():
	marked = true
	visible = false
	
func _physics_process(delta: float) -> void:
	if !marked and !dead:
		shoot_ttl -= 1 * delta
		if shoot_ttl <= 0:
			shoot_ttl = shoot_ttl_total
			if randi() % 10 == 0:
				shoot()
		
		if hit_tll >= 0:
			hit_tll -= 1 * delta
			if hit_tll <= 0:
				$sprite.material.set_shader_parameter("on", 0)

func die():
	#Registrar celda liberada
	var ash = ash_scene.instantiate()
	ash.idx_s = idx_s
	ash.global_position = global_position
	for idx in idx_s:
		Global.occupied_cells[idx][1] = Global.CELL_EGG_4
		Global.ash_cells[idx] = ash
		
	get_tree().current_scene.add_child(ash)
	
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	
	spawn_crystals()
	dead = true
	visible = false

func hit(dmg):
	if hit_tll <= 0:
		var lbl = lbl_scene.instantiate()
		lbl.global_position = global_position
		lbl.dmg = dmg
		get_tree().current_scene.add_child(lbl)
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		if life <= 0:
			die()
	
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.shoot_direction = (Global.player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func spawn_crystals():
	var count := randi_range(7, 11)
	for i in count:
		var c = crystal_scene.instantiate()
		c.global_position = global_position
		get_tree().current_scene.add_child(c)
