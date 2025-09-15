extends Node3D

@export var data : ItemData
@export var count = 1
@export var item_id : String = ""
@onready var area_3d: Area3D = $Area3D

var disabled = false
func _ready() -> void:
	$Area3D/GPUParticles3D.emitting = true
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if disabled : return
	if body and body.is_in_group("player"):
		var inv : InventoryData=	body.get("inventory")
		if item_id!="": data = GameManager.get_item(item_id)
		if inv:
			disabled = true
			if data : 
				data = inv.add_item(data,count)
			elif item_id!="": 
				data = inv.add_item_by_id(item_id,count)
			AudioManager.pick.play()
			$AnimationPlayer.stop()
			GameManager.emit_state_changed()
			GameManager.notify("ได้รับ "+data.name+" "+str(count))
			queue_free()
			#var tween = get_tree().create_tween()
			#var pos = body.position 
			##tween.tween_property(self, "scale",Vector3(0.1,0.1,0.1),0.5)
			#tween.tween_property(self, "position",pos,1);
			#tween.tween_callback(queue_free)
