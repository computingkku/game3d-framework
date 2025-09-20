extends Node3D

signal hitbody(body: Node3D)
var hit_group = "monster"
var velocity = Vector3.ZERO
var lifetime = 1
var _time = 0

func _physics_process(delta: float) -> void:
	_time+=delta
	position += velocity * delta
	if _time > lifetime:
		queue_free()
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(hit_group):
		emit_signal("hitbody",body)
		await get_tree().create_timer(0.1).timeout
		queue_free()
	
