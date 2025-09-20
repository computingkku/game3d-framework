extends Node3D

signal hitbody(body: Node3D)
var hit_group :String = "monster"
var pre_animation = ""
var bullet_count=1

func get_animation(action:String,prev:String):
	pre_animation = prev
	#print("get_animation ",prev," ",action)
	if action=="attack":
		if prev != "attack":
			return {"name":"arrowLib/draw", 	"time":0.0}
		else:
			return {"name":"arrowLib/draw",  	"time":0.8}	
	elif action=="idle":
		return {"name":"arrowLib/idle_arrow", 	"time":0.0}		
	return null	
	
func attack(actor: CharacterModel) ->void:
	var arrow = preload("res://objects/bullet/arrow.tscn").instantiate()
	var delay_time = 1.2
	actor.right_hand.add_child(arrow)
	if pre_animation!="attack":
		#print("wait ",delay_time)
		await get_tree().create_timer(delay_time).timeout
	else :
		#print("wait ",0.05)
		await get_tree().create_timer(0.05).timeout
	if is_instance_valid(arrow):
		for i in bullet_count:
			#print("fire bullet")
			AudioManager.attack.play()
			var forward = actor.right_hand.global_transform.basis.y
			var origin = actor.right_hand.global_transform.origin
			var b = preload("res://objects/bullet/arrow_bullet.tscn").instantiate()
			b.global_transform.origin = origin
			b.hit_group = hit_group
			b.lifetime = 3
			b.velocity = forward.normalized()*20
			b.velocity.y = 0
			b.connect("hitbody",on_hitbody)
			get_tree().current_scene.add_child(b)
			await get_tree().create_timer(0.3).timeout		
		arrow.queue_free()
		
		
func on_hitbody(body: Node3D, pos:Vector3):
	emit_signal("hitbody",body)
