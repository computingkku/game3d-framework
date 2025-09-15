extends Resource
class_name  InventoryData

signal inventory_changed(data:InventoryData)

@export var slots : Dictionary[String,InventoryItem] = {}

# เพิ่มไอเทม
func add_item_by_id(id:String, count: int = 1):
	if slots.has(id):
		var slot = slots[id]
		slot.count = slot.count + count
		emit_signal("inventory_changed",self)
		return slot.data
	return null	

func add_item(item: ItemData, count: int = 1):
	var slot = null
	if slots.has(item.id):
		slot = slots[item.id]
		slot.data = item
		slot.count = min(slot.count + count, item.stack_size)
	else:
		slot = InventoryItem.new()
		slot.data = item
		slot.count = count
		slots[item.id] = slot
	emit_signal("inventory_changed",self)
	return slot.data

# ใช้ไอเทม
func use_item(actor: CharacterData, item_id: String) -> bool:
	if slots.has(item_id):
		var slot = slots[item_id]
		print(item_id,slot.data.name,slot.count)
		if slot.data.is_consumable() and slot.count>0:
			if remove_item(item_id,1):
				slot.data.effect.update_stats(actor)		
				return true				#
	return false

# ลบไอเทมตามจำนวน
func remove_item(item_id: String, count: int = 1) -> bool:
	if slots.has(item_id):
		var slot = slots[item_id]
		if count<=slot.count:
			slot.count -= count
			emit_signal("inventory_changed")
			return true
	return false

# ดึงจำนวนไอเทม
func get_item_count(item_id: String) -> int:
	if slots.has(item_id):
		var slot = slots[item_id]
		return slot.count
	return 0

# ดึงข้อมูล ItemData
func get_item_data(item_id: String) -> ItemData:
	if slots.has(item_id):
		var slot = slots[item_id]
		return slot.data
	return null
