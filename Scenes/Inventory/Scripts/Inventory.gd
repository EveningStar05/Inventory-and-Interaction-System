extends Node

# Inventory features:
# 1. Add item: players can add item to the inventory
# 2. Craft item (update and remove): players can craft item within the inventory
# 3. Inspect item: players can inspect item within the inventory (pop up window)

signal extend_slot()
signal display_item_to_inventory(item_index, texture_path)

var inventory_list: Array = [null, null, null, null, null, null]
var item_data = ImportData.load_data("res://item-list.json")
var texture_path = null

func extend_inv() -> void: # extending inventory slot
	if not null in inventory_list: 
		inventory_list.push_back(null)
		emit_signal("extend_slot")

func add_item(item_name: StaticBody2D) -> void:
	# add items to the inventory
	var itemName = item_name.get_name() # get the item name
	var itemIndex = inventory_list.find(null) # find null reference
	
	# always add item to the first slot.
	# if the first slot is not empty then we're adding the item to the next empty slot
	if itemIndex != -1:
		inventory_list[itemIndex] = itemName # set the added item to the first slot
	texture_path =  item_data[itemName]["texture-path"] # texture path for the added item
	# checks for empty slot
	extend_inv()

#	# emit a signal and pass the item index and texture path
	emit_signal("display_item_to_inventory", itemIndex, texture_path)
	
func get_craft_item(selected_item: String) -> String: # helper function, get craftable item
	var get_item_name = item_data[selected_item]["craftable-item"]["combine-item-result"]
	return get_item_name
	
func craft_item(item_index: int, target_item_index: int) -> String: # item_index: index, target_item_index: index
	
	var new_item = get_craft_item(inventory_list[item_index]) # fetch the craftable item, if exist
	# update texture and inventory_list
	inventory_list[target_item_index] = new_item 
	texture_path = item_data[new_item]["texture-path"]
	
	emit_signal("display_item_to_inventory", target_item_index, texture_path)
	remove_item(item_index) # remove the previous item (the selected item)
	
	return new_item

# remove item from list and update the display texture
func remove_item(item_index: int):
	inventory_list[item_index] = null
	emit_signal("display_item_to_inventory", item_index, null)
