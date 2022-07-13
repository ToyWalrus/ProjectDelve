extends State

class_name HeroStartPhase


func _init(sm: PhaseManager).(sm, "HeroStartPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered hero start phase - changing to equip phase")
	_change_state(HeroEquipPhase.new(_parent))
