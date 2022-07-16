extends State

class_name HeroEquipPhase


func _init(sm: StateMachine).(sm, "HeroEquipPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered hero equip phase - changing to action phase")
	call_deferred("_change_state", HeroActionPhase.new(_parent))
