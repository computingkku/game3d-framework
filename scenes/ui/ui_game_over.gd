extends CanvasLayer
@onready var knight: Node3D = $ColorRect/SubViewport/Knight

func open():
	visible = true
	knight.visible = true
	#knight.add("Idle",1.0,1)
	knight.add("Lie_Idle",5.0,1,0)
	knight.add("Sit_Floor_Idle",1.0,1,2)
	knight.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close():
	visible = false
	knight.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready() -> void:
	#open()
	knight.visible = false
	visible = false
	pass
	
func _on_button_pressed() -> void:
	knight.clear()
	knight.add("Idle",1.0,1,1)
	knight.add("1H_Melee_Attack_Chop",1.0,0,0.5)
	knight.start()
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	close()
