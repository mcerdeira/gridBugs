extends Area2D
@export var speed: float = 600.0
var velocity: Vector2
var ttl = 0

func _ready():
	add_to_group("bullet")
	ttl = Global.BULLET_TTL
	velocity = Vector2.UP.rotated(rotation) * speed

func _process(delta):
	ttl -= 1 * delta
	if ttl <= 0:
		queue_free()
	position += velocity * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("enemy"):
		area.hit(Global.BULLET_DMG)
		queue_free()
