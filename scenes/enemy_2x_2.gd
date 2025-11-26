extends Area2D
var life = Global.ENEMY_BASE_LIFE * 2
var hit_tll = 0.0
var notify_death = null
var shoot_ttl_total = 5.0 / 2.0
var shoot_ttl = shoot_ttl_total
var bullet_scene = load("res://scenes/enemy_bullet_a.tscn")
var crystal_scene = load("res://scenes/crystal.tscn")
var lbl_scene = load("res://scenes/dmg_lbl.tscn")
var ash_scene = load("res://scenes/Ash1x1.tscn")
var enemy_grow_to = load("res://scenes/Enemy4x4.tscn")
var dead = false
var ash = 0
var growing = 0

func _ready():
	add_to_group("enemy")
	add_to_group("enemy2x2")
	
func get_ash(cant = 1):
	ash += cant
	if ash >= 10:
		start_grow()
			
func start_grow():
	growing = 1.1
	$sprite.material.set_shader_parameter("on", 1)
	
func _physics_process(delta: float) -> void:
	if growing > 0:
		growing -= 1 * delta
		var enemy = enemy_grow_to.instantiate()
		enemy.global_position = global_position
		get_tree().current_scene.add_child(enemy)
		queue_free()
	else:
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
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	
	spawn_crystals()
	spawn_ash()
	queue_free()

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

func spawn_ash():
	var count = randi_range(3, 7) + ash
	for i in count:
		var c = ash_scene.instantiate()
		c.global_position = global_position
		get_tree().current_scene.add_child(c)

func spawn_crystals():
	var count := randi_range(3, 7)
	for i in count:
		var c = crystal_scene.instantiate()
		c.global_position = global_position
		get_tree().current_scene.add_child(c)

func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("enemy1x1"):
		get_ash(5)
		area.queue_free()
