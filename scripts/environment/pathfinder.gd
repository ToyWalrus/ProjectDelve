extends Node2D

# Based on the script https://github.com/GDQuest/godot-demos/blob/master/2018/03-30-astar-pathfinding/pathfind_astar.gd
class_name Pathfinder

onready var _a_star = GridAStar.new()

# A Dictionary of int -> PoolVector2Array
var _weighted_tiles = {}
var _obstacles: PoolVector2Array

var _tilemap: TileMap
var _bounds: Rect2
var _initialized := false
var _dirty := false


func set_obstacles(obstacles: PoolVector2Array, update_map = true):
	_obstacles = obstacles
	_dirty = true

	if update_map:
		_update_map()


func set_weighted_tiles(tiles: PoolVector2Array, weight: int, update_map = true):
	if _weighted_tiles.has(weight):
		_weighted_tiles[weight].append_array(tiles)
	else:
		_weighted_tiles[weight] = tiles
	_dirty = true

	if update_map:
		_update_map()


func set_tilemap(tm: TileMap):
	_tilemap = tm
	_bounds = tm.get_used_rect()
	_update_map()


func _update_map():
	_a_star.clear()
	_initialized = false
	_connect_traversable_cells(_add_traversable_cells())
	_dirty = false
	_initialized = true


# Returns the total cost to move from start to end.
# Shorthand for cost_of_path(get_id_path(start, end))
func get_path_cost(start: Vector2, end: Vector2, include_start_position = false) -> int:
	var id_path = get_id_path(start, end)
	return cost_of_path(id_path, include_start_position)


# Shorthand for get_point_path_from_ids(get_id_path(start, end))
func get_point_path(start: Vector2, end: Vector2, in_world_coordinates = true):
	var id_path = get_id_path(start, end)
	return get_point_path_from_ids(id_path, in_world_coordinates)


# Returns the point ids of a viable path from start to end
func get_id_path(start: Vector2, end: Vector2):
	if not _initialized:
		printerr("The tilemap has not yet been set!")
		return -1
	if _dirty:
		print_debug("The tilemap has been updated since last calculated")

	start = convert_to_map_point(start)
	end = convert_to_map_point(end)

	var start_point_index = _get_point_index(start)
	var end_point_index = _get_point_index(end)
	return _a_star.get_id_path(start_point_index, end_point_index)


# Returns the total cost of the path based on the point weights
func cost_of_path(id_path: PoolIntArray, include_starting_point = false) -> int:
	var cost = 0
	var start_weight = 1

	for idx in range(id_path.size()):
		var weight = _a_star.get_point_weight_scale(id_path[idx])
		if idx == 0:
			start_weight = weight
		cost += weight

	return cost - (0 if include_starting_point else start_weight)


func get_point_path_from_ids(id_path: PoolIntArray, in_world_coordinates = true):
	var path: PoolVector2Array = []

	for point_id in id_path:
		path.append(_a_star.get_point_position(point_id))

	if in_world_coordinates:
		var world_path: PoolVector2Array = []
		var half_cell_size = _tilemap.cell_size / 2
		for point in path:
			# Add the half-cell size to get the center of the cell
			var world_point = _tilemap.map_to_world(point) + half_cell_size
			world_path.append(world_point)
		path = world_path

	return path


func convert_to_map_point(point: Vector2) -> Vector2:
	return _tilemap.world_to_map(point)


func _add_traversable_cells() -> PoolVector2Array:
	var map_size := _bounds.size
	var points: PoolVector2Array = []

	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)

			# An obstacle cell is not traversable
			if point in _obstacles or _tilemap.get_cellv(point) == TileMap.INVALID_CELL:
				continue

			points.append(point)

			# The AStar2D class maps every point to a unique
			# index, hence the need for a _get_point_index function
			var point_index = _get_point_index(point)
			_a_star.add_point(point_index, point, _get_point_weight(point))

	return points


func _connect_traversable_cells(points: PoolVector2Array):
	for point in points:
		var point_index = _get_point_index(point)
		var adjacent = _get_all_adjacent_points(point)

		for neighbor in adjacent:
			var neighbor_point_index = _get_point_index(neighbor)

			# We can skip connecting this neighbor to the current point
			# if the neighbor is not in bounds, or if the neighbor was
			# never registered in the _a_star object
			if _is_outside_bounds(neighbor) or not _a_star.has_point(neighbor_point_index):
				continue

			# Can optionally add a third argument for whether connection
			# is bidirectional
			_a_star.connect_points(point_index, neighbor_point_index)


# This function is essentially just calculating the 1D
# array index of a point in a 2D array
func _get_point_index(point: Vector2):
	return point.y * _bounds.size.x + point.x


func _get_all_adjacent_points(point: Vector2) -> PoolVector2Array:
	return PoolVector2Array(
		[
			point + Vector2.UP,
			point + Vector2.RIGHT,
			point + Vector2.DOWN,
			point + Vector2.LEFT,
			# Include diagonal points
			point + Vector2.UP + Vector2.RIGHT,
			point + Vector2.DOWN + Vector2.RIGHT,
			point + Vector2.DOWN + Vector2.LEFT,
			point + Vector2.UP + Vector2.LEFT
		]
	)


func _is_outside_bounds(point: Vector2) -> bool:
	var size := _bounds.size
	return point.x < 0 or point.y < 0 or point.x >= size.x or point.y >= size.y


func _get_point_weight(point: Vector2):
	for weight in _weighted_tiles.keys():
		var tiles = _weighted_tiles[weight]
		if point in tiles:
			return weight
	return 1


# https://github.com/godotengine/godot/issues/62366#issuecomment-1165785353
class GridAStar:
	extends AStar2D

	func _compute_cost(from_id, to_id):
		var pointA = get_point_position(from_id)
		var pointB = get_point_position(to_id)
		return floor(pointA.distance_to(pointB))
