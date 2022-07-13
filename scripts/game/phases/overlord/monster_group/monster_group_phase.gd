extends State

signal monster_group_completed

class_name MonsterGroupPhase


func _init(sm: StateMachine).(sm, "MonsterGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")


func enter_state():
	.enter_state()
	print("Monster Group turn started!")
	_state_machine.change_state(MonsterStartPhase.new(_state_machine))


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "MonsterEndPhase":
		print("Monster Group turn ended")
		# TODO: Check if any other monsters still need to take their turn
		emit_signal("monster_group_completed")
