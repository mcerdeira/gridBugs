extends Node2D
var levelup_scene = load("res://scenes/LevelUpScene.tscn")
var pause_scene = load("res://scenes/Pause.tscn")

var enemy_scenes = {
	1: preload("res://scenes/Enemy1x1.tscn"),
	2: preload("res://scenes/Enemy2x2.tscn"),
	3: preload("res://scenes/Enemy4x4.tscn")
}

var grid = {}      
var grid_nodes := {}  # Vector2i -> Node (referencia al enemigo)

func _ready() -> void:
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
		
		Global.ENEMY_SPAWN_TTL -= Global.TIME_SIZE * delta
		if Global.ENEMY_SPAWN_TTL <= 0:
			if !all_occupied_cells():
				check_merge()
				check_mergex2()
				spawn_enemy(get_random_pos())
				Global.ENEMY_SPAWN_TTL = Global.ENEMY_SPAWN_TTL_TOTAL
		
func check_merge():
	var results: Array = has_square(2, Global.CELL_EGG)
	if(results.size() > 0):
		var cc = 0
		for r in results:
			Global.ash_cells[r].queue_free()
			Global.ash_cells[r] = null
			var obj = Global.occupied_cells[r]
			if cc == 0:
				var enemy = enemy_scenes[2].instantiate()
				enemy.global_position = Global.occupied_cells[r][0] + Vector2i(16, 16)
				enemy.idx_s = results
				add_child(enemy)
			
			#Registrar celda usada
			Global.occupied_cells[r][1] = Global.CELL_ENEMY
			cc += 1
			
func check_mergex2():
	var results: Array = has_square(4, Global.CELL_EGG_2)
	if(results.size() > 0):
		var cc = 0
		for r in results:
			Global.ash_cells[r].queue_free()
			Global.ash_cells[r] = null
			var obj = Global.occupied_cells[r]
			if cc == 0:
				var enemy = enemy_scenes[3].instantiate()
				enemy.global_position = Global.occupied_cells[r][0] + Vector2i(32, 32)
				enemy.idx_s = results
				add_child(enemy)
			
			#Registrar celda usada
			Global.occupied_cells[r][1] = Global.CELL_ENEMY
			cc += 1

func get_random_pos() -> int:
	var cell : Vector2i
	var idx: int
	var matches = find_by_int(Global.CELL_ENEMY)
	if randf() < 0.7 and Global.occupied_cells.size() > 0 and matches.size() > 0:
		# Elegir una celda base ya ocupada
		matches.shuffle()
		var id_random = matches.pop_at(0)
		var base = Global.occupied_cells[id_random]
		
		# Buscar una posición cercana dentro de un radio de 1 celdas, aleatoria
		var found = false
		for i in range(10): # hasta 10 intentos
			var dx = randi_range(-1, 1)
			var dy = randi_range(-1, 1)
			var candidate = base[0] + Vector2i(dx * 32, dy * 32)
			
			if candidate.x >= (Global.CELL_SIZE * 3) \
					and candidate.y >= (Global.CELL_SIZE * 3) \
					and candidate.x < ((Global.GRID_W - 3) * 32) \
					and candidate.y < ((Global.GRID_H - 3) * 32):
					idx = Global.occupied_cells.find([candidate, Global.CELL_EMPTY])
					if idx != -1:
						found = true
						break
		
		if not found:
			idx = get_random_free_cell()
	else:
		idx = get_random_free_cell()
	
	return idx
	
func find_by_int(value: int) -> Array:
	var matches = []
	for i in Global.occupied_cells.size():
		if Global.occupied_cells[i][1] == value:
			matches.append(i)
	return matches
	
func has_square(size: int, cell_kind: int) -> Array:
	var cell_idx = -1
	var result = []
	for cell in Global.occupied_cells:
		var x = int(cell[0].x)
		var y = int(cell[0].y)
		var found_square = true
		for dx in range(size):
			for dy in range(size):
				var pos = Vector2i(x + (dx * 32), y + (dy * 32))
				cell_idx = Global.occupied_cells.find([pos, cell_kind])
				if cell_idx == -1:
					found_square = false
					break
				else:
					result.append(cell_idx)
				
			if not found_square:
				result = []
				break
		if found_square:
			return result
	return []
	
func all_occupied_cells():
	for c in Global.occupied_cells:
		if c[1] == Global.CELL_EMPTY:
			return false
			
	return true

func get_random_free_cell():
	var cell := Vector2i()
	for t in range(100):
		cell.x = randi_range(3, Global.GRID_W - 3) * 32
		cell.y = randi_range(3, Global.GRID_H - 3) * 32
		var idx = Global.occupied_cells.find([cell, Global.CELL_EMPTY])
		if idx != -1:
			return idx
			
func spawn_enemy(idx: int, level: int = 1):
	if idx != -1:
		var enemy = enemy_scenes[level].instantiate()
		enemy.global_position = Global.occupied_cells[idx][0]
		enemy.idx_s = [idx]
		add_child(enemy)
		#Registrar celda usada
		Global.occupied_cells[idx][1] = Global.CELL_ENEMY

func _on_timer_timeout() -> void:
	Global.TIME_LEFT -= 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	$time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
