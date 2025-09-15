extends Node

signal state_changed()

var player : CharacterBody3D 
var gravity = 10
var ui_visible = false
var ui_status_canvas = null

func set_player(p:CharacterBody3D):
	player = p
	if player: 
		player.data.connect("stats_changed",emit_state_changed)
	await get_tree().create_timer(1).timeout
	emit_state_changed()
	
func get_item(id:String)->ItemData:
	if player and player.model:
		return ItemHelper.find(player.model.items,id)
	return null	

func emit_state_changed():
	emit_signal("state_changed")

func give_reward(exp,gold):
	if player:
		if(exp>0) : notify("เพิ่มค่าประสบการณ์ "+str(exp))
		if(gold>0): notify("ได้รับทอง "+str(gold))
		player.data.add_exp(exp)
		player.inventory.add_item_by_id("gold",gold)	

func notify(text:String):
	if ui_status_canvas:
		ui_status_canvas.notify(text)
