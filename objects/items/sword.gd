extends Node3D

signal hitbody(body: Node3D)
var marker: Marker3D 
var hit_group :String = "monster"

func _ready() -> void:
	marker = get_node("Marker3D")
	if marker == null:
		marker = Node3D.new()
		marker.position = Vector3(0.7,0,0)

func attack(actor: CharacterModel,delay_time=0.0) ->void:
	if delay_time>0:
		await get_tree().create_timer(delay_time).timeout
	var slash = preload("res://objects/bullet/sword_slash.tscn").instantiate()
	slash.hit_group = hit_group
	#slash.global_position = marker.global_position
	marker.add_child(slash)
	
func on_hitbody(body: Node3D):
	emit_signal("hitbody",body)
