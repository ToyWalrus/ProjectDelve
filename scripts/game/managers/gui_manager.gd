extends Node


# Gets the Hero GUI in the current scene. If not
# present, this returns null.
func get_hero_gui() -> HeroTurnGUI:
	var guis = _get_gui_type("hero")
	if guis.empty():
		return null
	return guis[0]


func _get_gui_type(type: String) -> Array:
	var guis = []
	var nodes = get_tree().get_nodes_in_group("gui")
	for node in nodes:
		if node.get_meta("gui_type") == type:
			guis.append(node)
	return guis
