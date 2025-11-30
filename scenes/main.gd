extends Node2D
var player_scene = load("res://scenes/you.tscn")
var pause_scene = load("res://scenes/Pause.tscn")
var enemy_scenes = preload("res://scenes/Enemy1x1.tscn")
var weapon_scenes = preload("res://scenes/weapon.tscn")
var item_scenes = preload("res://scenes/item.tscn")

func _ready() -> void:
	calc_time()
	randomize()
	Global.Main = self
	var player = player_scene.instantiate()
	Global.GRID_ELEMENTS[2][2] = player
	add_child(player)
	for i in range(10):
		turn()
		
	render_grid()

func render_grid():
	for r in range(Global.ROWS):
		for c in range(Global.COLS):
			if Global.GRID_ELEMENTS[r][c] != null:
				Global.GRID_ELEMENTS[r][c].global_position = Vector2(c * 32, r * 32) + Global.OFFSET

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		var pause = pause_scene.instantiate()
		pause.global_position = Vector2(0, 60)
		add_child(pause)
	
	var direction = ""
	if Input.is_action_just_pressed("up"):
		direction = "up"
	elif Input.is_action_just_pressed("down"):
		direction = "down"
	elif Input.is_action_just_pressed("left"):
		direction = "left"
	elif Input.is_action_just_pressed("right"):
		direction = "right"
	
	if direction != "":
		var change = process_direction(direction)
		if true or change:
			render_grid()
			
func process_direction(direction):
	if direction == "right":
		for r in range(Global.ROWS):
			for c in range(Global.COLS - 2, -1, -1):
				var type = legal_movement(Global.GRID_ELEMENTS[r][c + 1], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r][c + 1] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r][c + 1].level
					Global.GRID_ELEMENTS[r][c + 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.ATTACK:
					pass
				elif type == Global.LegalMoves.GET_WEAPON:
					pass
				elif type == Global.LegalMoves.EXIT:
					pass
					
	if direction == "left":
		for r in range(Global.ROWS):
			for c in range(1, Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r][c - 1], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r][c - 1] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r][c - 1].level
					Global.GRID_ELEMENTS[r][c - 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.ATTACK:
					pass
				elif type == Global.LegalMoves.GET_WEAPON:
					pass
				elif type == Global.LegalMoves.EXIT:
					pass
					
	if direction == "up":
		for r in range(1, Global.ROWS):
			for c in range(Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r - 1][c], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r - 1][c] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r - 1][c].level
					Global.GRID_ELEMENTS[r - 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.ATTACK:
					pass
				elif type == Global.LegalMoves.GET_WEAPON:
					pass
				elif type == Global.LegalMoves.EXIT:
					pass
		
	if direction == "down":
		for r in range(Global.ROWS - 2, -1, -1):
			for c in range(Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r + 1][c], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r + 1][c] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r + 1][c].level
					Global.GRID_ELEMENTS[r + 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
				elif type == Global.LegalMoves.ATTACK:
					pass
				elif type == Global.LegalMoves.GET_WEAPON:
					pass
				elif type == Global.LegalMoves.EXIT:
					pass
		
func legal_movement(cell_to, cell_from):
	if cell_to == null:
		return Global.LegalMoves.MOVEMENT
	elif cell_from != null and cell_to != null and cell_from.type == cell_to.type \
		and cell_from.level == cell_to.level:
			return Global.LegalMoves.MERGE
	elif cell_from != null and cell_to != null \
	 	and (cell_from.type == Global.GridType.PLAYER or cell_to.type == Global.GridType.PLAYER) \
		and (cell_from.type == Global.GridType.ENEMY or cell_to.type == Global.GridType.ENEMY):
			return Global.LegalMoves.ATTACK
		
func turn():
	var what = Global.pick_random([Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])
	get_random_free_cell(what)

func spawn_weapon(level: int = 0):
	var weapon = weapon_scenes.instantiate()
	weapon.level = level
	add_child(weapon)
	return weapon
	
func spawn_item(level: int = 0):
	var item = item_scenes.instantiate()
	item.level = level
	add_child(item)
	return item
		
func spawn_enemy(level: int = 0):
	var enemy = enemy_scenes.instantiate()
	enemy.level = level
	add_child(enemy)
	return enemy
	
func is_space_available():
	for r in range(Global.ROWS):
		for c in range(Global.COLS):
			if Global.GRID_ELEMENTS[r][c] == null:
				return true
			
func get_random_free_cell(what):
	if is_space_available():
		while(true):
			var r = randi() % Global.ROWS
			var c = randi() % Global.COLS
			if Global.GRID_ELEMENTS[r][c] == null:
				if what == Global.GridType.ENEMY:
					Global.GRID_ELEMENTS[r][c] = spawn_enemy()
				elif what == Global.GridType.WEAPON:
					Global.GRID_ELEMENTS[r][c] = spawn_weapon()
				elif what == Global.GridType.ITEM:
					Global.GRID_ELEMENTS[r][c] = spawn_item()
					
				break

func _on_timer_timeout() -> void:
	Global.TIME_LEFT += 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	%time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
