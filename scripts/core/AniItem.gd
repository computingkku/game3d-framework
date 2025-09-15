extends Resource
class_name AniItem 

@export var name:String = ""
@export var time:= 1.0
@export var loop : Animation.LoopMode 
@export var blend := 0.2

func _init(_name: String, _time: float = 1.0, _loop=0, _blend=0.2):
	name=_name
	time=_time
	loop=_loop
	blend=_blend
