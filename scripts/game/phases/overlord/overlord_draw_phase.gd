extends State

class_name OverlordDrawPhase


func _init(sm).(sm, "OverlordDrawPhase"):
	pass


func enter_state():
	.enter_state()
	_change_state(OverlordMonsterPhase.new(_parent))
