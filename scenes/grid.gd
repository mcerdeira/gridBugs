extends Node2D
const OFFSET := Global.CELL_SIZE / 2

func _ready() -> void:
	queue_redraw()

func _draw():
	var size := get_viewport_rect().size
	
	# Líneas verticales
	for x in range(OFFSET, int(size.x) + OFFSET, Global.CELL_SIZE):
		draw_line(Vector2(x, OFFSET), Vector2(x, size.y - OFFSET), Color(1, 1, 1, 0.2), 1)

	# Líneas horizontales
	for y in range(OFFSET, int(size.y) + OFFSET, Global.CELL_SIZE):
		draw_line(Vector2(OFFSET, y), Vector2(size.x - OFFSET, y), Color(1, 1, 1, 0.2), 1)
