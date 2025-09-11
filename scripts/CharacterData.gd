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
@export var faction: StringName = &"neutral"   # player / enemy / npc ฯลฯ
@export var icon: Texture2D

# ===== Current =====
@export var hp: int = 100 : set = set_hp
@export var mp: int = 50  : set = set_mp
@export var stamina: int = 100 : set = set_stamina

# ===== Max =====
@export_range(1, 999999) var max_hp: int = 100 : set = set_max_hp
@export_range(0, 999999) var max_mp: int = 50  : set = set_max_mp
@export_range(0, 999999) var max_stamina: int = 100 : set = set_max_stamina

# ===== Core Stats =====
@export_range(0, 9999) var attack: int = 10 : set = set_attack
@export_range(0, 9999) var defense: int = 5 : set = set_defense
@export_range(0.0, 10.0, 0.01) var speed: float = 1.0 : set = set_speed

# ===== Regen Rates =====
@export_range(0.0, 1000.0, 0.01) var hp_regen: float = 0.0     # HP per second
@export_range(0.0, 1000.0, 0.01) var mp_regen: float = 0.0     # MP per second
@export_range(0.0, 1000.0, 0.01) var stamina_regen: float = 0.0 # Stamina per second

# ค่าความเป็นไปได้คริติคอล (ใช้ร่วม)
@export_range(0.0, 1.0, 0.001) var crit_chance: float = 0.05
@export_range(1.0, 5.0, 0.01) var crit_multiplier: float = 1.5

var _is_dead_cached := false

# ===== Setters & Emits =====
func set_hp(v: int) -> void:
	v = clampi(v, 0, max_hp)
	if v == hp: return
	var old := hp
	hp = v
	emit_signal("hp_changed", hp, old)
	var now_dead := hp <= 0
	if now_dead and !_is_dead_cached:
		_is_dead_cached = true
		die()
	elif !now_dead and _is_dead_cached:
		_is_dead_cached = false
		emit_signal("revived")

func set_mp(v: int) -> void:
	v = clampi(v, 0, max_mp)
	if v == mp: return
	var old := mp
	mp = v
	emit_signal("mp_changed", mp, old)

func set_stamina(v: int) -> void:
	v = clampi(v, 0, max_stamina)
	if v == stamina: return
	var old := stamina
	stamina = v
	emit_signal("stamina_changed", stamina, old)

func set_max_hp(v: int) -> void:
	v = maxi(1, v)
	if v == max_hp: return
	max_hp = v
	set_hp(mini(hp, max_hp))
	emit_signal("stats_changed")

func set_max_mp(v: int) -> void:
	v = maxi(0, v)
	if v == max_mp: return
	max_mp = v
	set_mp(mini(mp, max_mp))
	emit_signal("stats_changed")

func set_max_stamina(v: int) -> void:
	v = maxi(0, v)
	if v == max_stamina: return
	max_stamina = v
	set_stamina(mini(stamina, max_stamina))
	emit_signal("stats_changed")

func set_attack(v: int) -> void:
	v = maxi(0, v)
	if v == attack: return
	attack = v
	emit_signal("stats_changed")

func set_defense(v: int) -> void:
	v = maxi(0, v)
	if v == defense: return
	defense = v
	emit_signal("stats_changed")

func set_speed(v: float) -> void:
	v = maxf(0.0, v)
	if is_equal_approx(speed, v): return
	speed = v
	emit_signal("stats_changed")

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
func regen(delta: float) -> void:
	if hp_regen > 0.0 and hp > 0:
		set_hp(hp + int(hp_regen * delta))
	if mp_regen > 0.0 and hp > 0: # mp ไม่ฟื้นถ้าตาย
		set_mp(mp + int(mp_regen * delta))
	if stamina_regen > 0.0 and hp > 0:
		set_stamina(stamina + int(stamina_regen * delta))
		
# ดาเมจ: รองรับ pierce (ทะลุ def บางส่วน) + โอกาสคริติคัล
func take_damage(raw_amount: int, pierce: float = 0.0, allow_crit: bool = true) -> int:
	if raw_amount <= 0: return 0
	var crit := false
	var amt := raw_amount
	if allow_crit and randf() < crit_chance:
		amt = int(round(raw_amount * crit_multiplier))
		crit = true
	var eff_def := int(round(defense * (1.0 - clampf(pierce, 0.0, 1.0))))
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

# ===== จัดการ ส่วนที่เกี่ยวข้องกับ Status Effects
# ระบบ Status Effects ในเกมจะใช้เพื่อสร้าง สภาพพิเศษชั่วคราว ที่ส่งผลกับตัวละคร 
# (ทั้ง Player และ Monster) นอกเหนือจากค่าสถานะปกติ เช่น HP, MP, Stamina
# ดีบัฟ (Debuff)  Poison / Burn → หัก HP เป็นช่วง ๆ (Damage over Time)
# เก็บแบบ one-per-id: { id: EffectState }
var effects: Dictionary = {}

class EffectState:
	var time: float
	var tick: float
	var tick_left: float
	var value: float
	func _init(_time: float, _tick: float, _value: float):
		time = _time; tick = _tick; tick_left = _tick; value = _value
		
func add_status(id: StringName, duration: float, tick_every: float = 0.0, value: float = 0.0) -> void:
	if effects.has(id):
		# รีเฟรช (นโยบาย: ต่ออายุและอัปเดตพารามิเตอร์)
		var e: EffectState = effects[id]
		e.time = max(e.time, duration)
		e.tick = tick_every
		e.value = value
		e.tick_left = tick_every
		emit_signal("status_refreshed", id, e.time, e.value)
	else:
		var e := EffectState.new(duration, tick_every, value)
		effects[id] = e
		emit_signal("status_added", id, duration, value)

func remove_status(id: StringName, reason: StringName = &"manual") -> void:
	if effects.erase(id):
		emit_signal("status_removed", id, reason)

func has_status(id: StringName) -> bool:
	return effects.has(id)

func clear_all_status() -> void:
	# ลบทั้งหมดแบบยิง removed(reason="manual")
	for id in effects.keys():
		emit_signal("status_removed", id, &"manual")
	effects.clear()

# เรียกจากโฮสต์ (เช่น Player/Monster node) ใน _process(delta)
func tick_status(delta: float) -> void:
	var to_expire: Array[StringName] = []
	for id in effects.keys():
		var e: EffectState = effects[id]
		e.time -= delta

		if e.tick > 0.0:
			e.tick_left -= delta
			if e.tick_left <= 0.0:
				# ทำงานหนึ่งครั้ง แล้วรีเซ็ตตัวนับ
				e.tick_left += e.tick
				_apply_status_tick(id, e)

		if e.time <= 0.0:
			to_expire.append(id)

	# จัดการหมดอายุ (expire)
	for id in to_expire:
		effects.erase(id)
		emit_signal("status_removed", id, &"expired")

# โค้ดผลลัพธ์ต่อ tick — ปรับตามเกม
func _apply_status_tick(id: StringName, e: EffectState) -> void:
	match id:
		&"poison":
			take_damage(int(e.value), 0.0, false)
		&"burn":
			take_damage(int(e.value), 0.2, false)
		&"regen":
			heal(int(e.value))
		_:
			pass
	emit_signal("status_tick", id, e.value)
