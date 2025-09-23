extends Node3D
@onready var ui_inventory: Node2D = $Inventory
@onready var player: Player3D = $Player
@onready var ui_game_over: CanvasLayer = $UI_GameOver

var gameover = false

func _ready() -> void:
	GameManager.set_player(player)
	ui_inventory.close()
	player.connect("died",on_died)
	gameover = false
	player.model.equip_item("sword")
	player.model.equip_item("skeleton_shield_a")
	print("ready")
	
func _input(event: InputEvent) -> void:
	if !gameover && event.is_action_pressed("inv"):
		if ui_inventory.toggle():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_died():
	gameover = true
	ui_inventory.close()
	ui_game_over.open()
