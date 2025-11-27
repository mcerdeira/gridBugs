extends Node2D
var levelup_scene = load("res://scenes/LevelUpScene.tscn")
var pause_scene = load("res://scenes/Pause.tscn")
var enemy_scenes = preload("res://scenes/Enemy1x1.tscn")
var weapon_scenes = preload("res://scenes/weapon.tscn")


func _ready() -> void:
	Global.Main = self
	calc_time()
	randomize()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		var pause = pause_scene.instantiate()
		pause.global_position = Vector2(0, 60)
		add_child(pause)
	
	if Global.check_level_up():
		$player_level.scale.x = 1.0
		var levelup = levelup_scene.instantiate()
		levelup.global_position = Vector2(0, 60)
		add_child(levelup)
	else:
		$player_level_lbl.text = "LVL " + str(Global.PLAYER_LEVEL)
		$player_level.scale.x = Global.PLAYER_XP / Global.TOTAL_XP

func turn():
	var where = get_random_free_cell()
	var what = Global.pick_random([Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])
	
	if what == Global.GridType.ENEMY:
		spawn_enemy(where)
	elif what == Global.GridType.WEAPON:
		spawn_weapon(where)
	elif what == Global.GridType.ITEM:
		spawn_item(where)
		
func spawn_weapon(pos: Vector2, level: int = 1):
	var weapon = weapon_scenes.instantiate()
	weapon.level = level
	weapon.global_position = pos
	add_child(weapon)
	
func spawn_item(pos: Vector2, level: int = 1):
	pass
		
func spawn_enemy(pos: Vector2, level: int = 1):
	var enemy = enemy_scenes.instantiate()
	enemy.level = level
	enemy.global_position = pos
	add_child(enemy)
			
func place_free_point(position: Vector2) -> bool:
	var space := get_viewport().get_world_2d().direct_space_state
	var pq := PhysicsPointQueryParameters2D.new()
	pq.position = position
	pq.collide_with_bodies = true
	pq.collide_with_areas = true  
	pq.collision_mask = 1 << 14

	var result := space.intersect_point(pq)
	return result.size() == 0
	
func get_random_free_cell():
	var cell := Vector2()
	var cell_size = 32
	var min_pos = Vector2(128, 32)
	var max_pos = min_pos + Vector2(32 * 8, 32 * 8)

	for t in range(100):
		var gx = randi_range(min_pos.x / cell_size, max_pos.x / cell_size) * cell_size
		var gy = randi_range(min_pos.y / cell_size, max_pos.y / cell_size) * cell_size
		cell = Vector2(gx, gy)
		if place_free_point(cell):
			return cell

func _on_timer_timeout() -> void:
	Global.TIME_LEFT -= 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	$time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
