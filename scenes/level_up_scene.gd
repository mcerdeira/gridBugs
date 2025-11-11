extends Node2D

func _ready() -> void:
	get_tree().paused = true
	var items = [] + Global.ITEMS
	items.shuffle()
	$Slot.item = items.pop_at(0)
	$Slot.set_sel(true)
	items.shuffle()
	$Slot2.item = items.pop_at(0)
	$Slot.set_sel(false)
	items.shuffle()
	$Slot3.item = items.pop_at(0)
	$Slot.set_sel(false)

func _on_btn_aceptar_pressed() -> void:
	get_tree().paused = false
	queue_free()
