
extends Resource
class_name EffectStatus

# ===== จัดการ ส่วนที่เกี่ยวข้องกับ Status Effects
# ระบบ Status Effects ในเกมจะใช้เพื่อสร้าง สภาพพิเศษชั่วคราว ที่ส่งผลกับตัวละคร 
# (ทั้ง Player และ Monster) นอกเหนือจากค่าสถานะปกติ เช่น HP, MP, Stamina
# ดีบัฟ (Debuff)  Poison / Burn → หัก HP เป็นช่วง ๆ (Damage over Time)
# เก็บแบบ one-per-id: { id: EffectState }
var id  : String
var time: float
var tick: float
var tick_left: float 
var value: float = 1.0
func _init(id:String, _time: float=1.0, _tick: float=0, _value: float=1.0):
	time = _time; tick = _tick; tick_left = _tick; value = _value

# เรียกจากโฮสต์ (เช่น Player/Monster node) ใน _process(delta)
func tick_status(actor:CharacterData, delta: float) -> void:
	time -= delta
	if tick > 0.0:
		tick_left -= delta
		if tick_left <= 0.0:
			# ทำงานหนึ่งครั้ง แล้วรีเซ็ตตัวนับ
			tick_left += tick
			_apply_status_tick(actor)
		if time <= 0.0 && tick<=0.0:
			_apply_status_tick(actor)

# โค้ดผลลัพธ์ต่อ tick — ปรับตามเกม
func _apply_status_tick(actor:CharacterData) -> void:
	match id:
		&"poison":
			actor.take_damage(int(value), 0.0, false)
		&"burn":
			actor.take_damage(int(value), 0.2, false)
		&"regen":
			actor.heal(int(value))
		_:
			pass
