extends State

class_name OverlordStartPhase


func _init(sm: StateMachine):
	super(sm, "OverlordStartPhase")
	pass


func enter_state():
	super.enter_state()
	_change_state(OverlordDrawPhase.new(_parent))
