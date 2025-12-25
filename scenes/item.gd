extends Area2D
var level = 1
var type = Global.GridType.ITEM
var text = ""

func _ready():
	add_to_group("item")
	set_level(level)
	
func set_level(lvl):
	fusion()
	level = lvl
	$sprite.frame = lvl - 1
	$sprite/lvl.text = str(lvl)
	text = "Potion lvl: " + str(level)
	
func fusion():
	$fusion_anim.play("new_animation")
	
func die():
	for obj in Global.MainQuest.objetives:
		if obj.what == type and obj.lvl == level and obj.got < obj.cant:
			obj.got += 1
	
	queue_free()
	
func get_texture():
	var anim = $sprite
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	
func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")
		
func _on_mouse_exited() -> void:
	$anim.stop()
