extends Area2D
var life = 3
var hit_tll = 0.0
var facing = "up"
var type = Global.GridType.PLAYER

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
		if life <= 0:
			die()
	
func _physics_process(delta: float) -> void:
	if !Global.GAME_OVER:
		if Input.is_action_just_pressed("left"):
			$sprite.flip_h = true
		elif Input.is_action_just_pressed("right"):
			$sprite.flip_h = false
		
		if hit_tll >= 0:
			hit_tll -= 1 * delta
			if hit_tll <= 0:
				$sprite.material.set_shader_parameter("on", 0)
