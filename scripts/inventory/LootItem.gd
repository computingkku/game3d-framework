# Resource ที่นิยามข้อมูลของไอเท็มที่จะ Drop ของจาก Monster

class_name LootItem
extends Resource

@export var item_id : String 
@export var chance:float =0.25
@export var min: int = 1
@export var max: int = 1

func new_instace(actor: Node3D):
	if item_id=="": return
	var data = GameManager.get_item(item_id)
	var item = preload("res://objects/DropItem.tscn").instantiate()
	item.item_id =  item_id
	var count = randi_range(min,max)
	var pos1 = actor.position + Vector3(0,-1,0)
	var pos2 = actor.position + Vector3(0,2,0)
	var pos3 = actor.position + Vector3(randf_range(-3,3),0,randf_range(-3,3))
	item.set("count", count)
	item.set("position",pos1)
	item.disabled = true
	actor.get_parent().add_child(item)	
	var tween = actor.get_tree().create_tween()
	tween.tween_property(item, "position",pos2, 1)
	tween.tween_property(item, "position",pos3, 1)
	await actor.get_tree().create_timer(3).timeout
	item.disabled = false
	return item
