class_name ItemEffect
extends Resource

@export var states_add : Dictionary[StringName, float] = {}
@export var states_mul : Dictionary[StringName, float] = {}

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
	var item_states = new_states	
	for key in states_add.keys():
		var val = states_add[key]
		new_states[key] = _clamp_if_needed(item_states,key,new_states.get(key, 0) + val)
		
	for key in states_mul.keys():
		var val = states_mul[key]
		new_states[key] = _clamp_if_needed(item_states,key,new_states.get(key, 0) * val)
	return new_states;
	
#  update ค่าสถานะของ Actor จากการใช้ Item
#  สำหรับ item CONSUMABLE
func update_stats(actor: CharacterData):
	var new_stat : Dictionary[StringName,float] = {}
	for key in states_add.keys():
		var val = states_add[key]
		#if val==0 : continue
		var aval = actor.get(key)	
		print(key,val,aval)
		if aval!=null:
			val = val + aval
			actor.set(key, val)
			if val != aval:
				new_stat[key] = val		
	actor.emit_signal("stats_changed")			
	print(new_stat)
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
