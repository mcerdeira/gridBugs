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

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if %door.animation == "open":
		if Input.is_action_just_pressed("mouseLeft"):
			if Global.TutorialLevel:
				Global.TutorialLevel = false
			else:
				Global.FLOOR += 1 
			get_tree().reload_current_scene()
