extends Area2D
var speed = Global.TOTAL_SPEED
var shoot_ttl_total = Global.SHOOT_TTL_TOTAL
var shoot_ttl = shoot_ttl_total
var life = Global.TOTAL_LIFE
var hit_tll = 0.0
var facing = "up"
var bullet_scene = load("res://scenes/bullet.tscn")

func _ready():
	add_to_group("player")
	Global.player = self
	
func max_shoot_ttl():
	var ten = Global.SHOOT_TTL_TOTAL * 0.10
	Global.SHOOT_TTL_TOTAL -= ten
	shoot_ttl_total = Global.SHOOT_TTL_TOTAL
	
func max_collect_up():
	Global.COLLECT_RADIUS *= 1.10
	$get_collector/collider.shape.radius *= 1.10
	
func shoot():
	if !Global.GAME_OVER:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = $mark.global_position
		bullet.rotation_degrees = rotation_degrees 
		get_tree().current_scene.add_child(bullet)
	
func die():
	Global.GAME_OVER = true
	visible = false
	
func hit(dmg):
	if hit_tll <= 0:
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		$life_bar.scale.x = life / Global.TOTAL_LIFE
		if life <= 0:
			die()
	
func _physics_process(delta: float) -> void:
	if !Global.GAME_OVER:
		$life_bar.global_position = Vector2(global_position.x - 16, global_position.y + 20)
		$life_black.global_position = Vector2(global_position.x - 16, global_position.y + 20)
		
		if hit_tll >= 0:
			hit_tll -= 1 * delta
			if hit_tll <= 0:
				$sprite.material.set_shader_parameter("on", 0)
				
		if Input.is_action_just_pressed("up"):
			if facing == "up":
				global_position.y -= 32
			else:
				facing = "up"
				rotation_degrees = 0
			Global.Main.turn()
		elif Input.is_action_just_pressed("down"):
			if facing == "down":
				global_position.y += 32
			else:
				facing = "down"
				rotation_degrees = 180
			Global.Main.turn()
		if Input.is_action_just_pressed("left"):
			if facing == "left":
				global_position.x -= 32
			else:
				facing = "left"
				rotation_degrees = 270
			Global.Main.turn()
		elif Input.is_action_just_pressed("right"):
			if facing == "right":
				global_position.x += 32
			else:
				facing = "right"
				rotation_degrees = 90
			Global.Main.turn()
			
		_limit_to_screen()
	
func _limit_to_screen() -> void:
	var rect = get_viewport_rect()
	var margin_side = 32
	var margin_bottom = 32
	var margin_top = 32 

	global_position.x = clamp(
		global_position.x,
		rect.position.x + margin_side,
		rect.size.x - margin_side
	)
	global_position.y = clamp(
		global_position.y,
		rect.position.y + margin_top,
		rect.size.y - margin_bottom
	)
