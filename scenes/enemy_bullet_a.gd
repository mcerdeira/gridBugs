extends Area2D
@export var speed: float = 100.0
var velocity: Vector2
var dmg = 1
var shoot_direction = null

func _ready():
	add_to_group("bullet")
	velocity = shoot_direction * speed

func _process(delta):
	position += velocity * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("player"):
		area.hit(dmg)
		queue_free()
