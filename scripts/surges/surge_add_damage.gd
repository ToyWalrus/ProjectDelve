extends Resource

export(int) var extra_damage := 1


func apply_to_wheel(result: WheelSectionData):
	if result.special_points > 0:
		result.special_points -= 1
		result.attack_points += extra_damage
	return result
