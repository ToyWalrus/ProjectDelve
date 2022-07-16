extends State

class_name MonsterActionPhase


func _init(sm: StateMachine).(sm, "MonsterActionPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered monster action phase - changing to Monster end phase")
	call_deferred("_change_state", MonsterEndPhase.new(_parent))
