extends TextureRect

signal inspect_item(slot_index)

func _ready() -> void:
	Inventory.connect("display_item_to_inventory", self, "_on_display_item_to_inventory")
		
func _gui_input(event) -> void: # detecting mouse clicks, for inspecting item
	var item_index = get_parent().get_index()
	if event is InputEventMouseButton:
		if event.doubleclick and self.texture != null: # double click item to inspect
			emit_signal("inspect_item", item_index)
	
func _on_display_item_to_inventory(index: int, texture_path) -> void: # sets the display
	var slot_list = get_tree().get_nodes_in_group("slots")
	
	if texture_path != null: # craft and add item
		var load_texture = load(texture_path)
		slot_list[index].get_node("Item").set_texture(load_texture)
	else: # removing item from slot display
		slot_list[index].get_node("Item").set_texture(texture_path)

func get_drag_data(_position: Vector2): # get the selected item data
	var data = {} # passing the data to the other 2 function
	
	data["origin_node"] = get_parent()
	data["origin_node_index"] = data["origin_node"].get_index()
	
	if self.texture != null: # if the slot is not empty
		data["origin-item-name"] = Inventory.inventory_list[data["origin_node_index"]]
		data["origin_texture"] = texture
		
		var texture_node = TextureRect.new() # create a new texture node for drag preview
		texture_node.expand = true # set the texture to whatever item is being added in the inventory
		texture_node.texture = texture
		texture_node.rect_size = Vector2(95, 95)
		texture_node.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		 
		# set the item to the middle of mouse position, so what we're doing here is add a Control node
		# and set the position of the item relative to the mouse cursor.
		var control_node = Control.new()
		control_node.add_child(texture_node)
		texture_node.rect_position = -0.5 * texture_node.rect_size
		set_drag_preview(control_node)
	else:
		data["origin-item-name"] = null
		data["origin_texture"] = texture
	
	return data

func can_drop_data(_position, data): # checks wether this item can be drop at this particular slot

	data["target_slot"] = get_parent()
	data["target_slot_index"] = data["target_slot"].get_index()
	data["target_item_name"] = Inventory.inventory_list[data["target_slot_index"]] # set the target name from the inventory list
	data["target_texture"] = texture

	if Inventory.item_data.has(data["origin-item-name"]): # if the draggable data exist in the dictionary
		if Inventory.item_data[data["origin-item-name"]]["craftable-item"]["item-name"] == data["target_item_name"]:
			return true
		else:
			return false
	
func drop_data(_position, data): # drop the item to the slot
	
	var new_item = Inventory.craft_item(data["origin_node_index"], data["target_slot_index"])
	
	# update the new item to the data dict
	data["target_item_name"] = new_item
	data["target_texture"] = texture
