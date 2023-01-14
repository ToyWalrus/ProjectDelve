extends Node


# Gets the Unit turn GUI in the current scene. If not
# present, this returns null.
func get_unit_turn_gui():
	var guis = get_tree().get_nodes_in_group("unit_gui")
	if guis.empty():
		return null
	return guis[0]


func get_avatar_selection_gui():
	var guis = get_tree().get_nodes_in_group("avatar_selection")
	if guis.empty():
		return null
	return guis[0]


func get_skill_list_gui():
	var guis = get_tree().get_nodes_in_group("unit_gui")
	if guis.empty():
		return null
	return guis[1]
