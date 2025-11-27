extends Area2D
var life = Global.ENEMY_BASE_LIFE
var hit_tll = 0.0
var notify_death = null
var crystal_scene = load("res://scenes/crystal.tscn")
var lbl_scene = load("res://scenes/dmg_lbl.tscn")
var dead = false
var level = 1

func _ready():
	add_to_group("enemy")
	
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
	
	if hit_tll >= 0:
		hit_tll -= 1 * delta
		if hit_tll <= 0:
			$sprite.material.set_shader_parameter("on", 0)
				
func _limit_to_screen() -> void:
	var rect = get_viewport_rect()
	var margin_side = 32
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

func die():
	if notify_death != null and is_instance_valid(notify_death):
		notify_death.notify()
	
	spawn_crystals()
	queue_free()

func hit(dmg):
	if hit_tll <= 0:
		var lbl = lbl_scene.instantiate()
		lbl.global_position = global_position
		lbl.dmg = dmg
		get_tree().current_scene.add_child(lbl)
		$sprite.material.set_shader_parameter("on", 1)
		hit_tll = 0.2
		life -= dmg
		if life <= 0:
			die()
	
func spawn_crystals():
	var count := randi_range(3, 7)
	for i in count:
		var c = crystal_scene.instantiate()
		c.global_position = global_position
		get_tree().current_scene.add_child(c)
