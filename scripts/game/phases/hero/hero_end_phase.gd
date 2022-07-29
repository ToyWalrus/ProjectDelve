extends State

class_name HeroEndPhase


func _init(sm: StateMachine).(sm, "HeroEndPhase"):
	pass


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui().set_current_unit(null)
	print("Hero end phase")
