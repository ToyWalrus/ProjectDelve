extends State

class_name HeroPhase


func _init(sm: StateMachine).(sm, "HeroPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")


func enter_state():
	.enter_state()
	print("Hero turn started!")
	_state_machine.change_state(HeroStartPhase.new(_state_machine))


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "HeroEndPhase":
		print("Hero turn ended")
		# TODO: Check if any heroes still need to take their turn
		_change_state(OverlordPhase.new(_parent))
