extends Node


# Gets the Unit turn GUI in the current scene. If not
# present, this returns null.
func get_unit_turn_gui():
	var guis = get_tree().get_nodes_in_group("gui")
	if guis.empty():
		return null
	return guis[0]
