extends Actor3D
class_name Monster3D

@export var attack_interval := 2  # seconds between attacks
@export var data : MonsterData
# ---- Wander (idle roaming when no player in range) ----
@export var wander_speed_scale := 0.6
@export var wander_turn_speed_deg := 180.0  # degrees per second
@export var wander_min_time := 2.0
@export var wander_max_time := 4.0
@export var rebirth_time := 10

var _wander_time_left := 0.0
var _wander_yaw_deg := 0.0
var _player: Actor3D
var _attack_cooldown := 0.0

@export var weapon = ""
@export var shield = ""
@export var helmet = ""
@onready var capsule_mesh: MeshInstance3D = $CapsuleMesh


func init_data():
	if !data: data = MonsterData.new()	
	data = data.duplicate(true)
	capsule_mesh.visible =  !model 
	data.faction = "monster"
	data.hp = 100
	_data = data
	$fire_effect.emitting = true
	if weapon!="": data.equip_items.append(weapon)
	if shield!="": data.equip_items.append(shield)
	if helmet!="": data.equip_items.append(helmet)
	
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
	if _player && !_player._alive : _player=null
	$fire_effect.emitting = _alive
	if !_alive :
		super._physics_process(delta)
		return
	# cooldown timer
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)

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
			elif model:
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
	
	super._physics_process(delta)
	
	
func on_died():
	super.on_died()
	GameManager.notify("กำจัด "+data.display_name+" สำเร็จ ")
	var exp_reward = randi_range(data.exp_reward_min,data.exp_reward_max)
	var gold_reward = randi_range(data.gold_reward_min,data.gold_reward_max)	
	GameManager.give_reward(exp_reward,gold_reward)
	data.roll_loot(self)
	await get_tree().create_timer(2).timeout
	if rebirth_time>=3:
		await get_tree().create_timer(rebirth_time).timeout
		# เพิ่มพลังโจมตี และ พื้นคืนชีพ
		data.attack += 1
		data.exp_reward_max += 2
		data.gold_reward_max += 2
		data.reset_full()
		_alive = true
	else:
		await get_tree().create_timer(5).timeout
		queue_free()	
