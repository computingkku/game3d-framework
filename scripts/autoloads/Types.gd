extends Node

enum ItemType {
	CONSUMABLE,  # 0  บริโภคได้: potion/scroll/coin
	WEAPON,      # 1  อาวุธ ใส่ได้ครั้งละ 1
	SHIELD,      # 2  โล่ ใส่ได้ครั้งละ 1
	EQUIPMENT,   # 3  เครื่องสวมใส่ทั่วไป เช่น แหวน/รองเท้า
	QUEST        # 4  ไอเท็มเควสต์ (ไม่ใช้ combat)
}
var drop_item = preload("res://objects/items/DropItem.tscn")
var drop_weapon = preload("res://objects/items/DropWeapon.tscn")

# Optional: canonical stat keys (เพื่อกันสะกดผิด)
const STAT := {
	HP = &"hp",
	MP = &"mp",
	EXP = &"exp",
	STAMINA = &"stamina",
	LOAD_LIMIT = &"load_limit",
	MAX_HP = &"max_hp",
	MAX_MP = &"max_mp",
	MAX_STAMINA = &"max_stamina",
}
