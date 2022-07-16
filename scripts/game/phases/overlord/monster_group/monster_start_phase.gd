extends State

class_name MonsterStartPhase


func _init(sm: StateMachine).(sm, "MonsterStartPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered monster start phase - changing to Monster action phase")
	call_deferred("_change_state", MonsterActionPhase.new(_parent))
