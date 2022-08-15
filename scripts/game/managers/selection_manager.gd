extends Node

signal group_member_selected
signal grid_tile_selected

var _current_target_group
var _active_dungeon


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon


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
		Utils.connect_signal(node, "clicked", self, "_select_group_member", [node, target_group], CONNECT_ONESHOT)
		Utils.connect_signal(
			node, "entered", self, "_toggle_highlightable", [node, true, highlight_color, fade, fade_frequency]
		)
		Utils.connect_signal(node, "exited", self, "_toggle_highlightable", [node, false])


func cancel_selection():
	_end_grid_tile_selection(null)

	if not _current_target_group:
		return

	print("cancelled selection")
	_select_group_member(null, null, _current_target_group)


# Enables selection for dungeon tiles. Will emit the grid_tile_selected
# signal when a valid tile has been selected.
#
# Can optionally provide a list of grid coordinates that the selection should
# be limited to. If not passed, any tile is considered valid selection.
func select_grid_tile(valid_grid_coordinates = null):
	DrawManager.enable_tile_highlighting(valid_grid_coordinates)
	Utils.connect_signal(_active_dungeon, "grid_tile_clicked", self, "_clicked_tile", [valid_grid_coordinates])


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


func _clicked_tile(event, loc, pathfinder, valid_grid_coordinates):
	var grid_coordinate = _active_dungeon.get_grid_position(loc)
	if valid_grid_coordinates and valid_grid_coordinates.size() > 0 and not valid_grid_coordinates.has(grid_coordinate):
		return

	_end_grid_tile_selection(grid_coordinate)


func _end_grid_tile_selection(grid_coordinate):
	DrawManager.disable_tile_highlighting()
	Utils.disconnect_signal(_active_dungeon, "grid_tile_clicked", self, "_clicked_tile")
	if grid_coordinate:
		emit_signal("grid_tile_selected", grid_coordinate)


func _disconnect_group_signals(group):
	var nodes = _get_group(group)
	for node in nodes:
		Utils.disconnect_signal(node, "clicked", self, "_select_group_member")
		Utils.disconnect_signal(node, "entered", self, "_toggle_highlightable")
		Utils.disconnect_signal(node, "exited", self, "_toggle_highlightable")
		_toggle_highlightable(null, node, false)


func _get_group(group):
	if typeof(group) == TYPE_ARRAY:
		return group

	if typeof(group) != TYPE_STRING:
		group = "interactable"

	return get_tree().get_nodes_in_group(group)
