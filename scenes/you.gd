extends Area2D
var speed = 250.0
var shoot_ttl_total = 0.1
var shoot_ttl = shoot_ttl_total
var bullet_scene = load("res://scenes/bullet.tscn")

func _ready():
	add_to_group("player")
	
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $mark.global_position
	bullet.rotation_degrees = rotation_degrees 
	get_tree().current_scene.add_child(bullet)
	
func _physics_process(delta: float) -> void:
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
