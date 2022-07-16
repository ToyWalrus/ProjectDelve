extends State

class_name OverlordPhase


func _init(sm: StateMachine).(sm, "OverlordPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")


func enter_state():
	.enter_state()
	print("Overlord turn started!")
	_state_machine.change_state(OverlordDrawPhase.new(_state_machine))


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "OverlordEndPhase":
		print("Overlord turn ended")
