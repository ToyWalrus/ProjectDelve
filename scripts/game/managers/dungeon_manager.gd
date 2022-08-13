extends Node

var _active_dungeon
var _tile_size := 1.0


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon
	if dungeon:
		_tile_size = dungeon.floors.cell_size
	else:
		_tile_size = 1.0


func get_nodes_within_grid_radius(world_point: Vector2, tile_radius: int, node_group = "units"):
	var nodes = get_tree().get_nodes_in_group(node_group)
	var within_radius := []
	for node in nodes:
		if _active_dungeon.tile_distance_to(world_point, node.position) <= tile_radius:
			within_radius.append(node)
	return within_radius


func get_grid_coordinates_of_node(node: Node):
	return _active_dungeon.get_grid_position(node.position)


func get_empty_grid_spaces_adjacent_to(world_point: Vector2, obstacle_groups: PoolStringArray = []):
	var walkable_tiles := []
	for neighbor_point in _get_neighbor_vectors(world_point, Vector2(_tile_size, _tile_size)):
		if _active_dungeon.walkable_tile_exists_at(neighbor_point):
			walkable_tiles.append(_active_dungeon.get_grid_position(neighbor_point))

	if not obstacle_groups or obstacle_groups.size() == 0:
		return walkable_tiles

	for group in obstacle_groups:
		var obstacles = get_grid_coordinates_of_group(group)
		for obstacle in obstacles:
			walkable_tiles.erase(obstacle)

	return walkable_tiles


func get_grid_coordinates_of_group(group: String) -> Dictionary:
	var coordinates := {}
	var nodes = get_tree().get_nodes_in_group(group)

	for node in nodes:
		coordinates[_active_dungeon.get_grid_position(node.position)] = node

	return coordinates


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
