extends Node2D
var level = 1
var type = Global.GridType.ITEM

func _ready():
	add_to_group("item")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl - 1
	
func _physics_process(delta: float) -> void:
	pass
