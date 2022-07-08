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
onready var _pathdrawer = $PathDrawer
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
	var origin_map_point = floors.world_to_map(from_world_point)
	var target_map_point = floors.world_to_map(to_world_point)
	return _line_of_sight.can_see(
		floors.map_to_world(origin_map_point), floors.map_to_world(target_map_point)
	)


func draw_path(path: PoolVector2Array, color = Color.transparent, thickness = 0):
	_pathdrawer.draw_path(path, color, thickness)


func erase_path():
	_pathdrawer.erase_path()
