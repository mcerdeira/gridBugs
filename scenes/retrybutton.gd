extends Area2D

func _ready() -> void:
	if Global.TutorialLevel:
		$"..".text = ""
		$"../button/lbl_retry".text = "Restart"

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Global.GAME_OVER or Global.TutorialLevel:
		if Input.is_action_just_pressed("mouseLeft"):
			Global.game_reset()
			get_tree().reload_current_scene()
