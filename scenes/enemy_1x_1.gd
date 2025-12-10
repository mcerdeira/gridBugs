extends Area2D
var life = 1
var hit_tll = 0.0
var notify_death = null
var crystal_scene = load("res://scenes/crystal.tscn")
var lbl_scene = load("res://scenes/dmg_lbl.tscn")
var dead = false
var level = 1
var type = Global.GridType.ENEMY
var text = ""

func _ready():
	add_to_group("enemy")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl - 1
	text = "Enemy lvl: " + str(level)
	
func _physics_process(delta: float) -> void:
	if hit_tll >= 0:
		hit_tll -= 1 * delta
		if hit_tll <= 0:
			$sprite.material.set_shader_parameter("on", 0)
			
func die():
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	
	queue_free()
	
func get_texture():
	var anim = $sprite
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)

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

func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")

func _on_mouse_exited() -> void:
	$anim.stop()
