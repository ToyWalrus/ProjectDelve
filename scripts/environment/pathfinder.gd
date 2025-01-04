extends Node2D

# Based on the script https://github.com/GDQuest/godot-demos/blob/master/2018/03-30-astar-pathfinding/pathfind_astar.gd
class_name Pathfinder

@onready var _a_star = GridAStar.new()

# A Dictionary of int -> PoolVector2Array
var _weighted_tiles = {}
var _obstacles: PackedVector2Array

var _tilemap: TileMapLayer
var _bounds: Rect2i
var _initialized := false
var _dirty := false


func set_obstacles(obstacles: PackedVector2Array, update_map = true):
	_obstacles = obstacles
	_dirty = true

	if update_map:
		_update_map()


func set_weighted_tiles(tiles: PackedVector2Array, weight: int, update_map = true):
	if _weighted_tiles.has(weight):
		_weighted_tiles[weight].append_array(tiles)
	else:
		_weighted_tiles[weight] = tiles
	_dirty = true

	if update_map:
		_update_map()


func set_tilemap(tm: TileMapLayer):
	_tilemap = tm
	_bounds = tm.get_used_rect()
	_update_map()


func _update_map():
	_a_star.clear()
	_initialized = false
	_connect_traversable_cells(_add_traversable_cells())
	_dirty = false
	_initialized = true


## Returns the total cost to move from start to end. If in_world_coordinates is true, the start and end points are in world coordinates.
## Otherwise they are presumed to be in map tile coordinates.
## Shorthand for `cost_of_path(get_id_path(start, end))`
func get_path_cost(start: Vector2, end: Vector2, in_world_coordinates = true, include_start_position = false) -> int:
	var id_path = get_id_path(start, end, in_world_coordinates)
	return cost_of_path(id_path, include_start_position)


## Returns the  If in_world_coordinates is true, the start and end points are in world coordinates.
## Otherwise they are presumed to be in map tile coordinates.
## Shorthand for `get_point_path_from_ids(get_id_path(start, end))`.
func get_point_path(start: Vector2, end: Vector2, in_world_coordinates = true):
	var id_path = get_id_path(start, end, in_world_coordinates)
	return get_point_path_from_ids(id_path, in_world_coordinates)


## Returns the point ids of a viable path from start to end. If in_world_coordinates is true, the start and end points are in world coordinates.
## Otherwise they are presumed to be in map tile coordinates.
func get_id_path(start: Vector2, end: Vector2, in_world_coordinates = true):
	if not _initialized:
		printerr("The tilemap has not yet been set!")
		return -1
	if _dirty:
		print_debug("The tilemap has been updated since last calculated")

	if in_world_coordinates:
		start = convert_to_map_point(start)
		end = convert_to_map_point(end)

	var start_point_index = _get_point_index(start)
	var end_point_index = _get_point_index(end)
	return _a_star.get_id_path(start_point_index, end_point_index)


## Returns the total cost of the path based on the point weights
func cost_of_path(id_path: PackedInt64Array, include_starting_point = false) -> int:
	var cost = 0
	var start_weight = 1

	for idx in range(id_path.size()):
		var weight = _a_star.get_point_weight_scale(id_path[idx])
		if idx == 0:
			start_weight = weight
		cost += weight

	return cost - (0 if include_starting_point else start_weight)


func get_point_path_from_ids(id_path: PackedInt64Array, in_world_coordinates = true):
	var path: PackedVector2Array = []

	for point_id in id_path:
		path.append(_a_star.get_point_position(point_id))

	if in_world_coordinates:
		var world_path: PackedVector2Array = []
		var half_cell_size = _tilemap.tile_set.tile_size / 2.0
		for point in path:
			# Add the half-cell size to get the center of the cell
			var local_point = convert_to_world_point(point)  # + half_cell_size
			world_path.append(local_point)
		path = world_path

	return path


func convert_to_map_point(world_point: Vector2) -> Vector2i:
	return _tilemap.local_to_map(_tilemap.to_local(world_point))


func convert_to_world_point(map_point: Vector2i) -> Vector2:
	return _tilemap.map_to_local(map_point)


func _add_traversable_cells() -> PackedVector2Array:
	var map_position := _bounds.position
	var map_size := _bounds.size
	var points: PackedVector2Array = []

	for y in range(map_position.y, map_position.y + map_size.y):
		for x in range(map_position.x, map_position.x + map_size.x):
			var point = Vector2(x, y)

			# An obstacle cell is not traversable
			if point in _obstacles or _tilemap.get_cell_source_id(point) == -1:
				continue

			points.append(point)

			# The AStar2D class maps every point to a unique
			# index, hence the need for a _get_point_index function
			var point_index = _get_point_index(point)
			_a_star.add_point(point_index, point, _get_point_weight(point))

	return points


func _connect_traversable_cells(points: PackedVector2Array):
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


func _get_all_adjacent_points(point: Vector2i) -> PackedVector2Array:
	return PackedVector2Array(
		[
			point + Vector2i.UP,
			point + Vector2i.RIGHT,
			point + Vector2i.DOWN,
			point + Vector2i.LEFT,
			# Include diagonal points
			point + Vector2i.UP + Vector2i.RIGHT,
			point + Vector2i.DOWN + Vector2i.RIGHT,
			point + Vector2i.DOWN + Vector2i.LEFT,
			point + Vector2i.UP + Vector2i.LEFT
		]
	)


func _is_outside_bounds(point: Vector2i) -> bool:
	var pos := _bounds.position
	var size := _bounds.size
	return point.x < pos.x or point.y < pos.y or point.x >= pos.x + size.x or point.y >= pos.y + size.y


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
