# res://data/CharacterData.gd
extends Resource
class_name CharacterData
# Base resource สำหรับข้อมูล "ตัวละคร" ทุกประเภท

# ===== Signals =====
signal hp_changed(new_hp: int, old_hp: int)
signal mp_changed(new_mp: int, old_mp: int)
signal stamina_changed(new_stamina: int, old_stamina: int)

signal died()
signal revived()
signal damage_taken(raw_amount: int, final_amount: int, crit: bool)
signal healed(gained: int)
signal stats_changed()

#เมื่อสถานะเปลี่ยน
signal status_added(id: StringName, duration: float, value: float)
signal status_refreshed(id: StringName, duration: float, value: float)
signal status_removed(id: StringName, reason: StringName) # "manual" | "expired"
signal status_tick(id: StringName, value: float)

# ===== Identity / Meta =====
@export var display_name: String = "Unnamed"
@export var faction: StringName = &"enemy"   # player / enemy / npc ฯลฯ
@export var icon: Texture2D

# ===== Current =====
@export var hp: float = 100 : set = set_hp
@export var mp: float = 50  : set = set_mp
@export var stamina: float = 100 : set = set_stamina

# ===== Max =====
@export_range(1, 999999) var max_hp: int = 100 : set = set_max_hp
@export_range(0, 999999) var max_mp: int = 50  : set = set_max_mp
@export_range(0, 999999) var max_stamina: int = 100 : set = set_max_stamina

# ===== Core Stats =====
@export_range(0, 9999) var attack: float = 10 : set = set_attack
@export_range(0, 9999) var defense: float = 5 : set = set_defense
@export_range(0.0, 10.0, 0.01) var speed: float = 1.0 : set = set_speed

# ===== Regen Rates =====
@export_range(0.0, 1000.0, 0.01) var hp_regen: float = 0.5     # HP per second
@export_range(0.0, 1000.0, 0.01) var mp_regen: float = 0.5     # MP per second
@export_range(0.0, 1000.0, 0.01) var stamina_regen: float = 0.5 # Stamina per second

# ค่าความเป็นไปได้คริติคอล (ใช้ร่วม)
@export_range(0.0, 1.0, 0.001) var crit_chance: float = 0.05
@export_range(1.0, 5.0, 0.01) var crit_multiplier: float = 1.5

@export var equip_items: Array[String]  

var _is_dead_cached := false
var model : CharacterModel = null

# ค่าสถานะปัจจุบัน หลังการคำนวณอุปกรณ์สวมใส่
var current_stat : Dictionary[StringName,float] = {}
var _equip_items : Array[ItemData] = []
var _props : Array[String] = []

func set_model(m: CharacterModel):
	model = m
	update_equip_items()
	
func get_stat(key:String,defval=0) -> float:
	var v = current_stat.get(key,-1)
	if v==-1:
		if defval!=0: v=defval 
		else: 
			v=get(key)
			if v!=null: v=float()
			else: v=0
	return v

func update_stat() -> Dictionary[StringName,float]:
	if _props.is_empty():
		for p in get_property_list():
			var pname:String = p['name']
			if pname.substr(0,1)=="_": continue
			var type = p['type']
			if type == TYPE_INT or type ==  TYPE_FLOAT:
				_props.append(p['name'])
		
	for pname in _props:
		current_stat[pname] = float(get(pname))				
	for x in _equip_items:
		if x.effect:
			current_stat = x.effect.calc_stats(current_stat,self)
	
	emit_signal("stats_changed")
	return current_stat
	
func update_equip_items():
	if model:
		model._update_state(equip_items)
		_equip_items = ItemHelper.find_all(model.items,equip_items)
	update_stat()		

func equip_item(item:ItemData, value:bool=true):
	if value:
		if item.item_type == Types.ItemType.WEAPON or item.item_type == Types.ItemType.SHIELD:
			equip_items = ItemHelper.remove_item_by_type(equip_items,model.items,item.item_type)
		if !(item.id in equip_items): equip_items.append(item.id)
	else:
		equip_items.erase(item.id)
	update_equip_items()
		
func equip_item_toggle(item:ItemData):
	if item.id in equip_items: equip_item(item,false)
	else:
		equip_item(item,true)

# ===== Setters & Emits =====
func set_hp(v: int) -> void:
	v = clamp(v, 0, get_stat('max_hp'))
	if v == hp: return
	var old := hp
	hp = v
	update_stat()
	emit_signal("hp_changed", get_stat("hp"), old)
	var now_dead := get_stat("hp") <= 0
	if now_dead and !_is_dead_cached:
		_is_dead_cached = true
		die()
	elif !now_dead and _is_dead_cached:
		_is_dead_cached = false
		emit_signal("revived")

func set_mp(v: int) -> void:
	v = clamp(v, 0, get_stat('max_mp'))
	if v == mp: return
	var old := mp
	mp = v
	update_stat()
	emit_signal("mp_changed", get_stat("mp"), old)

func set_stamina(v: int) -> void:
	v = clamp(v, 0, get_stat('max_stamina'))
	if v == stamina: return
	var old := stamina
	stamina = v
	update_stat()
	emit_signal("stamina_changed", get_stat("stamina"), old)

func set_max_hp(v: int) -> void:
	v = maxi(1, v)
	if v == max_hp: return
	max_hp = v
	set_hp(mini(hp, max_hp))
	update_stat()


func set_max_mp(v: int) -> void:
	v = maxi(0, v)
	if v == max_mp: return
	max_mp = v
	set_mp(mini(mp, max_mp))
	update_stat()

func set_max_stamina(v: int) -> void:
	v = maxi(0, v)
	if v == max_stamina: return
	max_stamina = v
	set_stamina(mini(stamina, max_stamina))
	update_stat()

func set_attack(v: int) -> void:
	v = maxi(0, v)
	if v == attack: return
	attack = v
	update_stat()

func set_defense(v: int) -> void:
	v = maxi(0, v)
	if v == defense: return
	defense = v
	update_stat()

func set_speed(v: float) -> void:
	v = maxf(0.0, v)
	if is_equal_approx(speed, v): return
	speed = v
	update_stat()
	
# ===== Gameplay Helpers =====
func is_dead() -> bool:
	return hp <= 0

func die() -> void:
	emit_signal("died")

func reset_full() -> void:
	set_hp(max_hp)
	set_mp(max_mp)
	set_stamina(max_stamina)

# ฟื้นค่าพลังทั้งหมดตามอัตราที่กำหนด
# เรียกจาก _process(delta) ของ Node ที่ถือ CharacterData
var regen_time = 0.0
func regen(delta: float) -> void:
	regen_time += delta
	if regen_time<1.0 : return
	var _hp_regen = get_stat("hp_regen")
	var _mp_regen = get_stat("mp_regen")
	var _st_regen = get_stat("stamina_regen")
	if _hp_regen > 0.0 or _mp_regen>0.0 or _st_regen>0.0:
		if _hp_regen > 0.0 and hp > 0:
			hp = clamp(hp + _hp_regen,0,get_stat("max_hp"))
		if _mp_regen > 0.0 and hp > 0: # mp ไม่ฟื้นถ้าตาย
			mp = clamp(mp + _mp_regen,0,get_stat("max_mp"))
		if _st_regen > 0.0 and hp > 0:
			stamina = clamp(stamina + _st_regen,0,get_stat("max_stamina"))
		update_stat()
	regen_time -= 1.0	
# ดาเมจ: รองรับ pierce (ทะลุ def บางส่วน) + โอกาสคริติคัล
func take_damage(raw_amount: int, pierce: float = 0.0, allow_crit: bool = true) -> int:
	if raw_amount <= 0: return 0
	var crit := false
	var amt := raw_amount
	if allow_crit and randf() < crit_chance:
		amt = int(round(raw_amount * crit_multiplier))
		crit = true
	var eff_def = current_stat.get("defense",defense)
	eff_def = int(round( eff_def * (1.0 - clampf(pierce, 0.0, 1.0))))
	var final := maxi(amt - eff_def, 1)
	set_hp(hp - final)
	emit_signal("damage_taken", raw_amount, final, crit)
	return final

func heal(amount: int) -> int:
	if amount <= 0: return 0
	var before := hp
	set_hp(hp + amount)
	var gained := hp - before
	if gained > 0:
		emit_signal("healed", gained)
	return gained

# ===== จัดการ MP =====
func change_mp(amount: int) -> int:
	if amount == 0: 
		return 0
	var before := mp
	set_mp(mp + amount)
	return mp - before  # ค่าที่เปลี่ยนจริง (อาจถูก clamp)

# ===== จัดการ Stamina =====
func change_stamina(amount: int) -> int:
	if amount == 0: 
		return 0
	var before := stamina
	set_stamina(stamina + amount)
	return stamina - before  # ค่าที่เปลี่ยนจริง
