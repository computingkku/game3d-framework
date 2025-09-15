extends Actor3D

# ---- Runtime ----
var gravity = GameManager.gravity
var _player: Node3D
var _attack_cooldown := 0.0
@export var attack_interval := 1.2  # seconds between attacks
@export var data : MonsterData
# ---- Wander (idle roaming when no player in range) ----
@export var wander_speed_scale := 0.6
@export var wander_turn_speed_deg := 180.0  # degrees per second
@export var wander_min_time := 2.0
@export var wander_max_time := 4.0
var _wander_time_left := 0.0
var _wander_yaw_deg := 0.0

@onready var name_label: Label3D = $name_label
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar

#override
func init_data():
	if model: 
		$Skeleton_Warrior.queue_free()
	else:
		model = $Skeleton_Warrior	
	if !data: data = MonsterData.new()
	_data = data
	# Connect MonsterData signals for reactive behavior
	data.connect("hp_changed", on_hp_changed)			
	$OmniLight3D/GPUParticles3D.emitting = true
	name_label.text = data.display_name
	progress_bar.value = data.get_stat("hp") / data.max_hp

func _pick_wander_target() -> void:
	_wander_time_left = randf_range(wander_min_time, wander_max_time)
	_wander_yaw_deg = randi_range(0, 359)

func _update_wander(delta: float) -> Vector3:
	if _wander_time_left <= 0.0:
		_pick_wander_target()
	_wander_time_left -= delta
	# rotate body towards wander heading using shortest path (wrap-aware)
	rotation_degrees.y = _turn_towards_deg(rotation_degrees.y, _wander_yaw_deg, wander_turn_speed_deg * delta)
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	# keep model aligned with body
	#model.rotation_degrees.y = rotation_degrees.y
	var forward := global_transform.basis.z
	var base_speed := (data.speed if data else 1.0)
	return forward.normalized() * maxf(0.0, base_speed) * wander_speed_scale

func _turn_towards_deg(current: float, target: float, max_step: float) -> float:
	var diff = wrapf(target - current, -180.0, 180.0)
	var step = clamp(diff, -max_step, max_step)
	return current + step


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		# Find Player node anywhere in the scene tree by name
		_player = get_tree().get_root().find_child("Player", true, false)

	# cooldown timer
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)

	var action := ""

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta * 5.0
		action = "jump"

	var hvel := Vector3(velocity.x, 0.0, velocity.z)

	# Basic chase/attack AI using MonsterData
	if data and is_instance_valid(_player):
		var to_player := _player.global_transform.origin - global_transform.origin
		var to_player_flat := Vector3(to_player.x, 0.0, to_player.z)
		var dist := to_player_flat.length()
		var detect_range := data.detect_range
		var stop_distance := data.stop_distance
		
		if dist <= detect_range:
				#rotation_degrees.y = lerp(rotation_degrees.y, target_yaw_deg, 0.2)
			_wander_time_left = wander_max_time
			if dist > stop_distance:
				var dir := to_player_flat.normalized()
				var target_yaw_deg := rad_to_deg(atan2(dir.x, dir.z))
				# rotate model so forward aligns to player
				rotation_degrees.y = lerp(rotation_degrees.y, target_yaw_deg, 0.2)
				# move towards player
				if int(rotation_degrees.y) == int(target_yaw_deg):
					var move_speed := maxf(0.0, data.speed)
					# move only in facing (forward) direction
					var forward := global_transform.basis.z
					var desired := forward.normalized() * move_speed
					hvel = hvel.move_toward(desired, 4.0 * delta)
					action = "walk"
			else:
				# in attack range
				hvel = hvel.move_toward(Vector3.ZERO, 10.0 * delta)
				if _attack_cooldown <= 0.0 and not model.is_attack:
					model.play("attack")
					_attack_cooldown = maxf(0.4, attack_interval / maxf(0.1, data.aggression))
		else:
			# out of range: wander around
			var desired_wander := _update_wander(delta)
			hvel = hvel.move_toward(desired_wander, 3.0 * delta)
			action = "walk"
	else:
		# no data or player yet: do a light wander
		var desired_wander := _update_wander(delta)
		hvel = hvel.move_toward(desired_wander, 3.0 * delta)
		action = "walk"

	velocity.x = hvel.x
	velocity.z = hvel.z

	if action != "attack" and action != "jump":
		# only play locomotion/idle when not attacking or in air
		if hvel.length() > 0.05 and is_on_floor():
			action = "walk"
		else:
			action = "idle"
		model.play(action)

	move_and_slide()

func _on_data_died() -> void:
	# Play death animation and stop movement
	if model:
		model.play("death")
	velocity = Vector3.ZERO

func _on_data_damage_taken(raw_amount: int, final_amount: int, crit: bool) -> void:
	var dlabel = Label3D.new()
	dlabel.text = str(final_amount)
	dlabel.modulate = Color.RED
	dlabel.font_size = 60
	dlabel.scale = Vector3(2,2,2)
	dlabel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(dlabel)
	var tween = get_tree().create_tween()
	tween.tween_property(dlabel, "position", Vector3(randf_range(-0.5,0.5),2,randf_range(-0.5,0.5)), 2)
	tween.tween_callback(dlabel.queue_free)
	
func on_weapon_hit(body):
	#todo ตรวจสอบว่าเป็น player แล้ว เรียก take_damage 
	pass

func on_hp_changed(new_hp: int, old_hp: int):
	name_label.text = data.display_name
	progress_bar.value = data.get_stat("hp") / data.max_hp
