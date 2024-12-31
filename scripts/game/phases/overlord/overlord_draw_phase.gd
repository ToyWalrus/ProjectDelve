extends State

class_name OverlordDrawPhase


func _init(sm):
	super(sm, "OverlordDrawPhase")
	pass


func enter_state():
	super.enter_state()
	_change_state(OverlordMonsterPhase.new(_parent))
