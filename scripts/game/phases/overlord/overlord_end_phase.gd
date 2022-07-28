extends State

class_name OverlordEndPhase


func _init(sm: StateMachine).(sm, "OverlordEndPhase"):
	pass


func enter_state():
	.enter_state()
	print(_parent)
	_parent.finish_round()
