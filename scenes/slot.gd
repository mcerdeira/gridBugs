extends Area2D
var selected = false
@export var id = -1
@export var item = null
@export var other1: Area2D
@export var other2: Area2D

func _physics_process(delta: float) -> void:
	$lbl_description.text = item.name + item.increase
	
func execute_action():
	item["action"].call()

func set_sel(val):
	selected = val
	$sel.visible = val
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_sel(true)
		other1.set_sel(false)
		other2.set_sel(false)
