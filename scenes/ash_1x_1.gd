extends Node2D
var ttl = 45.0
var idx_s = []

func _physics_process(delta: float) -> void:
	ttl -= 1 * delta
	for idx in idx_s:
		if ttl <= 0:
			Global.occupied_cells.remove_at(idx)
			queue_free()
