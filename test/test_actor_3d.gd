extends Node3D
@onready var player_3d: Player3D = $Player3D

func _ready() -> void:
	player_3d.data.set_hp(0)		
