extends Area2D
var speed = Global.TOTAL_SPEED
var shoot_ttl_total = Global.SHOOT_TTL_TOTAL
var shoot_ttl = shoot_ttl_total
var life = Global.TOTAL_LIFE
var hit_tll = 0.0
var bullet_scene = load("res://scenes/bullet.tscn")

func _ready():
	add_to_group("player")
	Global.player = self
	
func max_shoot_ttl():
	var ten = Global.SHOOT_TTL_TOTAL * 0.10
	Global.SHOOT_TTL_TOTAL -= ten
	shoot_ttl_total = Global.SHOOT_TTL_TOTAL
	
func max_collect_up():
	$get_collector/collider.shape.radius *= 1.0
	
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $mark.global_position
	bullet.rotation_degrees = rotation_degrees 
	get_tree().current_scene.add_child(bullet)
	
func die():
	queue_free()
	
func hit(dmg):
	return
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
