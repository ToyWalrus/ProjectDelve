extends State

class_name HeroStartPhase


func _init(sm: StateMachine).(sm, "HeroStartPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered hero start phase - changing to equip phase")
	call_deferred("_change_state", HeroEquipPhase.new(_parent))
