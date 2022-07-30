extends Node

signal group_member_selected

var _current_target_group


# Sets up nodes in target_group for selection
# and returns the selected member when the
# group_member_selected signal is emitted.
#
# target_group can be either a string, or an array
# of nodes. If it's a string, the group is the result
# of calling get_nodes_in_group() with the string. If
# the target_group is null, it defaults to "interactable".
# If the target_group is empty, null will be returned.
func wait_until_group_member_selected(target_group, highlight_color = null, fade = false, fade_frequency = 0):
	select_member_of_group(target_group, highlight_color, fade, fade_frequency)
	var member = yield(self, "group_member_selected")
	return member


# Sets up nodes in target_group for selection. Will
# emit the group_member_selected signal when a selection
# is made.
#
# target_group can be either a string, or an array
# of nodes. If it's a string, the group is the result
# of calling get_nodes_in_group() with the string. If
# the target_group is null, it defaults to "interactable".
# If the target_group is empty, null will be returned.
func select_member_of_group(target_group, highlight_color = null, fade = false, fade_frequency = 0):
	if _current_target_group:
		printerr("Already in process of selecting group member!")
		return

	_current_target_group = target_group
	var group = _get_group(target_group)

	if group.empty():
		yield(get_tree(), "idle_frame")
		_select_group_member(null, null, [])
		return

	for node in group:
		if node.has_signal("clicked"):
			node.connect("clicked", self, "_select_group_member", [node, target_group])
			node.connect("entered", self, "_toggle_highlightable", [node, true, highlight_color, fade, fade_frequency])
			node.connect("exited", self, "_toggle_highlightable", [node, false])


func cancel_selection():
	if not _current_target_group:
		return

	print("cancelled selection")
	_select_group_member(null, null, _current_target_group)


# ==================
#      PRIVATE
# ==================


func _toggle_highlightable(event, highlightable, highlighted, color = null, fade = false, fade_frequency = 0):
	highlightable.toggle_highlight(highlighted, color, fade, fade_frequency)


func _select_group_member(event, member, target_group):
	_disconnect_group_signals(target_group)
	_current_target_group = null

	if member:
		print("Group member selected: " + member.name)

	emit_signal("group_member_selected", member)


func _disconnect_group_signals(group):
	var nodes = _get_group(group)
	for node in nodes:
		if node.is_connected("clicked", self, "_select_group_member"):
			node.disconnect("clicked", self, "_select_group_member")
			node.disconnect("entered", self, "_toggle_highlightable")
			node.disconnect("exited", self, "_toggle_highlightable")


func _get_group(group):
	if typeof(group) == TYPE_ARRAY:
		return group

	if typeof(group) != TYPE_STRING:
		group = "interactable"

	return get_tree().get_nodes_in_group(group)
