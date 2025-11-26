extends Node2D
var levelup_scene = load("res://scenes/LevelUpScene.tscn")
var pause_scene = load("res://scenes/Pause.tscn")

var enemy_scenes = {
	1: preload("res://scenes/Enemy1x1.tscn"),
	2: preload("res://scenes/Enemy2x2.tscn"),
	3: preload("res://scenes/Enemy4x4.tscn")
}

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
	spawn_enemy(get_random_pos())
			
func place_free_point(position: Vector2) -> bool:
	var space := get_viewport().get_world_2d().direct_space_state
	var pq := PhysicsPointQueryParameters2D.new()
	pq.position = position
	pq.collide_with_bodies = true
	pq.collide_with_areas = true  
	pq.collision_mask = 1 << 14

	var result := space.intersect_point(pq)
	return result.size() == 0
		
func get_random_pos() -> Vector2:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var candidate : Vector2
	if randf() < 0.7 and enemies.size() > 0:
		var base = enemies.pick_random()
	
		var found = false
		for i in range(10): # hasta 10 intentos
			var dx = randi_range(-1, 1)
			var dy = randi_range(-1, 1)
			candidate = base.global_position + Vector2(dx * 32, dy * 32)
			
			if candidate.x >= (Global.CELL_SIZE * 3) \
					and candidate.y >= (Global.CELL_SIZE * 3) \
					and candidate.x < ((Global.GRID_W - 3) * 32) \
					and candidate.y < ((Global.GRID_H - 3) * 32):
						if place_free_point(candidate):
							found = true
							break
		
		if not found:
			candidate = get_random_free_cell()
	else:
		candidate = get_random_free_cell()
	
	return candidate
	
func get_random_free_cell():
	var cell := Vector2()
	for t in range(100):
		cell.x = randi_range(3, Global.GRID_W - 3) * 32
		cell.y = randi_range(3, Global.GRID_H - 3) * 32
		if place_free_point(cell):
			return cell
			
func spawn_enemy(pos: Vector2, level: int = 1):
	var enemy = enemy_scenes[level].instantiate()
	enemy.global_position = pos
	add_child(enemy)

func _on_timer_timeout() -> void:
	Global.TIME_LEFT -= 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	$time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
