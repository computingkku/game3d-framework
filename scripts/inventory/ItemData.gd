# item_data.gd
# Resource ที่นิยามข้อมูลของไอเท็มหนึ่งชิ้น
class_name ItemData
extends Resource

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""

# ประเภทของไอเท็ม (enum)
@export var item_type: Types.ItemType = Types.ItemType.CONSUMABLE

# ไอคอน/โมเดล (แล้วแต่เกมคุณจะใช้)
@export var icon: Texture2D
@export_node_path("Node3D") var node_path: NodePath

# stack/น้ำหนัก
@export_range(1, 9999) var stack_size: int = 10000
@export_range(0, 9999) var weight: int = 1

# เอฟเฟกต์ของไอเท็มนี้ (ถ้ามี)
@export var effect: ItemEffect 

# ข้อมูลเสริม (metadata) ที่ยืดหยุ่นได้
@export var meta: Dictionary[StringName, Variant] = {}

var node : Node3D

func is_equipable() -> bool:
	return item_type in [Types.ItemType.WEAPON,Types.ItemType.SHIELD, Types.ItemType.EQUIPMENT]

func is_consumable() -> bool:
	return item_type == Types.ItemType.CONSUMABLE
