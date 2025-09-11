# res://data/PlayerData.gd
extends CharacterData
class_name PlayerData
# ขยายความสามารถของผู้เล่น: เลเวล, EXP, แต้มค่าสถานะ, เงิน, อุปกรณ์

# ===== Progression =====
@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next: int = 100
@export var stat_points: int = 0  # แต้มอัพ STR/DEX/INT ตามระบบที่คุณใช้

# ===== Economy / Inventory (พื้นฐาน) =====
@export var gold: int = 0
@export var load_limit: float = 50.0

# ===== Equipment (อย่างง่าย: ช่องอ้างชื่อ/ไอเท็ม) =====
@export var equip_mainhand: Resource		 # WeaponData
@export var equip_armor: Resource			 # โล่ป้องกัน

# โบนัสจากอุปกรณ์ (คำนวณรวมแบบง่าย)
func get_total_attack() -> int:
	var bonus := 0
	if stamina <= 0: return 0
	if equip_mainhand and equip_mainhand.has_method("get_attack_bonus"):
		bonus += int(equip_mainhand.get_attack_bonus())
	return attack + bonus

func get_total_defense() -> int:
	var bonus := 0
	if equip_armor and equip_armor.has_method("get_defense_bonus"):
		bonus += int(equip_armor.get_defense_bonus())
	return defense + bonus

# Override การคำนวณดาเมจเล็กน้อย ให้ใช้ total attack
func take_damage(raw_amount: int, pierce: float = 0.0, allow_crit: bool = true) -> int:
	# ใช้ defense ปกติ (หรือจะ override เพิ่มระบบเกราะ/ธาตุก็ได้)
	return super.take_damage(raw_amount, pierce, allow_crit)

# ===== Leveling =====
func add_exp(amount: int) -> void:
	if amount <= 0: return
	exp += amount
	while exp >= exp_to_next:
		exp -= exp_to_next
		_level_up()

func _level_up() -> void:
	level += 1
	stat_points += 3
	# ปรับเพดานและรีเจนพื้นฐานตามเลเวล
	set_max_hp(int(max_hp * 1.1))
	set_max_mp(int(max_mp * 1.08))
	set_attack(attack + 1)
	set_defense(defense + 1)
	# เติมเลือด/มานา
	set_hp(max_hp)
	set_mp(max_mp)

# เก็บเป็น Dictionary: { "potion": { "data": ItemData, "count": 5 } }
var inventory: Dictionary = {}

signal inventory_changed

# เพิ่มไอเทม
func add_item(item: ItemData, count: int = 1):
	if inventory.has(item.id):
		var slot = inventory[item.id]
		slot["count"] = min(slot["count"] + count, item.max_stack)
	else:
		inventory[item.id] = {"data": item, "count": min(count, item.max_stack)}
	emit_signal("inventory_changed")

# ใช้ไอเทม
func use_item(item_id: String) -> bool:
	if inventory.has(item_id):
		var slot = inventory[item_id]
		if slot["count"] > 0:
			slot["count"] -= 1
			if slot["count"] <= 0:
				inventory.erase(item_id)
			emit_signal("inventory_changed")
			return true
	return false

# ลบไอเทมตามจำนวน
func remove_item(item_id: String, count: int = 1) -> bool:
	if inventory.has(item_id):
		var slot = inventory[item_id]
		slot["count"] -= count
		if slot["count"] <= 0:
			inventory.erase(item_id)
		emit_signal("inventory_changed")
		return true
	return false

# ดึงจำนวนไอเทม
func get_item_count(item_id: String) -> int:
	if inventory.has(item_id):
		return inventory[item_id]["count"]
	return 0

# ดึงข้อมูล ItemData
func get_item_data(item_id: String) -> ItemData:
	if inventory.has(item_id):
		return inventory[item_id]["data"]
	return null
