extends Node3D

const ItemJsonLoader := preload("res://scripts/inventory/ItemJsonLoader.gd")

func _ready() -> void:
	var items = ItemJsonLoader.load_items_from_json("res://resources/items/knight_items.json")
	print(items)
	
