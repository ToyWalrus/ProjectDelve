extends Skill

var _current_grid_coordinate

# TODO: will need to find some way to cancel all active interrupt skills
# when hero turn starts


func use():
	hero.stamina -= skill_def.stamina_cost
	_current_grid_coordinate = DungeonManager.world_to_grid_coordinate(hero.position)
	Utils.connect_signal(DungeonManager, "unit_entered_tile", self, "_unit_entered_space")
	print("waiting for trigger condition...")


func _unit_entered_space(unit, grid_coordinate):
	var tile_dist = DungeonManager.tile_distance(_current_grid_coordinate, grid_coordinate)
	if tile_dist <= 1 and unit.get_groups().has("monsters"):
		_interrupt(unit, grid_coordinate)
		Utils.disconnect_signal(DungeonManager, "unit_entered_tile", self, "_unit_entered_space")


func _interrupt(unit, grid_coordinate):
	print(hero.name + " attacks " + unit.name)
	pass
