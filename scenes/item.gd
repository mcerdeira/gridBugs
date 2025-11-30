extends Node2D
var level = 0
var type = Global.GridType.ITEM

func _ready():
	add_to_group("item")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl
	
func _physics_process(delta: float) -> void:
	pass
