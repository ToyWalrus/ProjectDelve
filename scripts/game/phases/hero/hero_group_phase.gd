extends State

class_name HeroGroupPhase


func _init(sm: StateMachine).(sm, "HeroGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")


func enter_state():
	.enter_state()
	print("Hero group turn started!")
	_state_machine.change_state(HeroStartPhase.new(_state_machine))


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "HeroEndPhase":
		print("Have all heroes been activated?")
		print("Hero group ended")
		# TODO: Check if any heroes still need to take their turn
		_change_state(OverlordPhase.new(_parent))
