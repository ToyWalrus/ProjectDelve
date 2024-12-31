extends State

class_name OverlordEndPhase


func _init(sm: StateMachine):
	super(sm, "OverlordEndPhase")
	pass


func enter_state():
	super.enter_state()
	_parent.finish_round()
