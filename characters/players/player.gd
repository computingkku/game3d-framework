extends CharacterBody3D

@export var model_scene : PackedScene 
@export var data : PlayerData
@onready var model: CharacterModel = $Knight

@export_node_path("Node3D") var head_path = NodePath("Head")
@onready var head: Node3D = get_node(head_path)
@onready var cam: Camera3D = head.get_node_or_null("Camera3D")

var mouse_sensitivity := 0.12
var yaw := 0.0
var pitch := 0.0
var pitch_limit := 89.0

# -------- Movement Tunables (สไตล์ Roblox: ลื่น ไหล ควบคุมง่าย) --------
@export var walk_speed := 7.0
@export var sprint_mult := 1.4
@export var accel_ground := 12.0
@export var accel_air := 4.0
@export var friction := 10.0          # ชะลอบนพื้น
@export var jump_velocity := 9.0
@export var air_control := 0.6        # 0..1 ควบคุมทิศทางกลางอากาศ

# -------- Gravity / Jump Assist --------
var gravity = GameManager.gravity
@export var coyote_time := 0.12       # เวลากระโดดได้แม้เพิ่งหลุดพื้น
@export var jump_buffer := 0.12       # กดกระโดดล่วงหน้า

var _time_since_left_floor := 0.0
var _time_since_jump_pressed := 0.0
var _time_since_attack_pressed := 0.0

func _ready() -> void:
	if model_scene: 
		$Knight.queue_free()
		model = model_scene.instantiate()
		add_child(model)	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not head:
		push_warning("Head path not set. Camera pitch won't work.")
	set_data_event()
	
func set_data_event():
	model.equip_shield_at(1)
	model.equip_weapon_at(1)
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw   -= event.relative.x * mouse_sensitivity * 0.01 * 100.0
		pitch -= event.relative.y * mouse_sensitivity * 0.01 * 100.0
		pitch = clamp(pitch, -pitch_limit, pitch_limit)
		rotation_degrees.y = yaw
		if head:
			head.rotation_degrees.x = head.rotation_degrees.x

	# ปล่อย/จับเมาส์
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# จดจำเวลาที่กด jump (สำหรับ jump buffer)
	if event.is_action_pressed("jump"):
		_time_since_jump_pressed = 0.0

func _physics_process(delta: float) -> void:
	# อัปเดตตัวจับเวลา
	_time_since_left_floor += delta
	_time_since_jump_pressed += delta
	_time_since_attack_pressed += delta
	
	var action = ""
	# ตรวจพื้น
	if is_on_floor():
		_time_since_left_floor = 0.0
		if _time_since_attack_pressed > 1:
			if velocity == Vector3.ZERO: 
				action = "idle"
			else:
				action = "walk"	

	# ----- แรงโน้มถ่วง -----
	if not is_on_floor():
		velocity.y -= gravity * delta * 5
		action = "jump"
	# ----- อินพุตการเคลื่อนที่ (ตามกล้อง) -----
	var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir := Vector3.ZERO
	if input_vec != Vector2.ZERO:
		# คำนวณทิศหน้า/ขวาจาก Basis ของ body (yaw)
		var forward :=  global_transform.basis.z
		var right   :=  global_transform.basis.x
		move_dir = (forward * input_vec.y + right * input_vec.x).normalized()
		action = "walk"
		if  input_vec.y>0:
			model.rotation_degrees.y = lerp(model.rotation_degrees.y,0.0,0.2)
		elif  input_vec.y<0:
			model.rotation_degrees.y = lerp(model.rotation_degrees.y,180.0,0.2)	
		elif  input_vec.x<0:
			model.rotation_degrees.y = lerp(model.rotation_degrees.y,-90.0,0.2)
		elif  input_vec.x>0:
			model.rotation_degrees.y = lerp(model.rotation_degrees.y,90.0,0.2)
		
	# ความเร็วเป้าหมาย (คูณ sprint หากกด)
	var target_speed := walk_speed * (sprint_mult if Input.is_action_pressed("sprint") else 1.0)
	var target_hvel := move_dir * target_speed

	# แยกแนวนอน/แนวตั้ง
	var hvel := velocity
	hvel.y = 0.0

	# ----- การเร่ง/ชะลอแบบลื่นไหล -----
	if move_dir != Vector3.ZERO:
		var used_accel := accel_ground if is_on_floor() else accel_air
		# air control: blend เข้าเป้าหมายในอากาศน้อยลง
		if not is_on_floor():
			target_hvel = hvel.lerp(target_hvel, air_control)
		hvel = hvel.move_toward(target_hvel, used_accel * delta)
	else:
		# ไม่มีอินพุต → friction บนพื้น
		if is_on_floor():
			hvel = hvel.move_toward(Vector3.ZERO, friction * delta)
		# กลางอากาศไม่ใส่ friction เพื่อยังคงโมเมนตัม

	velocity.x = hvel.x
	velocity.z = hvel.z

	if Input.is_action_just_pressed("attack"):
		_time_since_attack_pressed = 0
		action = "attack"	
		
	# ----- Jump: รองรับ coyote time + jump buffer -----
	var can_coyote := _time_since_left_floor <= coyote_time
	var can_buffer := _time_since_jump_pressed <= jump_buffer
	if can_buffer and (is_on_floor() or can_coyote):
		velocity.y = jump_velocity*2
		_time_since_jump_pressed = jump_buffer + 1.0  # consume buffer
	# เคลื่อนที่
			
	if action!="": model.play(action)
	move_and_slide()
	
