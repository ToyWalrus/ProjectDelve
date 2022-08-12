extends Node

var _active_dungeon
var _tile_size := 1.0


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon
	if dungeon:
		_tile_size = dungeon.floors.cell_size
  else:
    _tile_size = 1.0


func get_units_within_radius(origin: Vector2, radius: int, unit_group = "units"):
  var units = get_tree().get_nodes_in_group(unit_group)
  var within_radius = []
  for unit in units:
    if origin.distance_to(unit.position) <= radius * _tile_size:
      within_radius.append(unit)
  return within_radius

func has_empty_space_next_to(origin: Vector2):
  return true