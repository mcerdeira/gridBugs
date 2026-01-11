extends Area2D
var type = Global.GridType.STATIC
var text = ""
var level = 1

func _ready():
	add_to_group("static")
	
func set_level(lvl):
	fusion()
	
func fusion():
	$fusion_anim.play("new_animation")
	
func die():
	queue_free()
	
func get_texture():
	var anim = $ficha
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	
func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")
		
func _on_mouse_exited() -> void:
	$anim.stop()
