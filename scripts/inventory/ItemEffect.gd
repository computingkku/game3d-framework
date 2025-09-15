class_name ItemEffect
extends Resource

@export var states_add : Dictionary[StringName, float] = {}
@export var states_mul : Dictionary[StringName, float] = {}

## ===== Max =====
@export_range(1, 999999) var max_hp: int = 0 
@export_range(0, 999999) var max_mp: int = 0  
@export_range(0, 999999) var max_stamina: int = 0 
@export_range(0, 999999) var load_limit: int = 0 

# ===== Combat Stats =====
@export_range(0, 9999) var attack: int = 0
@export_range(0, 9999) var defense: int = 0 
@export_range(0.0, 10.0, 0.01) var speed: float = 0.0 

# ===== Regen Rates =====
@export_range(0.0, 1000.0, 0.01) var hp_regen: float = 0.0     # HP per second
@export_range(0.0, 1000.0, 0.01) var mp_regen: float = 0.0     # MP per second
@export_range(0.0, 1000.0, 0.01) var stamina_regen: float = 0.0 # Stamina per second

# ค่าความเป็นไปได้คริติคอล (ใช้ร่วม)
@export_range(0.0, 1.0, 0.001) var crit_chance: float = 0.0
@export_range(1.0, 5.0, 0.01)  var crit_multiplier: float = 0.0

func get_states() -> Dictionary[StringName,float]:
	for p in get_property_list():
		var type = p['type']
		if type == TYPE_INT or type ==  TYPE_FLOAT:
			var pname = p['name']
			if !states_add.has(pname): states_add[pname] = get(pname)
	return states_add

# คำนวนค่าสถานะของ Actor จากการใช้ Item
func calc_actor_stats(actor: CharacterData):
	var new_states : Dictionary[StringName,float] = {}
	for p in actor.get_property_list():
		var type = p['type']
		if type == TYPE_INT or type ==  TYPE_FLOAT:
			var pname = p['name']
			new_states[pname] = float(actor.get(pname))		
	return  calc_stats(new_states,actor)

# สำหรับคำนวณค่าสถานะ Effect ของ อุปกรณ์ ที่ Actor สวมใส่
func calc_stats(new_states : Dictionary[StringName,float], actor: CharacterData = null):	
	var item_states = get_states()		
	for key in states_add.keys():
		var val = states_add[key]
		new_states[key] = _clamp_if_needed(item_states,key,new_states.get(key, 0) + val)
		
	for key in states_mul.keys():
		var val = states_mul[key]
		new_states[key] = _clamp_if_needed(item_states,key,new_states.get(key, 0) * val)
	return new_states;
	
#  update ค่าสถานะของ Actor จากการใช้ Item
#  สำหรับ item CONSUMABLE
func update_stats(actor: CharacterData, item_states: Dictionary[StringName,float] = {}):
	var new_stat : Dictionary[StringName,float] = {}
	if item_states.is_empty():
		item_states = calc_actor_stats(actor)
	for key in item_states.keys():
		var val = item_states[key]
		var aval = float(actor.get(key))	
		if val != aval:
			actor.set(key,val)
			new_stat[key] = val		
	if new_stat.size()>0:
		actor.emit_signal("stats_changed")			
	return new_stat;
	
## ====== HELPERS ======
func _infer_max_key(stat_key: String) -> String:
	match stat_key:
		"hp":		return "max_hp"
		"mp":		return "max_mp"
		"stamina": return "max_stamina"
		_:		return "max_%s" % stat_key  # เผื่อกรณี stat อื่น ๆ

func _clamp_if_needed(actor: Dictionary[StringName,float], key: String, value: float) -> float:
	if !actor: return value
	var max_key := _infer_max_key(key)
	if actor.has(max_key):
		var mx := float(actor.get(max_key,100))
		return clamp(value, -1e12, mx)  # ไม่เกิน max
	return value
