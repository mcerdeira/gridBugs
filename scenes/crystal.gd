extends Area2D
var attrackted = false
@export var speed: float = 265.0
@export var speed_min: float = 150.0
@export var speed_max: float = 300.0
@export var friction: float = 200.0  # qué tan rápido frenan
@export var lifetime: float = 35.0    # opcional, si querés que desaparezcan
var go_direction = null

var velocity: Vector2 = Vector2.ZERO
var timer := 0.0

func _ready():
	var dir = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spd = randf_range(speed_min, speed_max)
	velocity = dir * spd

func _physics_process(delta: float) -> void:
	if attrackted:
		go_direction = (Global.player.global_position - global_position).normalized()
		velocity = go_direction * speed
		position += velocity * delta
		
		if global_position.distance_to(Global.player.global_position) <= 10:
			Global.get_gem()
			queue_free()
		
	else:
		position += velocity * delta
		var decel = friction * delta
		if velocity.length() > decel:
			velocity = velocity.move_toward(Vector2.ZERO, decel)
		else:
			velocity = Vector2.ZERO
		
		# desaparecer con el tiempo
		timer += delta
		if timer > lifetime:
			queue_free()
		
	_handle_screen_bounce()
	
func _handle_screen_bounce() -> void:
	var viewport_rect = get_viewport_rect()

	var margin_x = 4  
	var margin_y_u = 32
	var margin_y_d = 4

	# X
	if global_position.x < viewport_rect.position.x + margin_x:
		velocity.x = abs(velocity.x) 
	elif global_position.x > viewport_rect.size.x - margin_x:
		velocity.x = -abs(velocity.x)

	# Y
	if global_position.y < viewport_rect.position.y + margin_y_u:
		velocity.y = abs(velocity.y)
	elif global_position.y > viewport_rect.size.y - margin_y_d:
		velocity.y = -abs(velocity.y)


func _on_area_entered(area: Area2D) -> void:
	if !attrackted and area and area.is_in_group("player"):
		attrackted = true

func _on_get_area_entered(area: Area2D) -> void:
	if !attrackted and area and area.is_in_group("player_collector"):
		area.get_gem()
		queue_free()
