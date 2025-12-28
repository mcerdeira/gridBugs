extends Area2D
var letter = ""
var type = Global.GridType.LETTER
var text = ""
var level = 1

func _ready():
	add_to_group("letters")
	set_level(letter)
	
func set_level(lvl):
	fusion()
	$lbl.text = letter
	
func fusion():
	$fusion_anim.play("new_animation")
	
func die():
	queue_free()
	
func _physics_process(delta: float) -> void:			
	if Global.Wok and Global.Aok and Global.Sok and Global.Dok:
		queue_free()
	
func get_texture():
	return null
	
func _on_mouse_entered() -> void:
	Global.Main.set_item_inspect(self)
	if !$anim.is_playing():
		$anim.play("new_animation")
		
func _on_mouse_exited() -> void:
	$anim.stop()
