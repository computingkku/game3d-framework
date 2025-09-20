extends CharacterBody3D
class_name Actor3D

signal died()

@export  var model_scene : PackedScene 
@onready var model : CharacterModel = null
var _data : CharacterData = null
@export var walk_speed := 6.0
@export var run_speed := 10.0
@onready var label_name: Label3D = $label_name
@onready var bar_hp: MeshInstance3D = $label_name/bar_hp

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
var prev_action = ""
@onready var walk_sound: AudioStreamPlayer3D = $sounds/walk
@onready var attack_sound: AudioStreamPlayer = $sounds/attack
@onready var marker_3d: Marker3D = $Marker3D
@onready var attack_area: Area3D = $AttackArea

func _ready() -> void:
	if $Model.get_child_count()>0:
		for c in $Model.get_children():
			if c is CharacterModel:
				model = c
				break
	elif model_scene: 
		model = model_scene.instantiate()
		add_child(model)
	$CapsuleMesh.visible = !model
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
		if model.right_hand :
			attack_area.reparent(model.right_hand)
			attack_area.position = Vector3.ZERO

func _process(delta: float) -> void:
	if !_alive :
		label_name.visible = false	
		return
	var cam : Camera3D = GameManager.player.cam
	if !cam : return
	var d = cam.global_position - global_position
	if d.length()<20:
		label_name.visible = true	
	else:
		label_name.visible = false	
	attack_area.visible = model and model.is_attack
	
func _physics_process(delta: float) -> void:
	# อัปเดตตัวจับเวลา
	if position.y > 1000: 
		on_died()
	if !_alive && prev_action=="death": 
		move_and_slide()
		return

	if _alive and _data : _data.regen(delta)	
	_time_since_left_floor += delta
	_time_since_idle += delta
	_time_since_play_action += delta
	_time_since_play_sound  += delta
	_time_since_attack += delta	
	_time_since_damage += delta
	var v = Vector2(velocity.x,velocity.y)
	if _time_since_damage <0.5 : return	
	# ตรวจพื้น
	if is_on_floor() && _time_since_attack>1.0:
		_time_since_left_floor = 0.0
		var vspeed=v.length()
		if prev_action in ["walk","idle","jump","run"]:
			_time_since_play_action=0
			if  vspeed < delta: 
				action = "idle"
			elif vspeed<=walk_speed:
				action = "walk"
			else:	
				action = "run"
				_time_since_run+=delta
				if _time_since_run>0.2: 
					_data.change_stamina(-1)
					_time_since_run-=0.2
			#if vspeed>0.1 && self==GameManager.player:
				#print(" speed=",vspeed,' walkspeed=',walk_speed)

		#if self==GameManager.player:
			#print(" prev "," speed=",vspeed," run=",run_speed*delta," ",action)
				
	# ----- แรงโน้มถ่วง -----
	if not is_on_floor():
		velocity.y -= _gravity * delta * 5
		if velocity.y > 200 : on_died()
		if _time_since_left_floor >0.2:
			action = "jump"
	
	
	_alive = !_data.is_dead()	

	if !_alive: 
		velocity.x = 0
		velocity.y = 0
	if !_alive	: action = "death"
	
	if model: 
		if action=="idle": 
			if _time_since_idle >20 : 
				action="sit"
		else:
			_time_since_idle = 0 
				
		if action!="": 
			_time_since_play_action=0
			model.play(action)
			prev_action = action
			action=""	
			
			if is_on_floor() and !walk_sound.playing and _time_since_play_sound>0.8:
				if action=="walk" :
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
	if model: 
		_time_since_damage = 0
		model.play("hurt")
		AudioManager.explosion.play()
	#print("on_damage_taken")
	pass
	
func on_healed(gained: int):
	pass
	
func on_stats_changed():
	var hp = _data.get_stat("hp")
	var max_hp = _data.get_stat("max_hp",100)
	label_name.text = _data.display_name
	#print (label_name.text," ",hp)
	bar_hp.set_instance_shader_parameter("health",float(hp/max_hp))
	_alive = hp>0.0
	$light.visible = _alive
	bar_hp.visible = _alive
	label_name.visible = _alive
	$Collision.disabled = !_alive
	pass

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	if label_name:
		$light.visible = _alive
		label_name.visible = _alive
	_onscreen = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if label_name:
		$light.visible = false
		label_name.visible = false
	_onscreen = false

func on_attack():
	_data.change_stamina(-1)

func on_weapon_hit(body : PhysicsBody3D):
	var op = ""
	if !_alive : return
	if !model : return  
	if _data.faction=="player" : op="monster"
	elif _data.faction=="monster" :op="player"
	if op!="" and body.is_in_group(op):
		if !body._alive : return
		var op_data : CharacterData = body.get("data")
		if op_data :
			op_data.take_damage(_data.get_stat("attack"),_data.get_stat("pierce"))


func _on_attack_area_body_entered(body: Node3D) -> void:
	if model.is_attack: on_weapon_hit(body)
