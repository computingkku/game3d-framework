extends Node3D

signal hitbody(body: Node3D, pos:Vector3)
var hit_group = "monster"
var velocity = Vector3.ZERO
var lifetime = 1
var _time = 0

func _physics_process(delta: float) -> void:
	_time+=delta
	#if velocity!=Vector3.ZERO:
		##velocity.y -= GameManager.gravity*delta*0.5
		#look_at(global_transform.origin + velocity, Vector3.UP)
		## หมุนเพิ่ม 90 องศา รอบแกน X เพื่อให้แกน Y ไปแทน Z
		#rotate_x(deg_to_rad(-90))

	position += velocity * delta
	if _time > lifetime:
		queue_free()
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(hit_group):
		emit_signal("hitbody",body,global_position)
		queue_free()
	
