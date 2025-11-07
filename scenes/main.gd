extends Node2D
const CELL_SIZE = 32
const GRID_W = 1024 / CELL_SIZE
const GRID_H = 640 / CELL_SIZE

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
	$player_level_lbl.text = "LVL " + str(Global.PLAYER_LEVEL)
	$player_level.scale.x = Global.PLAYER_XP / Global.TOTAL_XP
	Global.check_level_up()
	
	Global.ENEMY_SPAWN_TTL -= Global.PLAYER_LEVEL * delta
	if Global.ENEMY_SPAWN_TTL <= 0:
		check_merge()
		Global.ENEMY_SPAWN_TTL = Global.ENEMY_SPAWN_TTL_TOTAL
		spawn_enemy(get_random_pos())
		
func check_merge():
	var results: Array = has_3x3_square()
	if(results.size() > 0):
		var cc = 0
		for r in results:
			var obj = Global.occupied_cells_obj[r]
			if cc == 4:
				var enemy = enemy_scenes[2].instantiate()
				enemy.position = Global.occupied_cells[r] * CELL_SIZE
				enemy.idx = Global.occupied_cells.size()
				add_child(enemy)
				#Registrar celda usada
				Global.occupied_cells[r]
				Global.occupied_cells_obj[r] = enemy
				
			obj.mark()
			cc += 1

func get_random_pos() -> Vector2:
	var cell : Vector2i

	if Global.occupied_cells.size() > 0 and randf() < 0.7:
		# Elegir una celda base ya ocupada
		var base = Global.occupied_cells[randi() % Global.occupied_cells.size()]
		
		# Buscar una posición cercana dentro de un radio de 1 celdas, aleatoria
		var found = false
		for i in range(10): # hasta 10 intentos
			var dx = randi_range(-1, 1)
			var dy = randi_range(-1, 1)
			var candidate = base + Vector2i(dx, dy)
			
			if candidate.x >= 0 and candidate.x < GRID_W and candidate.y >= 0 and candidate.y < GRID_H and not Global.occupied_cells.has(candidate):
				cell = candidate
				found = true
				break
		
		if not found:
			cell = get_random_free_cell()
	else:
		cell = get_random_free_cell()
	
	return cell
	
func has_3x3_square() -> Array:
	var cell_idx = -1
	var result = []
	for cell in Global.occupied_cells:
		var x = int(cell.x)
		var y = int(cell.y)
		var found_square = true
		for dx in range(3):
			for dy in range(3):
				var pos = Vector2i(x + dx, y + dy)
				cell_idx = Global.occupied_cells.find(pos)
				if cell_idx == -1 or Global.occupied_cells_obj[cell_idx].marked:
					found_square = false
					break
				else:
					if Global.occupied_cells_obj[cell_idx].dead:
						Global.occupied_cells_obj[cell_idx].queue_free()
						
					result.append(cell_idx)
				
			if not found_square:
				result = []
				break
		if found_square:
			return result
	return []

func get_random_free_cell():
	var cell := Vector2i()
	while true:
		cell.x = randi_range(2, GRID_W - 2)
		cell.y = randi_range(3, GRID_H - 2)
		if not Global.occupied_cells.has(cell):
			return cell
			
func spawn_enemy(cell: Vector2i, level: int = 1):
	grid[cell * CELL_SIZE] = level
	
	var enemy = enemy_scenes[level].instantiate()
	enemy.position = cell * CELL_SIZE
	enemy.idx = Global.occupied_cells.size()
	add_child(enemy)
	#Registrar celda usada
	Global.occupied_cells.append(cell)
	Global.occupied_cells_obj.append(enemy)

func _on_timer_timeout() -> void:
	Global.TIME_LEFT -= 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	$time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
