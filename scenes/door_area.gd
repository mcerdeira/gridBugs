extends Area2D
var text = "Exit floor?"

func get_texture():
	var anim = %door
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)

func _on_mouse_entered() -> void:
	if %door.animation == "closed":
		text = "Key Needed"
	else:
		text = "Exit floor?"
	
	Global.Main.set_item_inspect(self, true)
