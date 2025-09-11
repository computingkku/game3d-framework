extends Node3D
class_name CharacterModel

@export var equip_weapon  = -1
@export var equip_shield  = -1
@export var equip_props :Array[int] = [0] 

var weapons = [] # อาวุธ  {"name":"ชื่อ", "item":MeshInstance3D }
var shields = [] # โล่
var props = []  # อุปกรณ์สวมใส่อื่น ๆ 
var animation_player : AnimationPlayer
var actions={
	"attack":["attack"],		
	"attack_weapon":["attack"],
	"walk":["walk"],
	"walk_weapon":["walk"],
	"idle":["idle"],
	"idle_weapon":["idle"],
	"jump":["jump"],
	"jump_weapon":["jump"],
	"death":["death"],
}
var current_action="idle"

func _ready() -> void:
	init()
	equip_props.resize(props.size())
	_update_state()
	animation_player.connect("animation_finished",on_animation_finished)

# ให้ overided  
func init():
	pass

func _update_state():
	for x in weapons:
		if x['item']: x['item'].visible = false
	for x in shields:
		if x['item']: x['item'].visible = false
	
	var id=0	
	for x in props:
		if x['item']: x['item'].visible = equip_props[id]
		id=id+1
	
	if equip_weapon>=0 :
		weapons[equip_weapon]['item'].visible = true
	if equip_shield>=0 :
		shields[equip_shield]['item'].visible = true				
	pass	

func equip_weapon_at(index: int) -> void:
	if index >= 0 and index < weapons.size():
		equip_weapon = index
		_update_state()

func equip_shield_at(index: int) -> void:
	if index >= 0 and index < shields.size():
		equip_shield = index
		_update_state()

func get_animation_name(action,defval="idle"):
	var name=defval
	if action!="":
		var list:Array = actions.get(action,null)
		if equip_weapon>=0: 
			list = actions.get(action+"_weapon",list)
			if list==null || list.size()==0 : list=actions.get(action,null)
		if list != null || list.size()>0:
			name = list.pick_random()
	return name

func play(action: StringName = &"", custom_blend: float = 0.2):
	if action == "idle" && !(current_action in ["","jump"]) : return
	if action == current_action && animation_player.current_animation!="" : return		
	current_action = action
	var name=get_animation_name(action)
	if animation_player.current_animation != name:
		animation_player.play(name,custom_blend)

func on_animation_finished(anim_name:StringName):
	current_action=""
	
