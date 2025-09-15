extends CanvasLayer

@export var player : CharacterBody3D
var data: PlayerData

@onready var heal_bar: TextureProgressBar = $HealBar
@onready var lb_attack: Label = $lbAttack
@onready var lb_defense: Label = $lbDefense
@onready var lb_stamina: Label = $lbStamina
@onready var lb_gold: Label = $lbGold
@onready var mp_bar: TextureProgressBar = $MpBar
@onready var lb_hp: Label = $HealBar/lbHP
@onready var lb_exp: Label = $lbExp
@onready var msg_v_box: VBoxContainer = $MsgVBox

func _ready() -> void:
	GameManager.connect("state_changed",on_state_changed)
	GameManager.ui_status_canvas = self 

func on_state_changed():
	if  !GameManager.player : return
	data = GameManager.player.data
	heal_bar.max_value = data.get_stat("max_hp")
	mp_bar.max_value = data.get_stat("max_mp")
	heal_bar.value = data.get_stat("hp")
	lb_hp.text = str(data.get_stat("hp"))
	mp_bar.value = data.get_stat("mp")
	lb_attack.text = str(data.get_stat("attack"))
	lb_defense.text = str(data.get_stat("defense"))
	lb_stamina.text = str(data.get_stat("stamina"))
	lb_exp.text = str(data.get_stat("exp"))
	#lb_gold.text = str(data.get_stat("gold"))
	var inventory : InventoryData =  GameManager.player.inventory
	if inventory : 
		lb_gold.text = str(inventory.get_item_count("gold"))

func notify(text:String):
	var dlabel = Label.new()
	dlabel.text = text
#	dlabel.font_size = 24
#	dlabel.horizontal_alignment =HORIZONTAL_ALIGNMENT_CENTER
	msg_v_box.add_child(dlabel)
	await get_tree().create_timer(8).timeout
	dlabel.queue_free()
