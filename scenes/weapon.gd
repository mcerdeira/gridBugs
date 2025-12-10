extends Node2D
var level = 1
var type = Global.GridType.WEAPON
var text = ""

func _ready():
	add_to_group("weapon")
	set_level(level)
	
func get_texture():
	var anim = $sprite
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl - 1
	text = "Weapon lvl: " + str(level)
	
func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")
		
func _on_mouse_exited() -> void:
	$anim.stop()
