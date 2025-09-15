extends Node3D

@export var data : ItemData
@export var count = 1
@export var item_id : String = ""
@onready var audio: AudioStreamPlayer = $Audio

func _ready() -> void:
	$Area3D/GPUParticles3D.emitting = true
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body and body.is_in_group("player"):
		var inv : InventoryData=	body.get("inventory")
		if item_id!="": data = GameManager.get_item(item_id)
		if inv:
			if data : inv.add_item(data,count)
			AudioManager.pick.play()
			GameManager.emit_state_changed()
			queue_free()
