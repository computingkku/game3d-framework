extends Node2D

@onready var viewport: SubViewport = $SubViewport
@onready var container: HFlowContainer = $HFlowContainer

func _on_button_pressed() -> void:
	var json_path = "res://resources/items.json"
	var text = FileAccess.get_file_as_string(json_path)
	var parsed = JSON.parse_string(text)
	for item in parsed:
		var id = item['id']
		var icon_path = "res://objects/items/"+id+"_icon.png"
		var scene = load("res://objects/items/"+id+".tscn")
		var obj = viewport.get_node(id)
		if obj:
			obj.visible = true
			#var obj = scene.instantiate()
			#var zoom = item.get("icon_zoom",1.0)
			#viewport.add_child(obj)
			#obj.position = Vector3.ZERO
			#obj.position.x = -0.14
			#obj.rotation.x = 90
			#obj.scale = obj.scale * Vector3(2*zoom,zoom,2*zoom)
			await get_tree().create_timer(0.2).timeout
			await get_tree().process_frame
			var img: Image = viewport.get_texture().get_image()
			img.resize(40,40)
			img.save_png(icon_path)
			print("บันทึก icon ที่: ", icon_path)
			var btn = _make_item_button(item['name'],img)
			container.add_child(btn)
			obj.visible = false
			#obj.queue_free()

func _make_item_button(text: String,img:Image) -> Button:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_FILL
	var tex: Texture2D = ImageTexture.create_from_image(img)
	b.icon = tex
	return b
