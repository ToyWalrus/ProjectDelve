extends State

class_name MonsterEndPhase


func _init(sm: StateMachine).(sm, "MonsterEndPhase"):
	pass


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui().set_current_unit(null)
