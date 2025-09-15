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

func _ready() -> void:
	GameManager.connect("state_changed",on_state_changed)

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
	
