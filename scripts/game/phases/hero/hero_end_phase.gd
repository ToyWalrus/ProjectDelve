extends State

class_name HeroEndPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit):
	super(sm, "HeroEndPhase")
	hero = unit


func enter_state():
	super.enter_state()
	GUIManager.get_avatar_selection_gui().set_current_unit(null)
	hero.toggle_highlight(false)
