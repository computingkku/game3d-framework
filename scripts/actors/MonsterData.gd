# res://data/MonsterData.gd
extends CharacterData
class_name MonsterData
# ขยายความสามารถของศัตรู: พฤติกรรม, ของดรอป, รางวัล EXP/เงิน

# ===== AI / Behavior =====
@export var ai_type: StringName = &"melee"   # melee / ranged / boss ...
@export var detect_range: float = 8.0
@export var stop_distance: float = 1.6
@export var aggression: float = 1.0		  # ความดุ (ส่งผลกับความถี่โจมตี/ไล่)

# ===== Rewards =====
@export var exp_reward_min: int = 2
@export var gold_reward_min: int = 2
@export var exp_reward_max: int = 10
@export var gold_reward_max: int = 10

# ===== Loot Table อย่างง่าย =====
# โครง: [{ "item": Resource, "chance": 0.25, "min": 1, "max": 1 }, ...]
@export var loot_table: Array[LootItem] = []

# ของสำหรับ drop
func add_loot(item: ItemData, chance=0.25, min: int = 1, max: int=1):
	var x = LootItem.new()
	x.itemdata = item
	x.chance = chance
	x.max = max
	x.min = min
	loot_table.append(x)

# สุ่มดรอป (ผลลัพธ์เป็น Array ของ Dictionary หรือ Resource ตามที่คุณต้องการ)
func roll_loot(_actor:Node3D) -> Array:
	# TODO สร้าง object ของ dropitem ในตำแหน่งที่ monster ตาย
	var drops: Array = []
	for e in loot_table:
		if randf() <= e.chance:
			drops.append(e.new_instace(_actor))
	return drops
