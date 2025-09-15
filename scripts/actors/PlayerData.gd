# res://data/PlayerData.gd
extends CharacterData
class_name PlayerData
# ===== Progression =====
@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next: int = 100
@export var stat_points: int = 0  # แต้มอัพ STR/DEX/INT ตามระบบที่คุณใช้
# ==== ระบบ Inventory
@export var inventory: InventoryData
@export var load_limit: float = 50.0

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
