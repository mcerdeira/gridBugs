extends Area2D
var level = 1

func _ready():
	add_to_group("weapon")
	set_level(level)
	
func set_level(lvl):
	level = lvl
	$sprite.frame = lvl
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		global_position.y -= 32
	elif Input.is_action_just_pressed("down"):
		global_position.y += 32
		
	if Input.is_action_just_pressed("left"):
		global_position.x -= 32
	elif Input.is_action_just_pressed("right"):
		global_position.x += 32
	
	_limit_to_screen()
				
func _limit_to_screen() -> void:
	var rect = get_viewport_rect()
	var margin_side = 64 + 64
	var margin_bottom = 32 
	var margin_top = 32

	global_position.x = clamp(
		global_position.x,
		rect.position.x + margin_side,
		rect.size.x - margin_side
	)
	global_position.y = clamp(
		global_position.y,
		rect.position.y + margin_top,
		rect.size.y - margin_bottom
	)
