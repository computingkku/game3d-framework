extends Node3D
@onready var inventory: Node2D = $Inventory
@onready var player: Player3D = $CanvasLayer/Player

func _ready() -> void:
	GameManager.set_player(player)
	inventory.close()
	player.connect("died",on_died)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inv"):
		if inventory.toggle():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_died():
	$UIGameOver.open()
