extends Area2D
var hit_tll = 0.0
var facing = "up"
var type = Global.GridType.PLAYER
var text = "It's you."

func _ready():
	add_to_group("player")
	Global.player = self
	
func die():
	Global.GAME_OVER = true
	visible = false
	
func heal(points):
	Global.life += points
	Global.play_sound(Global.HealSFX)
	if Global.life > 3:
		Global.life = 3
	
func hit(dmg):
	$sprite.material.set_shader_parameter("on", 1)
	hit_tll = 1.2
	Global.life -= dmg
	Global.play_sound(Global.HurtSFX)
	if Global.life <= 0:
		Global.life = 0
		die()
	
	Global.Main.update_life()

func get_texture():
	return $sprite.texture
	
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

func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")

func _on_mouse_exited() -> void:
	$anim.stop()
