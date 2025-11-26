extends Area2D
var ttl = 3.0
var idx_s = []

var enemy_obj = null
var attrackted = false
@export var speed: float = 265.0
@export var speed_min: float = 50.0
@export var speed_max: float = 100.0
@export var friction: float = Global.pick_random([800.0, 220.0, 300.0])
var go_direction = null

var velocity: Vector2 = Vector2.ZERO
var timer := 0.0

func _ready():
	var dir = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spd = randf_range(speed_min, speed_max)
	velocity = dir * spd

func _physics_process(delta: float) -> void:
	if ttl > 0:
		ttl -= 1 * delta
		if ttl <= 0:
			$collider.set_deferred("disabled", false)
			
	if attrackted:
		if enemy_obj != null and !is_instance_valid(enemy_obj):
			enemy_obj = null 
			attrackted = false
			ttl = 1.1
			$collider.set_deferred("disabled", true)
		
		if enemy_obj != null and is_instance_valid(enemy_obj):
			go_direction = (enemy_obj.global_position - global_position).normalized()
			velocity = go_direction * speed
			position += velocity * delta
			
			if global_position.distance_to(enemy_obj.global_position) <= 10:
				enemy_obj.get_ash()
				queue_free()
	else:
		position += velocity * delta
		var decel = friction * delta
		if velocity.length() > decel:
			velocity = velocity.move_toward(Vector2.ZERO, decel)
		else:
			velocity = Vector2.ZERO
				
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
	if !attrackted and area:
		if area.is_in_group("enemy"):
			area.get_ash()
			queue_free()
			
		if area.is_in_group("enemy_attrack"):
			enemy_obj = area.get_parent()
			attrackted = true
