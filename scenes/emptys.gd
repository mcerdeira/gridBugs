extends Node2D

func _ready() -> void:
	if !Global.TutorialLevel:
		queue_free()

func _physics_process(delta: float) -> void:
	if Global.Wok and Global.Aok and Global.Sok and Global.Dok:
		queue_free()
