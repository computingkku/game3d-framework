extends Node3D

@export var animations : Array[AniItem] = []
@export var loop : Animation.LoopMode 
var play_id = 0

func play_list(list:Array[AniItem]):
	play_id += 1
	var pid = play_id
	for a in list:
		play(a.name,a.loop)
		await get_tree().create_timer(a.time).timeout
		if play_id != pid: break
		
func play(name:String, loop:int=0):
	var anim = $AnimationPlayer.get_animation(name)
	if anim :
		anim.set_loop_mode(loop)
		$AnimationPlayer.play(name,0.2)

func clear():
	animations.clear()
	
func add(_name: String, _time: float = 1.0, _loop=0, _blend=0.2):
	animations.append(AniItem.new(_name,_time,loop, _blend))

func start():
	play_list(animations)
