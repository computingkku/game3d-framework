extends CanvasLayer

func open():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready() -> void:
	visible = false
	pass
	
func _on_button_pressed() -> void:
	if GameManager.gamescene:
		get_tree().reload_current_scene()
	close()
