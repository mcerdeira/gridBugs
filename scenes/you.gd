extends Area2D
var speed = 250.0
var shoot_ttl_total = 0.1
var shoot_ttl = shoot_ttl_total
var life = Global.TOTAL_LIFE
var hit_tll = 0.0
var bullet_scene = load("res://scenes/bullet.tscn")

func _ready():
	add_to_group("player")
	Global.player = self
	
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $mark.global_position
	bullet.rotation_degrees = rotation_degrees 
	get_tree().current_scene.add_child(bullet)
	
func die():
	queue_free()
	
func hit(dmg):
	if hit_tll <= 0:
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		$life_bar.scale.x = life / Global.TOTAL_LIFE
		if life <= 0:
			die()
	
func _physics_process(delta: float) -> void:
	$life_bar.global_position = Vector2(global_position.x - 16, global_position.y + 20)
	$life_black.global_position = Vector2(global_position.x - 16, global_position.y + 20)
	
	if hit_tll >= 0:
		hit_tll -= 1 * delta
		if hit_tll <= 0:
			$sprite.material.set_shader_parameter("on", 0)
	
	look_at(get_global_mouse_position())
	rotation_degrees += 90
	shoot_ttl -= 1 * delta
	if shoot_ttl <= 0:
		shoot_ttl = shoot_ttl_total
		shoot()
	
	if Input.is_action_pressed("up"):
		global_position.y -= speed * delta
	elif Input.is_action_pressed("down"):
		global_position.y += speed * delta
		
	if Input.is_action_pressed("left"):
		global_position.x -= speed * delta
	elif Input.is_action_pressed("right"):
		global_position.x += speed * delta
