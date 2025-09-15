extends CharacterBody3D
class_name Actor3D

signal died()

@export  var model_scene : PackedScene 
@onready var model : CharacterModel = null
var _data : CharacterData = null
@onready var bar_hp: MeshInstance3D = $bar_hp
@onready var label_name: Label = $Label
@export var walk_speed := 7.0
@export var run_speed := 10.0


var _time_since_left_floor = 0.0
var _time_since_attack = 0.0
var _time_since_damage = 0.0
var _time_since_idle = 0.0
var _time_since_play_action = 0.0
var _time_since_play_sound = 0.0
var _time_since_run = 0.0
var _gravity = GameManager.gravity
var _alive := true
var _onscreen = true
var action = ""
@onready var walk_sound: AudioStreamPlayer3D = $sounds/walk
@onready var attack_sound: AudioStreamPlayer = $sounds/attack
@onready var marker_3d: Marker3D = $Marker3D

func _ready() -> void:
	if $Model.get_child_count()>0:
		for c in $Model.get_children():
			if c is CharacterModel:
				model = c
				break
	elif model_scene: 
		model = model_scene.instantiate()
		add_child(model)
	init_data()
	if !_data : _data = get("data")
	if !_data : _data = CharacterData.new()	
	_init_event_handlers()

# for override by subclass
func init_data():
	_data = CharacterData.new()
	pass

func _init_event_handlers():
	_data.connect("hp_changed", on_hp_changed)
	_data.connect("mp_changed", on_mp_changed)
	_data.connect("stats_changed", on_stats_changed)
	_data.connect("died", on_died)
	_data.connect("revived",on_revived)			
	_data.connect("healed",on_healed)			
	_data.connect("damage_taken",on_damage_taken)			
	if model: 
		_data.set_model(model)
		model.play("idle")
		model.connect("attack",on_attack)
		model.connect("weapon_hit", on_weapon_hit)


func _process(delta: float) -> void:
	if !_alive :
		label_name.visible = false	
		return
	var cam : Camera3D = GameManager.player.cam
	if !cam : return
	var d = cam.global_position - marker_3d.global_position
	if d.length()<10:
		var p2d = cam.unproject_position(marker_3d.global_transform.origin)
		label_name.position = p2d + Vector2(-40,0) # ยกขึ้นเหนือหัว
		label_name.visible = true	
	else:
		label_name.visible = false	
func _physics_process(delta: float) -> void:
	# อัปเดตตัวจับเวลา
	if position.y > 1000: 
		on_died()
	if _alive and _data : _data.regen(delta)	
	_time_since_left_floor += delta
	_time_since_idle += delta
	_time_since_play_action += delta
	_time_since_play_sound  += delta
	# ตรวจพื้น
	if is_on_floor():
		_time_since_left_floor = 0.0
		if _time_since_attack > 1.2 && _time_since_damage >0 :
			if velocity.length()<0.1: 
				action = "idle"
			else:
				action = "walk"
				
	_time_since_attack += delta	
	_time_since_damage += delta
	# ----- แรงโน้มถ่วง -----
	if not is_on_floor():
		velocity.y -= _gravity * delta * 5
		if velocity.y > 200 : on_died()
		if _time_since_left_floor >0.5 and _time_since_attack == 0:
			action = "jump"
		# เคลื่อนที่
	if !_alive : 
		move_and_slide()
		return
	
	_alive = !_data.is_dead()	

	if action=="walk" && velocity.length()>=walk_speed:
		_time_since_run+=delta
		if _time_since_run>0.2: 
			_data.change_stamina(-1)
			_time_since_run-=0.2
		action = "run"
	else:
		_time_since_run=0	

	if !_alive : 
		velocity.x = 0
		velocity.y = 0
		action = "death"
	
	if model: 
		if action=="idle": 
			if _time_since_play_action < 2: action=""	
			elif _time_since_idle < 5.0: action=""
			elif _time_since_idle >20 : 
				action="sit"
		else:
			_time_since_idle = 0 
				
		if action!="": 
			_time_since_play_action=0
			model.play(action)	
			
			if is_on_floor() && !walk_sound.playing:
				if action=="walk" and _time_since_play_sound>0.8:
					walk_sound.pitch_scale = 2
					walk_sound.play()
					_time_since_play_sound=0
				elif action=="run":
					walk_sound.pitch_scale = 1.5
					walk_sound.play()	
					_time_since_play_sound=0
					
	move_and_slide()

# ===== Signals =====
func on_hp_changed(new_hp: int, old_hp: int):
	pass
	
func on_mp_changed(new_mp: int, old_mp: int):
	pass
	
func on_died():
	_alive = false
	if model : 
		model.is_attack = false
		model.is_death = true
		model.play("death")
		await get_tree().create_timer(5).timeout
		emit_signal("died")
		on_stats_changed()
	pass
	
func on_revived():
	pass

func on_damage_taken(raw_amount: int, final_amount: int, crit: bool):
	$damage_effect.emitting = true
	#print("on_damage_taken")
	pass
	
func on_healed(gained: int):
	pass
	
func on_stats_changed():
	var hp = _data.get_stat("hp")/_data.get_stat("max_hp",100)
	label_name.text = _data.display_name
	bar_hp.set_instance_shader_parameter("health",hp)
	_alive = hp>0.0
	$light.visible = _alive
	bar_hp.visible = _alive
	label_name.visible = _alive
	$Collision.disabled = !_alive
	pass

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	$light.visible = _alive
	label_name.visible = _alive
	_onscreen = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	$light.visible = false
	label_name.visible = false
	_onscreen = false

func on_attack():
	_data.change_stamina(-1)
	attack_sound.play()

func on_weapon_hit(body : PhysicsBody3D):
	var op = ""
	if !_alive : return
	if _data.faction=="player" : op="monster"
	elif _data.faction=="monster" :op="player"
	if op!="" and body.is_in_group(op):
		if !body._alive : return
		var op_data : CharacterData = body.get("data")
		if op_data :
			op_data.take_damage(_data.get_stat("attack"),_data.get_stat("pierce"))
