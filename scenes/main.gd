extends Node2D
var player_scene = load("res://scenes/you.tscn")
var enemy_scenes = preload("res://scenes/Enemy1x1.tscn")
var weapon_scenes = preload("res://scenes/weapon.tscn")
var item_scenes = preload("res://scenes/item.tscn")
var key_scenes = preload("res://scenes/key.tscn")
var letter_scenes = preload("res://scenes/letter.tscn")
var cputurn_ttl = 0

func _ready() -> void:
	randomize()
	if !Music.is_playing():
		Music.play(Global.MainTheme)
		
	Global.define_objetives()
	Global.KeyAppeared = false
	Global.Main = self	
	if !Global.TutorialLevel:
		var player = player_scene.instantiate()
		Global.GRID_ELEMENTS[2][2] = player
		add_child(player)
		for i in range(7):
			turn(true)
		%weapon_sprite.frame = Global.DMG
		$Panel1/lbl_tutorial.visible = false
		$Panel2/lbl_tutorial.visible = false
	else:
		%lbl_floor.text = "Floor #" + str(Global.FLOOR)
		set_main_quest()
		
		var player = player_scene.instantiate()
		Global.GRID_ELEMENTS[0][4] = player
		add_child(player)
		%weapon_sprite.visible = false
		$Panel1/lbl_inspect.visible = false
		$Panel1/lbl_weapon.visible = false
		%lbl_floor.text = "Floor #0"
		$Panel2/lbl_next.visible = false
		$Panel2/lbl_quest.visible = false
		$Panel1/lbl_tutorial.visible = true
		$Panel2/lbl_tutorial.visible = true
		Global.GRID_ELEMENTS[0][0] = spawn_letter("W")
		Global.GRID_ELEMENTS[4][2] = spawn_letter("D")
		Global.GRID_ELEMENTS[3][1] = spawn_letter("S")
		Global.GRID_ELEMENTS[2][0] = spawn_letter("A")
		
	update_life()
	render_grid()

func set_main_quest():
	Global.MainQuest = {}
	
	var objs = Global.pick_random(Global.Objetives[0])
	Global.MainQuest = {
		"objetives": objs,
		"status": false
	}
	render_mainquest()
	
func render_mainquest():
	var objs = Global.MainQuest.objetives
	
	$Panel2/lbl_quest/quest1.animation = trad_enum_animation(objs[0].what)
	$Panel2/lbl_quest/quest1.frame = objs[0].lvl - 1 
	$Panel2/lbl_quest/quest1/lbl_cant.text = str(objs[0].got) + "/" + str(objs[0].cant)
	
	$Panel2/lbl_quest/quest2.animation = trad_enum_animation(objs[1].what)
	$Panel2/lbl_quest/quest2.frame = objs[1].lvl - 1 
	$Panel2/lbl_quest/quest2/lbl_cant.text = str(objs[1].got) + "/" + str(objs[1].cant)
	
	$Panel2/lbl_quest/quest3.animation = trad_enum_animation(objs[2].what)
	$Panel2/lbl_quest/quest3.frame = objs[2].lvl - 1 
	$Panel2/lbl_quest/quest3/lbl_cant.text = str(objs[2].got) + "/" + str(objs[2].cant)
	
	$Panel2/lbl_quest/lbl_quest_done.visible = Global.MainQuest.status


func render_grid():
	for r in range(Global.ROWS):
		for c in range(Global.COLS):
			if Global.GRID_ELEMENTS[r][c] != null:
				Global.GRID_ELEMENTS[r][c].global_position = Vector2(c * 32, r * 32) + Global.OFFSET

func update_life():
	if Global.life == 3:
		%Life.animation = "default"
		%Life2.animation = "default"
		%Life3.animation = "default"
	elif Global.life == 2:
		%Life.animation = "default"
		%Life2.animation = "default"
		%Life3.animation = "off"
	elif Global.life == 1:
		%Life.animation = "default"
		%Life2.animation = "off"
		%Life3.animation = "off"
	elif Global.life == 0:
		%Life.animation = "off"
		%Life2.animation = "off"
		%Life3.animation = "off"
		
func _physics_process(delta: float) -> void:
	$Panel1/You/You.frame = 3 - Global.life
	
	if !Global.TutorialLevel:
		$lbl_gameover.visible = Global.GAME_OVER
	else:
		$lbl_gameover.visible = true
		
	%lbl_dmg.text = "dmg " + str(Global.DMG)
	
	if Global.GAME_OVER:
		$Panel1/You/You.animation = "dead"
		
	if Global.GAME_OVER:
		if Input.is_action_just_pressed("restart"):
			Global.game_reset()
			get_tree().reload_current_scene()
			
	if cputurn_ttl > 0:
		cputurn_ttl -= 1 * delta
		if cputurn_ttl <= 0:
			if !Global.TutorialLevel:
				turn()
			else:
				check_all_letters()
				if Global.Wok and Global.Aok and Global.Sok and Global.Dok:
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
		
		receive_direction(direction)
				
func check_all_letters():
	var letters = get_tree().get_nodes_in_group("letters")
	for letter in letters:
		if letter.letter == "W":
			if letter.global_position == Global.WPos:
				Global.Wok = true
			else:
				Global.Wok = false
		if letter.letter == "A":
			if letter.global_position == Global.APos:
				Global.Aok = true
			else:
				Global.Aok = false
		if letter.letter == "S":
			if letter.global_position == Global.SPos:
				Global.Sok = true
			else:
				Global.Sok = false
		if letter.letter == "D":
			if letter.global_position == Global.DPos:
				Global.Dok = true
			else:
				Global.Dok = false
				
func receive_direction(direction):
	if !Global.GAME_OVER and cputurn_ttl <= 0:
		if direction != "":
			var change = process_direction(direction)
			if change:
				Global.play_sound(Global.WalkSFX1)
				cputurn_ttl = 0.3
				%weapon_sprite.frame = Global.DMG
				check_main_quest()
				render_grid()
				render_mainquest()
				
func check_main_quest():
	if !Global.MainQuest.status:
		var quest = true
		for obj in Global.MainQuest.objetives:
			if obj.got < obj.cant:
				quest = false
				break
				
		Global.MainQuest.status = quest
		if Global.MainQuest.status:
			open_door()
				
func set_item_inspect(node, is_door = false):
	if node:
		Global.play_sound(Global.BeepSFX)
		if is_door:
			%ficha.visible = false
		else:
			%ficha.visible = true
		%item.texture = node.get_texture()
		%description.text = node.text
		
func merge_sound(type):
	if type == Global.GridType.ITEM:
		Global.play_sound(Global.PotionMergeSFX)
	elif type == Global.GridType.ENEMY:
		Global.play_sound(Global.MonsterMergeSFX)
	elif type == Global.GridType.WEAPON:
		Global.play_sound(Global.WeaponMergeSFX)
							
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
					merge_sound(Global.GRID_ELEMENTS[r][c].type)
					Global.GRID_ELEMENTS[r][c + 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r, c + 1, r, c, Global.GridType.ENEMY)
					if Global.DMG < enemy.node.level:
						player.node.hit(enemy.node.level)
					player.node.attack()
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].die()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r, c + 1, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)

					Global.GRID_ELEMENTS[weapon.r][weapon.c].die()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c + 1, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].die()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c + 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_KEY:
					var player = get_cell_by_type(r, c + 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c + 1, r, c, Global.GridType.KEY)
					Global.play_sound(Global.KeysSFX)
					open_door()
					
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
					merge_sound(Global.GRID_ELEMENTS[r][c].type)
					Global.GRID_ELEMENTS[r][c - 1].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r, c - 1, r, c, Global.GridType.ENEMY)
					if Global.DMG < enemy.node.level:
						player.node.hit(enemy.node.level)
					player.node.attack()
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].die()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r, c - 1, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].die()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c - 1, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					
					Global.GRID_ELEMENTS[item.r][item.c].die()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r][c - 1] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_KEY:
					var player = get_cell_by_type(r, c - 1, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r, c - 1, r, c, Global.GridType.KEY)
					Global.play_sound(Global.KeysSFX)
					open_door()
					
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
					merge_sound(Global.GRID_ELEMENTS[r][c].type)
					Global.GRID_ELEMENTS[r - 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r - 1, c, r, c, Global.GridType.ENEMY)
					if Global.DMG < enemy.node.level:
						player.node.hit(enemy.node.level)
					player.node.attack()
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].die()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r - 1, c, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].die()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r - 1, c, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].die()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r - 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_KEY:
					var player = get_cell_by_type(r - 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r - 1, c, r, c, Global.GridType.KEY)
					Global.play_sound(Global.KeysSFX)
					open_door()
					
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
					merge_sound(Global.GRID_ELEMENTS[r][c].type)
					Global.GRID_ELEMENTS[r + 1][c].set_level(level+1)
					Global.GRID_ELEMENTS[r][c].queue_free()
					Global.GRID_ELEMENTS[r][c] = null
					movement = true
				elif type == Global.LegalMoves.ATTACK:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var enemy =  get_cell_by_type(r + 1, c, r, c, Global.GridType.ENEMY)
					if Global.DMG < enemy.node.level:
						player.node.hit(enemy.node.level)
					player.node.attack()
					
					Global.GRID_ELEMENTS[enemy.r][enemy.c].die()
					Global.GRID_ELEMENTS[enemy.r][enemy.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_WEAPON:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var weapon = get_cell_by_type(r + 1, c, r, c, Global.GridType.WEAPON)
					Global.DMG = weapon.node.level
					Global.play_sound(Global.WeaponSFX)
					
					Global.GRID_ELEMENTS[weapon.r][weapon.c].die()
					Global.GRID_ELEMENTS[weapon.r][weapon.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_ITEM:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r + 1, c, r, c, Global.GridType.ITEM)
					player.node.heal(item.node.level)
					Global.play_sound(Global.HealSFX)
					
					Global.GRID_ELEMENTS[item.r][item.c].die()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
				elif type == Global.LegalMoves.GET_KEY:
					var player = get_cell_by_type(r + 1, c, r, c, Global.GridType.PLAYER)
					var item = get_cell_by_type(r + 1, c, r, c, Global.GridType.KEY)
					Global.play_sound(Global.KeysSFX)
					open_door()
					
					Global.GRID_ELEMENTS[item.r][item.c].queue_free()
					Global.GRID_ELEMENTS[item.r][item.c] = null
					Global.GRID_ELEMENTS[player.r][player.c] = null
					Global.GRID_ELEMENTS[r + 1][c] = player.node
					movement = true
	
	return movement
	
func open_door():
	await get_tree().create_timer(0.5).timeout
	%door.animation = "open"
	Global.play_sound(Global.DoorSFX)
	await get_tree().create_timer(0.5).timeout
	%door.material.set_shader_parameter("maxLineWidth", 10.0)
		
func get_cell_by_type(r1, c1, r2, c2, type):
	if Global.GRID_ELEMENTS[r1][c1].type == type:
		return {"node": Global.GRID_ELEMENTS[r1][c1], "r": r1, "c": c1}
	elif Global.GRID_ELEMENTS[r2][c2].type == type:
		return {"node": Global.GRID_ELEMENTS[r2][c2], "r": r2, "c": c2}
	else:
		return null
		
func legal_movement(cell_to, cell_from):
	if cell_from != null and cell_to != null and cell_from.type == Global.GridType.LETTER and cell_to.type == Global.GridType.LETTER:
		return Global.LegalMoves.NON
	
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
		
func weighted_random_enum(table: Dictionary) -> Dictionary:
	var total := 0.0
	for w in table.values():
		total += w

	var r := randf() * total
	var acc := 0.0
	var what = null
	
	what = table.keys()[-1]

	for key in table.keys():
		acc += table[key]
		if r <= acc:
			what = key
			break
			
	var lvl = get_rng_max_level(what)
	return {"what": what, "level": lvl}
		
func get_rng_max_level(what):
	var obj = []
	var lvl = 1
	if what == Global.GridType.ENEMY:
		obj = get_tree().get_nodes_in_group("enemy")
	elif what == Global.GridType.WEAPON:
		obj = get_tree().get_nodes_in_group("weapon")
	elif what == Global.GridType.ITEM:
		obj = get_tree().get_nodes_in_group("item")
	elif what == Global.GridType.KEY:
		return 1
		
	for o in obj:
		if o.level > lvl:
			lvl = o.level
			
	return randi_range(1, lvl)

		
func turn(nokeys = false):
	if Global.TutorialLevel:
		if !Global.KeyAppeared:
			Global.KeyAppeared = true
			var what = {"what": Global.GridType.KEY, "level": 1} 
			get_random_free_cell(what)
	else:
		if Global.NEXT == null:
			if Global.KeyAppeared or nokeys:
				Global.NEXT = weighted_random_enum(Global.spawn_weights)
			else:
				Global.NEXT = weighted_random_enum(Global.spawn_weights_full)
		
		var what = Global.NEXT
		get_random_free_cell(what)
		if Global.KeyAppeared or nokeys:
			Global.NEXT = weighted_random_enum(Global.spawn_weights)
		else:
			Global.NEXT = weighted_random_enum(Global.spawn_weights_full)

		display_next()
	
func display_next():
	$Panel2/lbl_next/sprite.animation = trad_enum_animation(Global.NEXT.what)
	$Panel2/lbl_next/sprite.frame = Global.NEXT.level - 1
		
func trad_enum_animation(type):
	if type == Global.GridType.ENEMY:
		return "enemies"
	elif type  == Global.GridType.WEAPON:
		return "weapons"
	elif type  == Global.GridType.ITEM:
		return "items"
	elif type == Global.GridType.KEY:
		return "keys"

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
	
func spawn_letter(letter):
	var item = letter_scenes.instantiate()
	item.letter = letter
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
				if what.what == Global.GridType.ENEMY:
					Global.GRID_ELEMENTS[r][c] = spawn_enemy(what.level)
				elif what.what == Global.GridType.WEAPON:
					Global.GRID_ELEMENTS[r][c] = spawn_weapon(what.level)
				elif what.what == Global.GridType.ITEM:
					Global.GRID_ELEMENTS[r][c] = spawn_item(what.level)
				elif what.what == Global.GridType.KEY:
					Global.GRID_ELEMENTS[r][c] = spawn_key()
					
				break

func _on_timer_timeout() -> void:
	Global.TIME_LEFT += 1
	calc_time()

func calc_time():
	Global.minutes = int(Global.TIME_LEFT / 60)
	Global.seconds = int(Global.TIME_LEFT % 60)
	%time_elpased.text = "%d:%02d" % [Global.minutes, Global.seconds]
