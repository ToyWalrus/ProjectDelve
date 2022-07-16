extends State

class_name OverlordMonsterPhase


func _init(sm: StateMachine).(sm, "OverlordMonsterPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered Overlord monster phase - changing to monster group phase")
	var sub_phase = MonsterGroupPhase.new(_state_machine)
	sub_phase.connect("monster_group_completed", self, "_monster_group_completed")
	_state_machine.change_state(sub_phase)


func _monster_group_completed():
	print("In monster phase: monster group completed - changing to overlord end phase")
	_change_state(OverlordEndPhase.new(_parent))
