extends State

class_name HeroActionPhase


func _init(sm: StateMachine).(sm, "HeroActionPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered hero action phase - changing to end phase")
	call_deferred("_change_state", HeroEndPhase.new(_parent))
