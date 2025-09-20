extends Node3D
class_name CharacterModel

signal weapon_hit(body: Node3D)
signal attack()
@export var id :String = ""
@export_node_path("Skeleton3D") var skeleton_path : NodePath
@export_node_path("AnimationPlayer") var animation_path : NodePath = NodePath("AnimationPlayer")
@export var autoload_animation := true
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
@export var speed = 1.0
@export var attack_time_start=0.2
@export var attack_time_hit=0.8
@export var attack_time_back=0.2
@export var attack_speed = 1.0
@export_node_path("Node3D") var righthand_path : NodePath = NodePath("GeneralSkeleton/RightHand")
@export_node_path("Node3D") var lefthand_path : NodePath = NodePath("GeneralSkeleton/LeftHand")

var animation_player : AnimationPlayer
var current_action=""
var prev_action=""
var is_attack = false     # กำลังอยู่ในท่าโจมตี 
var is_attackhit = false  # ช่วงที่โจมตีเสียหาย
var is_death = false		# ช่วงตาย
var is_hurt = false
var weapon_collision :CollisionShape3D = null
var equip_weapon  = -1
var equip_shield  = -1
var equip_props :Array[int] = [0] 
var skeleton : Skeleton3D
var right_hand : Node3D
var right_hand_item :Node3D = null
var left_hand : Node3D
var left_hand_item :Node3D = null
var weapon_node : Node3D = null

func _ready() -> void:
	if animation_path: animation_player = get_node(animation_path)
	if skeleton_path: skeleton = get_node(skeleton_path)
	if skeleton :
		init_hands()
	if !animation_player:	
		animation_player = AnimationPlayer.new()
		add_child(animation_player)
	if autoload_animation:
		GameManager.loadAnimationLib(animation_player)
		_load_animation_data("res://resources/melee_animations.json")
	init()
	_update_state(equip_items)
	animation_player.connect("animation_finished",on_animation_finished)

func init_hands():
	if has_node(righthand_path):
		right_hand = get_node(righthand_path)
	if has_node(lefthand_path):
		left_hand = get_node(lefthand_path)
	
	if !right_hand: 
		right_hand = BoneAttachment3D.new()
		skeleton.add_child(right_hand)
		right_hand.bone_name = "RightHand"
	if !left_hand:	
		left_hand = BoneAttachment3D.new()
		skeleton.add_child(left_hand)
		left_hand.bone_name = "LeftHand"

func equip_item(id:String):
	var itemdata = GameManager.get_item(id)
	var item_node = null
	if itemdata and itemdata.scene:
		if itemdata.hand == "right":
			if right_hand_item!=null: right_hand_item.queue_free()
			right_hand_item = itemdata.scene.instantiate()
			right_hand.add_child(right_hand_item)
			item_node = right_hand_item
		elif itemdata.hand == "left":
			if left_hand_item!=null: left_hand_item.queue_free()
			left_hand_item = itemdata.scene.instantiate()
			left_hand.add_child(left_hand_item)
			item_node = left_hand_item
		if itemdata.item_type == Types.ItemType.WEAPON:
			weapon_node = item_node	
			weapon_node.connect("hitbody",_on_weapon_area_body_entered)
	return item_node

func free_hand(hand:String):
	if hand=="right" and right_hand_item!=null: 
		if weapon_node==right_hand_item:weapon_node=null 
		right_hand_item.queue_free()
		right_hand_item=null				
	if hand=="left" and left_hand_item!=null: 
		if weapon_node==left_hand_item:weapon_node=null 
		left_hand_item.queue_free()
		left_hand_item=null
	
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
	var start_time=0.0
	
	if action!="":
		var list:Array = animations.get(action,[])
		if weapon_node!=null:
			list = animations.get(action+"_weapon",list)
			if weapon_node.has_method("get_animation"):
				var a = weapon_node.call("get_animation", action, prev_action)
				if a!=null:
					return a
			if list==null || list.size()==0 : 
				list=animations.get(action,[])
		if list != null || list.size()>0:
			name = list.pick_random()
	return {"name":name,"time":start_time}

func play(action: StringName = &"", custom_blend: float = 0.2):
	if speed<=0.5 : speed=0.5
	if action != "death":
		if is_attack or is_hurt: return false
		if action == current_action && animation_player.current_animation!="" : 
			return	false	
		if action=="hurt":
			is_hurt = true
			
	current_action = action
	var animation=get_animation_name(action)
	var name = animation['name']
	#print("play",action,name)
	#if id == "kachujin":
		#print("play ",prev_action," ",action," "+name)
	if name and animation_player.current_animation != name:
		animation_player.play_section(name,animation['time'],-1,custom_blend,speed)
	elif animation_player.current_animation != action:
		animation_player.play(action,custom_blend)
	if action == "attack":
		on_attack()
	prev_action = current_action	
	return true
func on_animation_finished(anim_name:StringName):
	var next=current_action
	is_attack=false	
	is_attackhit=false
	is_hurt = false
	prev_action = current_action
	if current_action=="hurt" : next="idle"
	if current_action in ["attack","death"]:
		next = ""
	current_action = ""
	if next!="":
		play(next)	
	
func on_attack():
	is_attack=true
	is_attackhit=false
	if weapon_node and weapon_node.has_method("attack"):
		weapon_node.call("attack",self)
	else:
		AudioManager.attack.play()	
	if prev_action!="attack":
		await get_tree().create_timer(attack_time_start/speed).timeout			
	emit_signal("attack")
	is_attackhit=true
	#is_attackhit=true
	#if weapon_collision: weapon_collision.disabled = false
	##await get_tree().create_timer(attack_time_hit/speed).timeout
	#is_attackhit=false
	#if weapon_collision: weapon_collision.disabled = true
	##await get_tree().create_timer(attack_time_back/speed).timeout		
	#is_attack=false	


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
				if key == "idle" or key == "idle_weapon" :
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
