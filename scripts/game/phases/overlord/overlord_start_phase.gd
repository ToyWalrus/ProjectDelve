extends State

class_name OverlordStartPhase


func _init(sm: StateMachine).(sm, "OverlordStartPhase"):
	pass


func enter_state():
	.enter_state()
	print("Overlord turn started!")
	_change_state(OverlordDrawPhase.new(_state_machine))
