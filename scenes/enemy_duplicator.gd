extends Node2D
var enemy_obj = load("res://scenes/Enemy1x1.tscn")
var enemy = null
@export var wait_time = 1.0

func _ready() -> void:
	$Timer.wait_time = wait_time
	$Timer.start()
	
func notify():
	enemy = null
	await get_tree().create_timer(2.3).timeout
	$Timer.start()

func _on_timer_timeout() -> void:
	if enemy == null:
		$Timer.stop()
		enemy = enemy_obj.instantiate()
		enemy.global_position = global_position
		enemy.cangrow = false
		enemy.notify_death = self
		get_tree().get_current_scene().add_child(enemy)
