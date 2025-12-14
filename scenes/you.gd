extends Area2D
var hit_tll = 0.0
var facing = "up"
var type = Global.GridType.PLAYER
var text = "It's you."

func _ready():
	add_to_group("player")
	Global.player = self
	
func die():
	Global.play_sound(Global.PlayerDieSFX)
	Global.GAME_OVER = true
	$sprite.animation = "dead"
	
func heal(points):
	Global.life += points
	Global.play_sound(Global.HealSFX)
	if Global.life > 3:
		Global.life = 3
		
	Global.Main.update_life()
	show_damage()
	
func attack():
	$attack_a.play("new_animation")
	Global.play_sound(Global.EnemyHitSFX)
	
func show_damage():
	$sprite.frame = 3 - Global.life
	
func hit(dmg):
	$sprite.material.set_shader_parameter("on", 1)
	hit_tll = 1.2
	Global.life -= (dmg - Global.DMG)
	Global.play_sound(Global.HurtSFX)
	if Global.life <= 0:
		Global.life = 0
		die()
	
	Global.Main.update_life()
	show_damage()

func get_texture():
	var anim = $sprite
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	
func _physics_process(delta: float) -> void:
	$sprite/lvl.text = str(Global.DMG)
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
