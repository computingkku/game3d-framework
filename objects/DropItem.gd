extends Node3D


@export var count = 1
@export var item_id : String = ""
@onready var item: Node3D = $Item
@onready var mesh = $Item/Mesh
@onready var gpu_particles_3d: GPUParticles3D = $Item/GPUParticles3D

var data : ItemData
var disabled = false

func _ready() -> void:
	gpu_particles_3d.emitting = true
	init_data()

func init_data():
	if item_id!="": 
		data = GameManager.get_item(item_id)
		if data.scene:
			mesh.queue_free()
			mesh = data.scene.instantiate()
			item.add_child(mesh)

func _on_body_entered(body: Node) -> void:
	if disabled : return
	if body and body.is_in_group("player"):
		var inv : InventoryData=	body.get("inventory")
		if inv:
			disabled = true
			if data : 
				data = inv.add_item(data,count)
			elif item_id!="": 
				data = inv.add_item_by_id(item_id,count)
			AudioManager.pick.play()
			GameManager.emit_state_changed()
			GameManager.notify("ได้รับ "+data.name+" "+str(count))
			queue_free()
