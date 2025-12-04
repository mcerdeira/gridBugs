extends Area2D
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
	$sprite.material.set_shader_parameter("on", 1)
	hit_tll = 1.2
	Global.life -= dmg
	if Global.life <= 0:
		Global.life = 0
		die()
	
	Global.Main.update_life()
	
func _physics_process(delta: float) -> void:
	if !Global.GAME_OVER:
		if hit_tll >= 0:
			hit_tll -= 1 * delta
			if hit_tll < 0.9:
				$sprite.material.set_shader_parameter("on", 0)
			elif hit_tll < 0.5:
				$sprite.material.set_shader_parameter("on", 1)
				
			if hit_tll <= 0:
				$sprite.material.set_shader_parameter("on", 0)
