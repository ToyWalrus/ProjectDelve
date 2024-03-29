extends Node

var _active_dungeon
var _tile_size := 1.0

signal unit_entered_tile
signal unit_exited_tile


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon
	if dungeon:
		_tile_size = dungeon.floors.cell_size.x
	else:
		_tile_size = 1.0


func grid_to_world_position(grid_coordinate: Vector2, with_offset := false) -> Vector2:
	return _active_dungeon.map_to_world_point(grid_coordinate, with_offset)


func get_nodes_within_grid_radius(world_point: Vector2, tile_radius: int, node_groups: PoolStringArray):
	var within_radius := []
	for node_group in node_groups:
		var nodes = get_tree().get_nodes_in_group(node_group)
		for node in nodes:
			if (
				not within_radius.has(node)
				and _active_dungeon.tile_distance_to(world_point, node.position) <= tile_radius
			):
				within_radius.append(node)
	return within_radius


func tile_distance(grid_coordinate_a: Vector2, grid_coordinate_b: Vector2) -> int:
	var dx = abs(grid_coordinate_a.x - grid_coordinate_b.x)
	var dy = abs(grid_coordinate_a.y - grid_coordinate_b.y)
	return [int(dx), int(dy)].max()


func world_to_grid_coordinate(world_point: Vector2):
	return _active_dungeon.get_grid_position(world_point)


func get_empty_grid_spaces_adjacent_to(world_point: Vector2, obstacle_groups: PoolStringArray = []):
	var walkable_tiles := []
	for neighbor_point in _get_neighbor_vectors(world_point, Vector2(_tile_size, _tile_size)):
		if _active_dungeon.walkable_tile_exists_at(neighbor_point):
			walkable_tiles.append(_active_dungeon.get_grid_position(neighbor_point))

	if not obstacle_groups or obstacle_groups.size() == 0:
		return walkable_tiles

	for group in obstacle_groups:
		var obstacles := get_grid_coordinates_of_group(group)
		for obstacle in obstacles.keys():
			walkable_tiles.erase(obstacle)

	return walkable_tiles


func get_grid_coordinates_of_group(group: String) -> Dictionary:
	var coordinates := {}
	var nodes = get_tree().get_nodes_in_group(group)

	for node in nodes:
		coordinates[_active_dungeon.get_grid_position(node.position)] = node

	return coordinates


func trigger_unit_entered_tile(world_point: Vector2, unit):
	var grid_coordinate = world_to_grid_coordinate(world_point)
	emit_signal("unit_entered_tile", unit, grid_coordinate)


func trigger_unit_exited_tile(world_point: Vector2, unit):
	var grid_coordinate = world_to_grid_coordinate(world_point)
	emit_signal("unit_exited_tile", unit, grid_coordinate)


func _get_neighbor_vectors(point: Vector2, offset_mult = Vector2.ONE) -> PoolVector2Array:
	return PoolVector2Array(
		[
			point + Vector2(0, 1) * offset_mult,
			point + Vector2(1, 1) * offset_mult,
			point + Vector2(1, 0) * offset_mult,
			point + Vector2(-1, 0) * offset_mult,
			point + Vector2(0, -1) * offset_mult,
			point + Vector2(1, -1) * offset_mult,
			point + Vector2(-1, 1) * offset_mult,
			point + Vector2(-1, -1) * offset_mult,
		]
	)
