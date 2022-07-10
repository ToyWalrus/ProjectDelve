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

# Emits with parameters: event, world_point, pathfinder
signal grid_tile_clicked

# Emits with parameters: event, world_point, pathfinder
signal grid_tile_hovered


func _ready():
	_pathfinder.set_obstacles(obstacles.get_used_cells(), false)
	_pathfinder.set_weighted_tiles(water.get_used_cells(), water_weight, false)
	_pathfinder.set_weighted_tiles(lava.get_used_cells(), lava_weight, false)
	_pathfinder.set_weighted_tiles(pits.get_used_cells(), pit_weight, false)
	_pathfinder.set_tilemap(floors)
	_line_of_sight.set_tile_size(floors.cell_size)
	UnitActions.set_active_dungeon(self)


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		emit_signal("grid_tile_clicked", event, cam.screen_to_world_point(event.position), _pathfinder)
		_set_debug_positions(event)
	elif event.is_class("InputEventMouseMotion"):
		emit_signal("grid_tile_hovered", event, cam.screen_to_world_point(event.position), _pathfinder)


func has_line_of_sight_to(from_world_point, to_world_point):
	return _line_of_sight.can_see(
		_convert_to_top_left_tile_point(from_world_point), 
		_convert_to_top_left_tile_point(to_world_point)
	)


func draw_path(path: PoolVector2Array, color = Color.transparent, thickness = 0):
	_dungeon_drawer.draw_path(path, color, thickness)


func draw_target(from_world_point: Vector2, to_world_point: Vector2, has_line_of_sight: bool):
	var half_tile = floors.cell_size / 2
	_dungeon_drawer.draw_target(
		_convert_to_top_left_tile_point(from_world_point) + half_tile, 
		_convert_to_top_left_tile_point(to_world_point) + half_tile,
		Color.green if has_line_of_sight else Color.red
	)


func clear_drawings():
	_dungeon_drawer.clear()


func _convert_to_top_left_tile_point(world_point: Vector2):
	return floors.map_to_world(floors.world_to_map(world_point))


var _pos1
var _pos2


func _set_debug_positions(event):
	if not _pos1:
		_pos1 = cam.screen_to_world_point(event.position)
	else:
		_pos2 = cam.screen_to_world_point(event.position)
