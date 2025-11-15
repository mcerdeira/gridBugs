extends Node2D
var ttl = 45.0
var idx = -1

func _physics_process(delta: float) -> void:
	ttl -= 1 * delta
	if ttl <= 0:
		Global.occupied_cells.remove_at(idx)
		queue_free()
