extends Node2D

func _ready() -> void:
	get_tree().paused = true

func _on_btn_aceptar_pressed() -> void:
	get_tree().paused = false
	queue_free()
