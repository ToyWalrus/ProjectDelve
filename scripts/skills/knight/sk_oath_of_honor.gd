extends Skill

# https://descent2e.fandom.com/wiki/Oath_of_Honor

var _valid_grid_spaces := []


func can_use():
	if not .can_use():
		return false
	return _ensure_valid_grid_spaces()


func use():
	if not _ensure_valid_grid_spaces():
		return

	# Select one of the valid spaces
	SelectionManager.select_grid_tile(_valid_grid_spaces)
	var selected_grid_space = yield(SelectionManager, "grid_tile_selected")

	if not selected_grid_space:
		return false

	# If not cancelled...
	# Subtract stamina
	hero.stamina -= skill_def.stamina_cost

	# Move unit to selected space
	hero.position = DungeonManager.grid_to_world_position(selected_grid_space, true)

	# Attack monster adjacent to ally
	# TODO: perform attack...
	print("Attack...")

	return true


func _ensure_valid_grid_spaces():
	if _valid_grid_spaces.size() > 0:
		return true

	_get_valid_grid_spaces()
	return _valid_grid_spaces.size() > 0


func _get_valid_grid_spaces():
	# Get a list of all heroes in range of the skill
	var allies_in_range = DungeonManager.get_nodes_within_grid_radius(hero.position, 3, ["heroes"])
	for ally in allies_in_range:
		# Get a list of the monsters next to the hero in range
		var monsters_next_to_ally = DungeonManager.get_nodes_within_grid_radius(ally.position, 1, ["monsters"])
		if monsters_next_to_ally.size() > 0:
			# Get a list of empty spaces next to ally
			var ally_spaces = DungeonManager.get_empty_grid_spaces_adjacent_to(ally.position, ["units"])

			# Get a list of empty spaces next to monster
			var monster_spaces := []
			for monster in monsters_next_to_ally:
				monster_spaces.append_array(
					DungeonManager.get_empty_grid_spaces_adjacent_to(monster.position, ["units"])
				)

			# Take intersection of the two lists
			var intersection := []
			for grid_space in ally_spaces:
				if monster_spaces.has(grid_space):
					intersection.append(grid_space)

			# Add result of the intersection to _valid_grid_spaces
			_valid_grid_spaces.append_array(intersection)
