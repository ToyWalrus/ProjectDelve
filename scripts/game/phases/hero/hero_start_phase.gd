extends State

class_name HeroStartPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroStartPhase"):
	hero = unit


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui().set_current_unit(hero)
	hero.toggle_highlight(true, Color.white)
	_change_state(HeroEquipPhase.new(_parent, hero))
