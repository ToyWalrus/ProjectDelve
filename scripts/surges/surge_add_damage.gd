extends Resource

class_name SurgeAddDamage

export(int) var extra_damage := 1


func apply_to_wheel(result: WheelSectionData):
	if result.special_points > 0:
		result.special_points -= 1
		result.attack_points += extra_damage
		print("Added " + str(extra_damage) + " extra damage from surge!")
	return result
