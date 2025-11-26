extends Node
const CELL_SIZE = 32
const GRID_W = 480 / CELL_SIZE
const GRID_H = 288 / CELL_SIZE

var GAME_OVER = false
var Main = null

var FULLSCREEN = false
var shaker_obj = null      
var PLAYER_XP = 0.0
var TOTAL_XP = 0.0
var TOTAL_LIFE = 10.0
var PLAYER_LEVEL = 1
var TIME_SIZE = 1.0
var SHOOT_TTL_TOTAL = 0.3
var COLLECT_RADIUS = 20.0

var TIME_LEFT = 5 * 60
var minutes = 0
var seconds = 0

var ENEMY_BASE_LIFE = 5.0
var BULLET_TTL = 0.1
var BULLET_DMG = 1.0
var TOTAL_SPEED = 150.0
var player = null

var GUNS = []
var ITEMS = []

var item_range_up = {
	"name": "Range Up",
	"action": func(): range_up(),
	"increase": " (+10%)",
	"depends": null
}

var item_dmg_up = {
	"name": "Damage Up",
	"action": func(): dmg_up(),
	"increase": " (+15%)",
	"depends": null
}

var item_max_life_up = {
	"name": "Max Life Up",
	"action": func(): max_life_up(),
	"increase": " (+10%)",
	"depends": null
}

var item_max_speed_up = {
	"name": "Max Speed Up",
	"action": func(): max_speed_up(),
	"increase": " (+10%)",
	"depends": null
}

var item_collect_range_up = {
	"name": "Collect Range Up",
	"action": func(): max_speed_up(),
	"increase": " (+20%)",
	"depends": null
}

var item_max_shoot_ttl = {
	"name": "Shoot Cadence Up",
	"action": func(): max_shoot_ttl(),
	"increase": " (+10%)",
	"depends": null
}

func max_shoot_ttl():
	Global.player.max_shoot_ttl()

func max_collect_up():
	Global.player.max_collect_up()

func max_speed_up():
	Global.TOTAL_SPEED *= 1.10

func max_life_up():
	Global.TOTAL_LIFE *= 1.10

func range_up():
	BULLET_TTL *= 1.20
	
func dmg_up():
	BULLET_DMG *= 1.15

func init_vars():
	BULLET_DMG = 1.0
	TOTAL_XP = calc_totalxp()
	ITEMS.append(item_dmg_up)
	ITEMS.append(item_range_up)
	ITEMS.append(item_max_life_up)
	ITEMS.append(item_max_speed_up)
	ITEMS.append(item_collect_range_up)
	ITEMS.append(item_max_shoot_ttl)
	
func check_level_up():
	if Global.PLAYER_XP >= Global.TOTAL_XP:
		TIME_SIZE *= 1.10
		PLAYER_LEVEL += 1
		Global.PLAYER_XP = 0.0
		TOTAL_XP = calc_totalxp()
		return true
	
func get_gem():
	Global.PLAYER_XP += 1.0

func calc_totalxp():
	var next_level = PLAYER_LEVEL + 1
	if(next_level == 20):
		return (next_level*10)-5+600
	if(next_level == 40):
		return (next_level*13)-6+2400
	if(next_level < 20):
		return (next_level*10)-5
	if(next_level > 20 < 40): 
		return (next_level*13)-6
	if(next_level > 40): 
		return (next_level*16)-8

func _ready():
	init_vars()
		
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
