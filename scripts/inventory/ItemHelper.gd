# ItemHelper.gd
# Godot 4.x
# Utility functions for ItemData .
class_name ItemHelper
extends RefCounted

static func remove_item_by_type(list:Array[String], items: Array[ItemData], type:Types.ItemType):
	return list.filter(func(id): return get_type(items,id)!=type)

static func filter_item_by_type(list:Array[String], items: Array[ItemData], type:Types.ItemType):
	return list.filter(func(id): return get_type(items,id)==type)

static func get_type(items:Array[ItemData],id:String)->Types.ItemType:
	var item = find(items,id)
	if item: return item.item_type
	return -1
	
static func find(items:Array[ItemData],id:String)->ItemData:
	for x in items:
		if x.id == id: return x
	return null
static func find_all(items: Array[ItemData],list:Array[String]) -> Array[ItemData]:
	return items.filter(func(item): return item.id in list)
	
#  to load ItemData Resources from a JSON file.
static func load_items_array(json_path: String, owner: Node=null) -> Array[ItemData]:
	# Read file text
	var text := ""
	if FileAccess.file_exists(json_path):
		text = FileAccess.get_file_as_string(json_path)
	else:
		push_error("ItemJsonLoader: JSON file not found: %s" % json_path)
		return []
	
	if text.is_empty():
		push_error("ItemJsonLoader: JSON file is empty: %s" % json_path)
		return []
	
	# Parse JSON
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("ItemJsonLoader: root must be Array of items (got %s)" % typeof(parsed))
		return []
	
	var out: Array[ItemData] = []
	for i in parsed:
		if typeof(i) != TYPE_DICTIONARY:
			push_warning("ItemJsonLoader: skip non-dictionary element")
			continue
		var item: ItemData = _item_from_dict(i,owner)
		if item == null:
			continue
		out.append(item)
	return out

static func load_items_from_json(json_path: String, owner: Node=null) -> Dictionary[String, ItemData]:
	var items = load_items_array(json_path,owner)	
	var out: Dictionary[String, ItemData] = {}
	for item in items:
		if item.id == "":
			push_warning("ItemJsonLoader: item without id, skipped")
			continue
		out[item.id] = item
	return out

static func load_icon(path,w=28,h=28) -> Texture2D:
	var image = Image.load_from_file(path)
	image.resize(w,h)
	return ImageTexture.create_from_image(image)
	
static func _item_from_dict(d: Dictionary, owner: Node=null) -> ItemData:
	var item = ItemData.new()
	# Required
	item.id = str(d.get("id", ""))
	item.name = str(d.get("name", item.id))
	# Optional fields
	item.description = str(d.get("description", ""))
	# Enum item_type can be string ("WEAPON") or int (1)
	item.item_type = _parse_item_type(d.get("item_type", "CONSUMABLE"))
	# icon / mesh paths (optional, must be valid resource paths)
	if d.has("icon"):
		item.icon = load_icon(d["icon"])
	if owner and d.has("node"):
		item.node = owner.get_node(d["node"])	
	# stack / weight
	if d.has("stack_size"):
		item.stack_size = int(d["stack_size"])
	if d.has("weight"):
		item.weight = int(d["weight"])
	
	# effect (dictionary) -> ItemEffect Resource
	if d.has("effect") and typeof(d["effect"]) == TYPE_DICTIONARY:
		item.effect = _effect_from_dict(d["effect"])
	
	# meta (freeform key/values) — keep as Dictionary[StringName, Variant]
	if d.has("meta") and typeof(d["meta"]) == TYPE_DICTIONARY:
		var meta: Dictionary[StringName, Variant] = {}
		for k in d["meta"].keys():
			meta[StringName(str(k))] = d["meta"][k]
		item.meta = meta
	
	return item

static func _parse_item_type(v) -> Types.ItemType:
	# Accept int 0..n or string names ("CONSUMABLE", "WEAPON", ...)
	match typeof(v):
		TYPE_INT:
			return Types.ItemType.values()[clampi(int(v), 0, Types.ItemType.size() - 1)]
		TYPE_STRING, TYPE_STRING_NAME:
			var s := String(v).to_upper()
			if Types.ItemType.has(s):
				return Types.ItemType[s]
	return Types.ItemType.CONSUMABLE

static func _effect_from_dict(d: Dictionary) -> ItemEffect:
	var eff := ItemEffect.new()
	# states_add
	if d.has("states_add") and typeof(d["states_add"]) == TYPE_DICTIONARY:
		eff.states_add = {}
		for k in d["states_add"].keys():
			eff.states_add[StringName(str(k))] = float(d["states_add"][k])
			
	if d.has("states_mul") and typeof(d["states_mul"]) == TYPE_DICTIONARY:
		eff.states_mul = {}
		for k in d["states_mul"].keys():
			eff.states_mul[StringName(str(k))] = float(d["states_mul"][k])
	
	return eff
