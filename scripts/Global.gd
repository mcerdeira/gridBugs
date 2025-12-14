extends Node
const CELL_SIZE = 32
const ROWS = 5
const COLS = 5
const OFFSET = Vector2(192, 96)

var GRID_ELEMENTS = [] #rows,cols
var GAME_OVER = false
var Main = null
var FULLSCREEN = false
var shaker_obj = null      
var TIME_SIZE = 1.0
var TIME_LEFT = 0
var minutes = 0
var seconds = 0
var player = null
var life = 3
var DMG = 0
var KeyAppeared = false
var NEXT = null
var MainQuest = {}
var Objetives = []

var HurtSFX = null
var WalkSFX1 = null
var WalkSFX2 = null
var BeepSFX = null
var WeaponSFX = null
var HealSFX = null
var DoorSFX = null
var KeysSFX = null
var EnemyHitSFX = null
var PlayerDieSFX = null

enum GridType { 
	ENEMY,
	WEAPON,
	ITEM,
	PLAYER,
	KEY,
}

var spawn_weights := {
	GridType.ENEMY: 60,
	GridType.WEAPON: 20,
	GridType.ITEM: 20,
}

var spawn_weights_full := {
	GridType.ENEMY: 50,
	GridType.WEAPON: 23,
	GridType.ITEM: 30,
	GridType.KEY: 2,
}

enum LegalMoves {
	NON,
	MOVEMENT,
	MERGE,
	ATTACK,
	GET_WEAPON,
	GET_ITEM,
	GET_KEY,
}

func _ready() -> void:
	var easy = [
		[
			{"what": Global.GridType.ENEMY, "lvl": 1, "cant": 1},
			{"what": Global.GridType.WEAPON, "lvl": 1, "cant": 3},
			{"what": Global.GridType.ITEM, "lvl": 2, "cant": 1}
		],
		[
			{"what": Global.GridType.ENEMY, "lvl": 1, "cant": 2},
			{"what": Global.GridType.ENEMY, "lvl": 2, "cant": 1},
			{"what": Global.GridType.WEAPON, "lvl": 2, "cant": 2},
		]
	]
	
	var medium = [
		[
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0}
		],
		[
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
		]
	]
	
	var hard = [
		[
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0}
		],
		[
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
			{"what": null, "lvl": 0, "cant": 0},
		]
	]
	
	
	Objetives = [easy, medium, hard]
	
	
	for i in 5:
		var row = []
		for j in 5:
			row.append(null)
		GRID_ELEMENTS.append(row)
		
	load_sfx()
	
func load_sfx():
	HurtSFX = load("res://sfx/hurt_snd.ogg")
	WalkSFX1 = load("res://sfx/walk.mp3")
	BeepSFX = load("res://sfx/beep.mp3")
	WeaponSFX = load("res://sfx/sword.5.ogg")
	HealSFX = load("res://sfx/heal.wav")
	KeysSFX = load("res://sfx/keys_01.ogg")
	DoorSFX = load("res://sfx/door_open.wav")
	PlayerDieSFX = load("res://sfx/PlayerDieSfx.wav")
	EnemyHitSFX = load("res://sfx/EnemyHit.wav")	

#func emit(_global_position, count, particle_obj = null, size = 1):
	#var part = particle
	#if particle_obj:
		#part = particle_obj
	#
	#for i in range(count):
		#var p = part.instantiate()
		#p.global_position = _global_position
		#p.size = size
		#add_child(p)
	
func pick_random(container):
	if typeof(container) == TYPE_DICTIONARY:
		return container.values()[randi() % container.size() ]
	assert( typeof(container) in [
			TYPE_ARRAY, TYPE_PACKED_COLOR_ARRAY, TYPE_PACKED_INT32_ARRAY,
			TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_STRING_ARRAY,
			TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY
			], "ERROR: pick_random" )
	return container[randi() % container.size()]

func play_sound(stream: AudioStream, options:= {}, _global_position = null, delay = 0.0) -> AudioStreamPlayer:
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS

	add_child(audio_stream_player)
	audio_stream_player.stream = stream
	audio_stream_player.bus = "SFX"
	
	for prop in options.keys():
		audio_stream_player.set(prop, options[prop])
		
	if delay > 0.0:
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		timer.connect("timeout", audio_stream_player.play)
		add_child(timer)
		timer.start()
	else:
		audio_stream_player.play()
		
	audio_stream_player.finished.connect(kill.bind(audio_stream_player))
	
	return audio_stream_player
	
func kill(_audio_stream_player):
	if _audio_stream_player and is_instance_valid(_audio_stream_player):
		_audio_stream_player.queue_free()
