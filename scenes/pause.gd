extends Node2D

func _ready() -> void:
	get_tree().paused = true
	$lbl_1/value.text = str(Global.BULLET_DMG * 100)
	$lbl_2/value.text = str(Global.TOTAL_LIFE)
	$lbl_3/value.text = str(Global.BULLET_TTL * 100)
	$lbl_4/value.text = str(Global.TOTAL_SPEED)
	$lbl_5/value.text = str(Global.COLLECT_RADIUS)
	$lbl_6/value.text = str(Global.SHOOT_TTL_TOTAL * 100)
	$lbl_8.text = "LVL: " + str(Global.PLAYER_LEVEL)

func _on_btn_aceptar_pressed() -> void:
	get_tree().paused = false
	queue_free()
