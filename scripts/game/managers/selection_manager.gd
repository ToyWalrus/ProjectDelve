extends Node

signal group_member_selected


# Sets up nodes in target_group for selection
#
# target_group can be either a string, or an array
# of nodes. If it's a string, the group is the result
# of calling get_nodes_in_group() with the string. If
# the target_group is null, it defaults to "interactable".
# If the target_group is empty, null will be returned.
func wait_until_group_member_selected(target_group, highlight_color = null, fade = false, fade_frequency = 0):
	print("Waiting for selection...")

	var group = _get_group(target_group)
	if group.empty():
		return null

	for node in group:
		node.connect("clicked", self, "_select_group_member", [node, target_group])
		node.connect("entered", self, "_toggle_highlightable", [node, true, highlight_color, fade, fade_frequency])
		node.connect("exited", self, "_toggle_highlightable", [node, false])

	var member = yield(self, "group_member_selected")
	return member


func _toggle_highlightable(event, highlightable, highlighted, color = null, fade = false, fade_frequency = 0):
	highlightable.toggle_highlight(highlighted, color, fade, fade_frequency)


func _select_group_member(event, member, target_group):
	_disconnect_group_signals(target_group)
	print("Group member selected: " + member.name)
	emit_signal("group_member_selected", member)


func _disconnect_group_signals(group):
	var nodes = _get_group(group)
	for node in nodes:
		node.disconnect("clicked", self, "_select_group_member")
		node.disconnect("entered", self, "_toggle_highlightable")
		node.disconnect("exited", self, "_toggle_highlightable")


func _get_group(group):
	if typeof(group) == TYPE_ARRAY:
		return group

	if typeof(group) != TYPE_STRING:
		group = "interactable"

	return get_tree().get_nodes_in_group(group)
