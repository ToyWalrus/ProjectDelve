extends State

class_name HeroEquipPhase


func _init(sm).(sm, "HeroEquipPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered hero equip phase - changing to action phase")
	_change_state(HeroActionPhase.new(_parent))
