extends Node2D

class_name Dungeon

onready var cam: DungeonCamera = $DungeonCamera

export(int) var water_weight = 2
export(int) var lava_weight = 3
export(int) var pit_weight = 4

# Base tilemap
onready var floors = $Floors
onready var obstacles = $Obstacles
onready var water = $Water
onready var lava = $Lava
onready var pits = $Pits
onready var _pathfinder = $Pathfinder
onready var _dungeon_drawer = $DungeonDrawer
onready var _line_of_sight = $LineOfSight

signal grid_tile_clicked(event, world_point, pathfinder)
signal grid_tile_hovered(event, world_point, pathfinder)


func _ready():
	_pathfinder.set_obstacles(obstacles.get_used_cells(), false)
	_pathfinder.set_weighted_tiles(water.get_used_cells(), water_weight, false)
	_pathfinder.set_weighted_tiles(lava.get_used_cells(), lava_weight, false)
	_pathfinder.set_weighted_tiles(pits.get_used_cells(), pit_weight, false)
	_pathfinder.set_tilemap(floors)
	_line_of_sight.set_tile_size(floors.cell_size)
	DungeonManager.set_active_dungeon(self)
	SelectionManager.set_active_dungeon(self)
	UnitActions.set_active_dungeon(self)
	DrawManager.set_active_dungeon(self)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("grid_tile_clicked", null, null, null)


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		emit_signal("grid_tile_clicked", event, screen_to_world_point(event.position), _pathfinder)
		_set_debug_positions(event)
	elif event.is_class("InputEventMouseMotion"):
		emit_signal("grid_tile_hovered", event, screen_to_world_point(event.position), _pathfinder)


func screen_to_world_point(point: Vector2) -> Vector2:
	return cam.screen_to_world_point(point)


func map_to_world_point(map_point: Vector2, with_offset := false) -> Vector2:
	return floors.map_to_world(map_point) + (floors.cell_size / 2 if with_offset else Vector2.ZERO)


func has_line_of_sight_to(from_world_point: Vector2, to_world_point: Vector2) -> bool:
	return _line_of_sight.can_see(
		_convert_to_top_left_tile_point(from_world_point), _convert_to_top_left_tile_point(to_world_point)
	)


func space_is_occupied_by_unit(world_point: Vector2, group = "units"):
	var units = get_tree().get_nodes_in_group(group)
	var target_tile = get_grid_position(world_point)
	for unit in units:
		if get_grid_position(unit.position) == target_tile:
			return true
	return false


func walkable_tile_exists_at(world_point: Vector2):
	var grid_pos = get_grid_position(world_point)
	return floors.get_cellv(grid_pos) != TileMap.INVALID_CELL and obstacles.get_cellv(grid_pos) == TileMap.INVALID_CELL


func get_grid_position(world_point: Vector2) -> Vector2:
	return _pathfinder.convert_to_map_point(world_point)


# https://www.redblobgames.com/grids/line-drawing.html#snap-to-grid
func tile_distance_to(from_world_point: Vector2, to_world_point: Vector2):
	# Diagonal distance
	var from_tile = get_grid_position(from_world_point)
	var to_tile = get_grid_position(to_world_point)
	var dx = abs(to_tile.x - from_tile.x)
	var dy = abs(to_tile.y - from_tile.y)
	return [int(dx), int(dy)].max()


# TODO: move draw_x functions to DungeonManager
func draw_path(path: PoolVector2Array, color = Color.transparent, thickness = 0):
	_dungeon_drawer.draw_path(path, color, thickness)


func draw_target(
	from_world_point: Vector2,
	to_world_point: Vector2,
	has_line_of_sight: bool,
	max_range := 10000,
	needs_line_of_sight := true
):
	var half_tile = floors.cell_size / 2
	var in_range = tile_distance_to(from_world_point, to_world_point) <= max_range
	_dungeon_drawer.draw_target(
		_convert_to_top_left_tile_point(from_world_point) + half_tile,
		_convert_to_top_left_tile_point(to_world_point) + half_tile,
		Color.green if (has_line_of_sight or not needs_line_of_sight) and in_range else Color.red,
		needs_line_of_sight
	)


func draw_tile_highlight(grid_coordinate, color := Color.green):
	_dungeon_drawer.draw_tile_highlight(
		_convert_to_top_left_tile_point(map_to_world_point(grid_coordinate)), color, floors.cell_size.x
	)


func clear_drawings():
	_dungeon_drawer.clear()


func _convert_to_top_left_tile_point(world_point: Vector2):
	return floors.map_to_world(floors.world_to_map(world_point))


var _pos1
var _pos2


func _set_debug_positions(event):
	if not _pos1:
		_pos1 = screen_to_world_point(event.position)
	else:
		_pos2 = screen_to_world_point(event.position)
