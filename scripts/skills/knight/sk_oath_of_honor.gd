extends Skill

# https://descent2e.fandom.com/wiki/Oath_of_Honor

var _valid_options


func can_use():
	if not .can_use():
		return false
	_get_valid_options()
	return _valid_options.size() > 0


func use():
	pass


func _get_valid_options():
	var heroes_in_range = UnitManager.get_units_within_radius(hero.position, 3, "heroes")
	for ally in heroes_in_range:
		if (
			UnitManager.has_empty_space_next_to(ally.position)
			and UnitManager.get_units_within_radius(ally.position, 1, "monsters").size() > 0
		):
			_valid_options.append(ally)
