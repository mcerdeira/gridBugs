extends Node
var FULLSCREEN = false
var shaker_obj = null      
var PLAYER_XP = 0.0
var TOTAL_XP = 0.0
var TOTAL_LIFE = 10.0
var PLAYER_LEVEL = 1

var TIME_LEFT = 5 * 60
var minutes = 0
var seconds = 0

var ENEMY_BASE_LIFE = 5.0
var ENEMY_SPAWN_TTL_TOTAL = 0.1#2.0
var ENEMY_SPAWN_TTL = ENEMY_SPAWN_TTL_TOTAL
var BULLET_TTL = 0.1
var BULLET_DMG = 1.0
var occupied_cells = [] 
var player = null

func init_vars():
	BULLET_DMG = 1.0
	occupied_cells = [] 
	TOTAL_XP = calc_totalxp()
	
func check_level_up():
	if Global.PLAYER_XP >= Global.TOTAL_XP:
		PLAYER_LEVEL += 1
		Global.PLAYER_XP = 0.0
		TOTAL_XP = calc_totalxp()
	
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
