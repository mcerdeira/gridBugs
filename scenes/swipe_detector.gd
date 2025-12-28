extends Node2D
var init_ttl = 0.5
var deactivate = true
var swipe_start: Vector2
var swipe_end: Vector2
var min_swipe_distance := 50.0 # píxeles

func _physics_process(delta: float) -> void:
	if init_ttl > 0:
		init_ttl -= 1 * delta
		if init_ttl <= 0:
			deactivate = false

func _unhandled_input(event):
	if !Global.GAME_OVER and Global.Main.cputurn_ttl <= 0:
		# Touch
		if event is InputEventScreenTouch:
			if event.pressed:
				swipe_start = event.position
			else:
				swipe_end = event.position
				_detect_swipe()

		# Mouse (para debug en PC)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				swipe_start = event.position
			else:
				swipe_end = event.position
				_detect_swipe()

func _detect_swipe():
	if !deactivate:
		var delta := swipe_end - swipe_start

		if delta.length() < min_swipe_distance:
			return # demasiado corto, lo ignoramos

		if abs(delta.x) > abs(delta.y):
			if delta.x > 0:
				Global.Main.receive_direction("right")
			else:
				Global.Main.receive_direction("left")
		else:
			if delta.y > 0:
				Global.Main.receive_direction("down")
			else:
				Global.Main.receive_direction("up")
