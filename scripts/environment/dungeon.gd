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

signal grid_tile_clicked
signal grid_tile_hovered


func _ready():
	_pathfinder.set_obstacles(obstacles.get_used_cells(), false)
	_pathfinder.set_weighted_tiles(water.get_used_cells(), water_weight, false)
	_pathfinder.set_weighted_tiles(lava.get_used_cells(), lava_weight, false)
	_pathfinder.set_weighted_tiles(pits.get_used_cells(), pit_weight, false)
	_pathfinder.set_tilemap(floors)
	UnitActions.set_active_dungeon(self)


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		print("grid point: " + str(_pathfinder.convert_to_map_point(cam.screen_to_world_point(event.position))))
		emit_signal("grid_tile_clicked", event, _pathfinder)
	elif event.is_class("InputEventMouseMotion"):
		emit_signal("grid_tile_hovered", event, _pathfinder)


func draw_path(path: PoolVector2Array, color = Color.transparent, thickness = 0):
	_pathdrawer.draw_path(path, color, thickness)


func erase_path():
	_pathdrawer.erase_path()
