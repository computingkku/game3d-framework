extends Node3D
class_name CharacterModel

signal weapon_hit(body: Node3D)
signal attack()

@export var items : Array[ItemData] = []
@export var equip_items: Array[String] = []  # ค่า default อุปกรณ์สวมใส่
@export var animations: Dictionary = {
	"attack":["attack"],		
	"attack_weapon":["attack"],
	"walk":["walk"],
	"idle":["idle"],
	"jump":["jump"],
	"death":["death"],
}
@export var speed = 2.0
@export var attack_time_start=0.2
@export var attack_time_hit=0.8
@export var attack_time_back=0.2

var animation_player : AnimationPlayer
var current_action=""
var is_attack = false     # กำลังอยู่ในท่าโจมตี 
var is_attackhit = false  # ช่วงที่โจมตีเสียหาย
var is_death = false		# ช่วงตาย
var weapon_collision :CollisionShape3D = null
var equip_weapon  = -1
var equip_shield  = -1
var equip_props :Array[int] = [0] 

func _ready() -> void:
	init()
	_update_state(equip_items)
	animation_player.connect("animation_finished",on_animation_finished)

# ให้ overridden 
func init():
	pass

func _update_state(equipments):
	if weapon_collision : weapon_collision.disabled = true
	equip_weapon = -1	
	equip_shield = -1
	equip_props  = [] 
	for i in items.size():
		var item = items[i]
		if !item.node and item.node_path: 
			item.node = get_node(item.node_path)
		if item.node: item.node.set("visible",false)
		else: continue			
		match item.item_type:
			Types.ItemType.WEAPON:
				if equip_weapon<0 and item.id in equipments:
					equip_weapon = i
					item.node.set("visible",true)
					#print("ใส่อาวุธ ",item.name)
			Types.ItemType.SHIELD:
				if equip_shield<0 and item.id in equipments:
					equip_shield = i
					item.node.set("visible",true)
					#print("ใส่โล่ ",item.name)
			Types.ItemType.EQUIPMENT:
				if item.id in equipments:
					item.node.set("visible",true)
					#print("อุปกรณ์อื่น ๆ",item.name)
	
func get_animation_name(action,defval="idle"):
	var name=defval
	if action!="":
		var list:Array = animations.get(action,[])
		if equip_weapon>=0: 
			list = animations.get(action+"_weapon",list)
			if list==null || list.size()==0 : list=animations.get(action,[])
		if list != null || list.size()>0:
			name = list.pick_random()
	return name

func play(action: StringName = &"", custom_blend: float = 0.2):
	if speed<=0.5 : speed=0.5
	if action != "death" and is_attack: return
	if action != "idle" and action != "death":
		if action == current_action && animation_player.current_animation!="" : 
			return		
	current_action = action
	var name=get_animation_name(action)
	if name and animation_player.current_animation != name:
		#print(self,name)
		animation_player.play(name,custom_blend,speed)
	if action == "attack":
		is_attack=true
		is_attackhit=false
		await get_tree().create_timer(attack_time_start/speed).timeout
		emit_signal("attack")
		is_attackhit=true
		if weapon_collision: weapon_collision.disabled = false
		await get_tree().create_timer(attack_time_hit/speed).timeout
		is_attackhit=false
		if weapon_collision: weapon_collision.disabled = true
		await get_tree().create_timer(attack_time_back/speed).timeout		
		is_attack=false

func on_animation_finished(anim_name:StringName):
	current_action=""
	
func _on_weapon_area_body_entered(body: Node3D) -> void:
	#print(self,body)
	weapon_hit.emit(body)

func _load_animation_data(json_path:String)->Dictionary:
	var text := ""
	if FileAccess.file_exists(json_path):
		text = FileAccess.get_file_as_string(json_path)
		var parsed = JSON.parse_string(text)
		if typeof(parsed) != TYPE_DICTIONARY:
			push_error("ItemJsonLoader: root must be Array of items (got %s)" % typeof(parsed))
		else:
			animations = parsed
		for key in animations.keys():
			for a in animations[key]:
				var anim = animation_player.get_animation(a)
				if !anim : continue
				if key == "idle" or key == "idle_weapon":
					anim.loop_mode = Animation.LOOP_LINEAR	
				else:
					anim.loop_mode = Animation.LOOP_NONE
				
	return animations
		
func _load_items_data(json_path:String)->Array[ItemData]:
	items = ItemHelper.load_items_array(json_path,self)
	return items
	
func load_data(name:String):
	_load_items_data("res://resources/"+name+"_items.json")
	_load_animation_data("res://resources/"+name+"_animations.json")
