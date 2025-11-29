extends Node2D

const CELL_SIZE : int = 32
const CENTER := Vector2(256, 160)  # centro donde está el personaje
const RANGE  : int = 2             # 2 celdas hacia arriba/abajo y 2 a los lados

func _draw():
	# número de celdas por lado (por ejemplo RANGE=2 -> 5 celdas)
	var cells_count = RANGE * 2 + 1

	# los límites deben moverse medio cell extra para que las líneas queden en los bordes de celdas
	var half_extra = 0.5 * CELL_SIZE
	var min_x = CENTER.x - (RANGE * CELL_SIZE + half_extra)
	var max_x = CENTER.x + (RANGE * CELL_SIZE + half_extra)
	var min_y = CENTER.y - (RANGE * CELL_SIZE + half_extra)
	var max_y = CENTER.y + (RANGE * CELL_SIZE + half_extra)

	# dibuja líneas verticales (cells_count + 1 líneas)
	for i in range(cells_count + 1):
		var x = min_x + i * CELL_SIZE
		draw_line(Vector2(x, min_y), Vector2(x, max_y), Color(1,1,1), 1)

	# dibuja líneas horizontales (cells_count + 1 líneas)
	for j in range(cells_count + 1):
		var y = min_y + j * CELL_SIZE
		draw_line(Vector2(min_x, y), Vector2(max_x, y), Color(1,1,1), 1)

	# opcional: rectángulo alrededor de la grilla
	draw_rect(Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y)), Color(0,0,0,0), false, 1)
