# Resource ที่นิยามข้อมูลของไอเท็มที่จะ Drop ของจาก Monster

class_name LootItem
extends Resource

@export var item_scene : PackedScene 
@export var item_data: ItemData
@export var item_id : String 
@export var chance:float =0.25
@export var min: int = 1
@export var max: int = 1
@export var item_type : Types.ItemType 

func new_instace(actor: Node3D):
	if !item_scene: 
		if item_type == Types.ItemType.WEAPON : item_scene = Types.drop_weapon
		else: item_scene = Types.drop_item
	var item = item_scene.instantiate()
	var count = randi_range(min,max)
	if item_data: item.set("data",item_data)
	if item_id!="": item.set("item_id",item_id)
	item.set("count", count)
	item.set("position",actor.position)
	actor.get_parent().add_child(item)	
	var tween = actor.get_tree().create_tween()
	tween.tween_property(item, "position", Vector3(randf_range(-1,1),4,randf_range(-1,1)), 2)
	return item
