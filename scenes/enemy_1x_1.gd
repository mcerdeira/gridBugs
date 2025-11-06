extends Area2D
var life = Global.ENEMY_BASE_LIFE
var hit_tll = 0.0
var notify_death = null
var shoot_ttl_total = 5.0
var shoot_ttl = shoot_ttl_total
var bullet_scene = load("res://scenes/enemy_bullet_a.tscn")
var crystal_scene = load("res://scenes/crystal.tscn")
var lbl_scene = load("res://scenes/dmg_lbl.tscn")
var position_in_occupied_cells = Vector2i(-1, -1)
var marked = false

func _ready():
	add_to_group("enemy")
	add_to_group("enemy1x1")

func mark():
	marked = true
	$sprite.animation = "new_animation"
	
func _physics_process(delta: float) -> void:
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
	Global.occupied_cells.remove_at(Global.occupied_cells.find(position_in_occupied_cells))
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	
	spawn_crystals()
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

func spawn_crystals():
	var count := randi_range(3, 7)  # cantidad aleatoria
	for i in count:
		var c = crystal_scene.instantiate()
		c.global_position = global_position
		get_tree().current_scene.add_child(c)
