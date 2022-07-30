extends State

class_name HeroEndPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroEndPhase"):
	hero = unit


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui().set_current_unit(null)
	hero.toggle_highlight(false)
