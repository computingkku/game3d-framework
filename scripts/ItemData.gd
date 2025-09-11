# item_data.gd
class_name ItemData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var item_type: String = "consumable" # consumable, equipment, quest, etc.
@export var max_stack: int = 99
