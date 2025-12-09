extends Area2D
var level = 1
var type = Global.GridType.ITEM
var text = ""

func _ready():
	add_to_group("item")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl - 1
	text = "MedKit lvl: " + str(level)
	
func get_texture():
	var anim = $sprite
	return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	
func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
