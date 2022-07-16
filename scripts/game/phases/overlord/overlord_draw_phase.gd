extends State

class_name OverlordDrawPhase


func _init(sm).(sm, "OverlordDrawPhase"):
	pass


func enter_state():
	.enter_state()
	print("Entered overlord draw phase - changing to overlord monster phase")
	call_deferred("_change_state", OverlordMonsterPhase.new(_parent))
