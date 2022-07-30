extends State

class_name MonsterEndPhase

var monster: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "MonsterEndPhase"):
	monster = unit


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui().set_current_unit(null)
	monster.toggle_highlight(false)
