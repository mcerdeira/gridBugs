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
	randomize()

func _physics_process(delta: float) -> void:
	Global.ENEMY_SPAWN_TTL -= 1 * delta
	if Global.ENEMY_SPAWN_TTL <= 0:
		Global.ENEMY_SPAWN_TTL = Global.ENEMY_SPAWN_TTL_TOTAL
		spawn_enemy(get_random_pos())
		
func get_random_pos() -> Vector2:
	var cell : Vector2i

	if Global.occupied_cells.size() > 0 and randf() < 0.7:
		# Elegir una celda base ya ocupada
		var base = Global.occupied_cells[randi() % Global.occupied_cells.size()]
		
		# Buscar una posición cercana dentro de un radio de 2 celdas, aleatoria
		var found = false
		for i in range(10): # hasta 10 intentos
			var dx = randi_range(-2, 2)
			var dy = randi_range(-2, 2)
			var candidate = base + Vector2i(dx, dy)
			
			if candidate.x >= 0 and candidate.x < GRID_W and candidate.y >= 0 and candidate.y < GRID_H and not Global.occupied_cells.has(candidate):
				cell = candidate
				found = true
				break
		
		if not found:
			cell = get_random_free_cell()
	else:
		cell = get_random_free_cell()
	
	# Registrar celda usada
	Global.occupied_cells.append(cell)
	
	return cell * CELL_SIZE

func get_random_free_cell():
	var cell := Vector2i()
	while true:
		cell.x = randi_range(1, GRID_W - 1)
		cell.y = randi_range(1, GRID_H - 1)
		if not Global.occupied_cells.has(cell):
			return cell
			
func spawn_enemy(cell: Vector2i, level: int = 1):
	if grid.has(cell):
		return # ya ocupado

	grid[cell] = level

	var enemy = enemy_scenes[level].instantiate()
	enemy.position = cell
	add_child(enemy)
