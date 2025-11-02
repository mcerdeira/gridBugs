extends Area2D

func _ready() -> void:
	add_to_group("player_collector")

func get_gem():
	get_parent().get_gem()
