extends Node2D

@onready var weapons_grid: GridContainer = $Canvas/InventoryPanel/Scroll/VBox/WeaponsGrid
@onready var shields_grid: GridContainer = $Canvas/InventoryPanel/Scroll/VBox/ShieldsGrid
@onready var props_grid: GridContainer = $Canvas/InventoryPanel/Scroll/VBox/PropsGrid
@onready var other_grid: GridContainer = $Canvas/InventoryPanel/Scroll/VBox/OtherGrid

var player : Player3D
var is_built = false

func toggle():
	if $Canvas.visible: close()
	else: open()
	return $Canvas.visible
	
func open():
	player = GameManager.player
	if player or player.inventory:
		if !player.inventory.is_connected("inventory_changed",on_inventory_changed):
			player.inventory.connect("inventory_changed",on_inventory_changed)
	_build_inventory()
	$Canvas.visible = true
	
func close():
	$Canvas.visible = false

func _build_inventory() -> void:
	if !player or !player.inventory:
		push_warning("player.inventory not found for UI inventory")
		return
	_clear_grid(weapons_grid)
	_clear_grid(shields_grid)
	_clear_grid(props_grid)
	_clear_grid(other_grid)	
	# Build weapon buttons
	for id in player.inventory.slots:
		var item = player.inventory.slots[id]
		if item.count <=0 : continue
		var entry = item.data
		if !entry.icon && entry.icon_path:  
			entry.icon = load_icon(entry.icon_path)
		var btn = _make_item_button(entry.name+" "+str(item.count), entry.icon)
		btn.pressed.connect(_on_item_pressed.bind(entry))
		if entry.item_type == Types.ItemType.WEAPON:
			weapons_grid.add_child(btn)
		elif entry.item_type == Types.ItemType.SHIELD: 
			shields_grid.add_child(btn)	
		elif entry.item_type == Types.ItemType.EQUIPMENT:
			props_grid.add_child(btn)
		else:
			other_grid.add_child(btn)
	is_built = true	
		

func _make_item_button(text: String, icon_path) -> Button:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_FILL
	if icon_path is String and icon_path != "":
		var tex: Texture2D = load_icon(icon_path)
		if tex:
			b.icon = tex
	elif icon_path is Texture2D:
		b.icon = icon_path
		
	#b.vertical_icon_alignment = 0
	#b.icon_alignment = 1
	return b

func load_icon(path) -> Texture2D:
	var image = Image.load_from_file(path)
	image.resize(28,28)
	return ImageTexture.create_from_image(image)


func _clear_grid(grid: GridContainer) -> void:
	for c in grid.get_children():
		c.queue_free()

func _on_item_pressed(item:ItemData) -> void:
	player = GameManager.player
	if player:
		if item.is_equipable():
			player.data.equip_item_toggle(item)
		elif item.is_consumable():
			player.inventory.use_item(player.data,item.id)	

func _on_button_pressed() -> void:
	$Canvas.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_canvas_visibility_changed() -> void:
	GameManager.ui_visible = $Canvas.visible

func on_inventory_changed():
	_build_inventory()
	
