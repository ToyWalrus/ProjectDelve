extends Node

var _active_dungeon
var _prev_target_point


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon


func enable_path_drawing(unit, can_use_stamina, max_cost):
	if not _active_dungeon:
		printerr("Cannot enable path drawing, no dungeon has been set")
		return

	Utils.connect_signal(_active_dungeon, "grid_tile_hovered", self, "_draw_path", [unit, can_use_stamina, max_cost])


func disable_path_drawing():
	if not _active_dungeon:
		return

	_active_dungeon.clear_drawings()
	Utils.disconnect_signal(_active_dungeon, "grid_tile_hovered", self, "_draw_path")


func enable_target_drawing(from_unit, target_group = null, needs_LoS = true, max_range = 10000):
	if not _active_dungeon:
		printerr("Cannot enable target drawing, no dungeon has been set")
		return

	if not target_group:
		Utils.connect_signal(
			_active_dungeon,
			"grid_tile_hovered",
			self,
			"_draw_target_to_point",
			[from_unit.position, needs_LoS, max_range]
		)
	else:
		var group = get_tree().get_nodes_in_group(target_group)
		for node in group:
			if Utils.connect_signal(
				node, "entered", self, "_draw_target_to_group_member", [node, from_unit.position, needs_LoS, max_range]
			):
				# Make the listen area 50% larger
				node.extend_bounds(node.bounds * 0.5)
			Utils.connect_signal(node, "exited", self, "_erase_target_to_group_member")


func disable_target_drawing(target_group = null):
	if not _active_dungeon:
		return

	Utils.disconnect_signal(_active_dungeon, "grid_tile_hovered", self, "_draw_target_to_point")

	if target_group:
		var group = get_tree().get_nodes_in_group(target_group)
		for node in group:
			if Utils.disconnect_signal(node, "entered", self, "_draw_target_to_group_member"):
				node.revert_extended_bounds()
			Utils.disconnect_signal(node, "exited", self, "_erase_target_to_group_member")

	_active_dungeon.clear_drawings()


func enable_tile_highlighting(valid_points):
	if not _active_dungeon:
		printerr("Cannot enable path tile highlighting, no dungeon has been set")
		return

	Utils.connect_signal(_active_dungeon, "grid_tile_hovered", self, "_highlight_tile", [valid_points])


func disable_tile_highlighting():
	if not _active_dungeon:
		return

	Utils.disconnect_signal(_active_dungeon, "grid_tile_hovered", self, "_highlight_tile")
	_active_dungeon.clear_drawings()


# ===================
# 		PRIVATE
# ===================


func _draw_path(event, loc, pathfinder, unit, can_use_stamina, max_cost = 10000):
	var color = Color("#12f957")

	var path = unit.path_to(loc, pathfinder)
	var can_move_to = unit.can_move_to(loc, pathfinder, false, max_cost)

	if not can_move_to:
		var can_move_to_with_stamina := false
		if can_use_stamina:
			color = Color("#e8a948")
			can_move_to_with_stamina = unit.can_move_to(loc, pathfinder, true, max_cost)
		if not can_move_to_with_stamina:
			return

	_active_dungeon.draw_path(path, color)


# Used when specifically targeting a group of nodes
func _draw_target_to_group_member(event, member, from_point, needs_LoS, max_range):
	var to_point = member.position  # _active_dungeon.map_to_world_point(member.position)
	_prev_target_point = null
	_draw_target_to_point(event, to_point, null, from_point, needs_LoS, max_range)


func _erase_target_to_group_member(event):
	_active_dungeon.clear_drawings()


# Used when targeting any tile on the map
func _draw_target_to_point(event, to_point, pathfinder, from_point, needs_LoS, max_range):
	if to_point == _prev_target_point:
		return

	var has_LoS := true
	if needs_LoS:
		has_LoS = _active_dungeon.has_line_of_sight_to(from_point, to_point)

	_active_dungeon.draw_target(from_point, to_point, has_LoS, max_range, needs_LoS)
	_prev_target_point = to_point


func _highlight_tile(event, loc, pathfinder, valid_points):
	var grid_coordinate = _active_dungeon.get_grid_position(loc)
	if valid_points and valid_points.size() > 0 and not valid_points.has(grid_coordinate):
		_active_dungeon.clear_drawings()
		return

	_active_dungeon.draw_tile_highlight(grid_coordinate)
