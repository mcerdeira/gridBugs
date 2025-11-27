extends Area2D
var speed = Global.TOTAL_SPEED
var life = Global.TOTAL_LIFE
var hit_tll = 0.0
var facing = "up"

func _ready():
	add_to_group("player")
	Global.player = self
	
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
			global_position.y -= 32
			Global.Main.turn()
		elif Input.is_action_just_pressed("down"):
			global_position.y += 32
			Global.Main.turn()
		if Input.is_action_just_pressed("left"):
			$sprite.flip_h = true
			global_position.x -= 32
			Global.Main.turn()
		elif Input.is_action_just_pressed("right"):
			$sprite.flip_h = false
			global_position.x += 32
			Global.Main.turn()
			
		_limit_to_screen()
	
func _limit_to_screen() -> void:
	var rect = get_viewport_rect()
	var margin_side = 64 + 64
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
