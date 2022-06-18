extends Node2D

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

var _active_character: CharacterController


func _ready():
	_pathfinder.set_obstacles(obstacles.get_used_cells(), false)
	_pathfinder.set_weighted_tiles(water.get_used_cells(), water_weight, false)
	_pathfinder.set_weighted_tiles(lava.get_used_cells(), lava_weight, false)
	_pathfinder.set_weighted_tiles(pits.get_used_cells(), pit_weight, false)
	_pathfinder.set_tilemap(floors)


func set_active_character(character: CharacterController):
	_active_character = character


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		_on_grid_click(event)


func _on_grid_click(event):
	if _active_character:
		_active_character.move_to(event.position)
