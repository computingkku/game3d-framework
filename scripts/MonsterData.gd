# res://data/MonsterData.gd
extends CharacterData
class_name MonsterData
# ขยายความสามารถของศัตรู: พฤติกรรม, ของดรอป, รางวัล EXP/เงิน

# ===== AI / Behavior =====
@export var ai_type: StringName = &"melee"   # melee / ranged / boss ...
@export var detect_range: float = 8.0
@export var stop_distance: float = 0.6
@export var aggression: float = 1.0		  # ความดุ (ส่งผลกับความถี่โจมตี/ไล่)

# ===== Rewards =====
@export var exp_reward: int = 10
@export var gold_reward: int = 1

# ===== Loot Table อย่างง่าย =====
# โครง: [{ "item": Resource, "chance": 0.25, "min": 1, "max": 1 }, ...]
@export var loot_table: Array = []

# ของสำหรับ drop
func add_loot(item: ItemData, chance=0.25, min: int = 1, max: int=1):
	loot_table.append({ "item": item, "chance": chance, "min": min, "max": max })

# สุ่มดรอป (ผลลัพธ์เป็น Array ของ Dictionary หรือ Resource ตามที่คุณต้องการ)
func roll_loot() -> Array:
	var drops: Array = []
	for e in loot_table:
		var chance := float(e.get("chance", 0.0))
		if randf() <= chance:
			var amt := randi_range(int(e.get("min", 1)), int(e.get("max", 1)))
			drops.append({ "item": e.get("item", null), "amount": amt })
	return drops
