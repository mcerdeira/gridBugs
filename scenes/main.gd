extends Node2D
var player_scene = load("res://scenes/you.tscn")
var pause_scene = load("res://scenes/Pause.tscn")
var enemy_scenes = preload("res://scenes/Enemy1x1.tscn")
var weapon_scenes = preload("res://scenes/weapon.tscn")
var item_scenes = preload("res://scenes/item.tscn")
var key_scenes = preload("res://scenes/key.tscn")
var cputurn_ttl = 0

func _ready() -> void:
	calc_time()
	randomize()
	Global.Main = self
	var player = player_scene.instantiate()
	Global.GRID_ELEMENTS[2][2] = player
	add_child(player)
	for i in range(9):
		turn(true)
		
	%weapon_sprite.frame = Global.DMG - 1
	update_life()
	render_grid()

func render_grid():
	for r in range(Global.ROWS):
		for c in range(Global.COLS):
			if Global.GRID_ELEMENTS[r][c] != null:
				Global.GRID_ELEMENTS[r][c].global_position = Vector2(c * 32, r * 32) + Global.OFFSET

func update_life():
	if Global.life == 3:
		%Life.frame = 0
		%Life2.frame = 0
		%Life3.frame = 0
	elif Global.life == 2:
		%Life.frame = 0
		%Life2.frame = 0
		%Life3.frame = 1
	elif Global.life == 1:
		%Life.frame = 0
		%Life2.frame = 1
		%Life3.frame = 1
	elif Global.life == 0:
		%Life.frame = 1
		%Life2.frame = 1
		%Life3.frame = 1
		
func _physics_process(delta: float) -> void:
	$lbl_gameover.visible = Global.GAME_OVER
	%lbl_dmg.text = "dmg " + str(Global.DMG + 1)
	
	if Input.is_action_just_pressed("pause"):
		var pause = pause_scene.instantiate()
		pause.global_position = Vector2(0, 60)
		add_child(pause)
		
	if cputurn_ttl > 0:
		cputurn_ttl -= 1 * delta
		if cputurn_ttl <= 0:
			turn()
			render_grid()
		
	if !Global.GAME_OVER and cputurn_ttl <= 0:
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
			if change:
				Global.play_sound(Global.WalkSFX1)
				cputurn_ttl = 0.3
				%weapon_sprite.frame = Global.DMG
				render_grid()
				
func set_item_inspect(node):
	if node:
		Global.play_sound(Global.BeepSFX)
		%ficha.visible = true
		%item.texture = node.get_texture()
		%description.text = node.text
							
func process_direction(direction):
	var movement = false
	if direction == "right":
		for r in range(Global.ROWS):
			for c in range(Global.COLS - 2, -1, -1):
				var type = legal_movement(Global.GRID_ELEMENTS[r][c + 1], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r][c + 1] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r][c + 1].level
					Global.GRID_ELEMENTS[r][c + 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r, c + 1, r, c, Global.GridType.ENEMY)
					if Global.DMG <= enemy.node.level:
						player.node.hit(enemy.node.level)
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].queue_free()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r, c + 1, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)

					Global.GRID_ELEMENTS[weapon.r][weapon.c].queue_free()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c + 1, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].queue_free()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
					
	if direction == "left":
		for r in range(Global.ROWS):
			for c in range(1, Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r][c - 1], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r][c - 1] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r][c - 1].level
					Global.GRID_ELEMENTS[r][c - 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r, c - 1, r, c, Global.GridType.ENEMY)
					if Global.DMG <= enemy.node.level:
						player.node.hit(enemy.node.level)
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].queue_free()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r, c - 1, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].queue_free()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c - 1, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					
					Global.GRID_ELEMENTS[item.r][item.c].queue_free()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
					
	if direction == "up":
		for r in range(1, Global.ROWS):
			for c in range(Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r - 1][c], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r - 1][c] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r - 1][c].level
					Global.GRID_ELEMENTS[r - 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r - 1, c, r, c, Global.GridType.ENEMY)
					if Global.DMG <= enemy.node.level:
						player.node.hit(enemy.node.level)
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].queue_free()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r - 1, c, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].queue_free()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r - 1, c, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].queue_free()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
		
	if direction == "down":
		for r in range(Global.ROWS - 2, -1, -1):
			for c in range(Global.COLS):
				var type = legal_movement(Global.GRID_ELEMENTS[r + 1][c], Global.GRID_ELEMENTS[r][c])
				if type == Global.LegalMoves.MOVEMENT:
					Global.GRID_ELEMENTS[r + 1][c] = Global.GRID_ELEMENTS[r][c]
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.MERGE:
					var level = Global.GRID_ELEMENTS[r + 1][c].level
					Global.GRID_ELEMENTS[r + 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r + 1, c, r, c, Global.GridType.ENEMY)
					if Global.DMG <= enemy.node.level:
						player.node.hit(enemy.node.level)
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].queue_free()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r + 1, c, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].queue_free()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r + 1, c, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].queue_free()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
	
	return movement
		
func get_cell_by_type(r1, c1, r2, c2, type):
	if Global.GRID_ELEMENTS[r1][c1].type == type:
		return {"node": Global.GRID_ELEMENTS[r1][c1], "r": r1, "c": c1}
	elif Global.GRID_ELEMENTS[r2][c2].type == type:
		return {"node": Global.GRID_ELEMENTS[r2][c2], "r": r2, "c": c2}
	else:
		return null
		
func legal_movement(cell_to, cell_from):
	if cell_to == null:
		return Global.LegalMoves.MOVEMENT
	elif cell_from != null and cell_to != null and cell_from.type == cell_to.type \
		and cell_from.level == cell_to.level:
			return Global.LegalMoves.MERGE
	elif cell_from != null and cell_to != null \
	 	and ((cell_from.type == Global.GridType.PLAYER and cell_to.type == Global.GridType.ENEMY) \
		or (cell_from.type == Global.GridType.ENEMY and cell_to.type == Global.GridType.PLAYER)):
			return Global.LegalMoves.ATTACK
	elif cell_from != null and cell_to != null \
	 	and ((cell_from.type == Global.GridType.PLAYER and cell_to.type == Global.GridType.ITEM) \
		or (cell_from.type == Global.GridType.ITEM and cell_to.type == Global.GridType.PLAYER)):
			return Global.LegalMoves.GET_ITEM
	elif cell_from != null and cell_to != null \
	 	and ((cell_from.type == Global.GridType.PLAYER and cell_to.type == Global.GridType.KEY) \
		or (cell_from.type == Global.GridType.KEY and cell_to.type == Global.GridType.PLAYER)):
			return Global.LegalMoves.GET_KEY
	elif cell_from != null and cell_to != null \
	 	and ((cell_from.type == Global.GridType.PLAYER and cell_to.type == Global.GridType.WEAPON) \
		or (cell_from.type == Global.GridType.WEAPON and cell_to.type == Global.GridType.PLAYER)):
			return Global.LegalMoves.GET_WEAPON
	else:
		return Global.LegalMoves.NON
		
func turn(nokeys = false):
	if Global.NEXT == null:
		if Global.KeyAppeared or nokeys:
			Global.NEXT = Global.pick_random([Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])
		else:
			Global.NEXT = Global.pick_random([Global.GridType.KEY, Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])
	
	var what = Global.NEXT
	get_random_free_cell(what)
	if Global.KeyAppeared or nokeys:
		Global.NEXT = Global.pick_random([Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])
	else:
		Global.NEXT = Global.pick_random([Global.GridType.KEY, Global.GridType.ENEMY, Global.GridType.WEAPON, Global.GridType.ITEM])

	display_next()
	
func display_next():
	if Global.NEXT == Global.GridType.ENEMY:
		$Panel2/lbl_next/sprite.animation = "enemies"
	elif Global.NEXT == Global.GridType.WEAPON:
		$Panel2/lbl_next/sprite.animation = "weapons"
	elif Global.NEXT == Global.GridType.ITEM:
		$Panel2/lbl_next/sprite.animation = "items"
	elif Global.NEXT == Global.GridType.KEY:
		$Panel2/lbl_next/sprite.animation = "keys"

func spawn_weapon(level: int = 1):
	var weapon = weapon_scenes.instantiate()
	weapon.level = level
	add_child(weapon)
	return weapon
	
func spawn_item(level: int = 1):
	var item = item_scenes.instantiate()
	item.level = level
	add_child(item)
	return item
		
func spawn_enemy(level: int = 1):
	var enemy = enemy_scenes.instantiate()
	enemy.level = level
	add_child(enemy)
	return enemy
	
func spawn_key():
	Global.KeyAppeared = true
	var key = key_scenes.instantiate()
	add_child(key)
	return key
	
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
				elif what == Global.GridType.KEY:
					Global.GRID_ELEMENTS[r][c] = spawn_key()
					
				break

func _on_timer_timeout() -> void:
	Global.TIME_LEFT += 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	%time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
