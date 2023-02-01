extends Resource

class_name SurgeAddRange

export(int) var extra_range := 1


func apply_to_wheel(result: WheelSectionData):
	if result.special_points > 0:
		result.special_points -= 1
		result.attack_points += extra_range
		print("Added " + str(extra_range) + " extra range from surge!")
	return result
