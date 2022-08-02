extends State

class_name MonsterStartPhase

var monster


func _init(sm: StateMachine, unit: Unit).(sm, "MonsterStartPhase"):
	monster = unit


func enter_state():
	.enter_state()
	monster.toggle_highlight(true, Color.white)
	GUIManager.get_avatar_selection_gui().set_current_unit(monster)
	_change_state(MonsterActionPhase.new(_parent, monster))
