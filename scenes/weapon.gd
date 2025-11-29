extends Area2D
var level = 0

func _ready():
	add_to_group("weapon")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl
	
func _physics_process(delta: float) -> void:
	pass
				
