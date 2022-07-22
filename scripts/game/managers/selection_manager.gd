extends Node

signal unit_selected


func wait_until_unit_selected(highlight_color = null, fade = false, fade_frequency = 0, target_unit_group = null):
	print("Waiting for unit selection...")

	var units = _get_group(target_unit_group)
	for unit in units:
		unit.connect("clicked", self, "_select_unit", [unit, target_unit_group])
		unit.connect("entered", self, "_toggle_highlightable", [unit, true, highlight_color, fade, fade_frequency])
		unit.connect("exited", self, "_toggle_highlightable", [unit, false])

	var unit = yield(self, "unit_selected")
	return unit


func _toggle_highlightable(event, highlightable, highlighted, color = null, fade = false, fade_frequency = 0):
	highlightable.toggle_highlight(highlighted, color, fade, fade_frequency)


func _select_unit(event, unit, target_unit_group):
	_disconnect_group_signals(target_unit_group)
	print("Unit selected: " + unit.name)
	emit_signal("unit_selected", unit)


func _disconnect_group_signals(group):
	var units = _get_group(group)
	for unit in units:
		unit.disconnect("clicked", self, "_select_unit")
		unit.disconnect("entered", self, "_toggle_highlightable")
		unit.disconnect("exited", self, "_toggle_highlightable")


func _get_group(group = null):
	if not group:
		group = "units"
	return get_tree().get_nodes_in_group(group)
