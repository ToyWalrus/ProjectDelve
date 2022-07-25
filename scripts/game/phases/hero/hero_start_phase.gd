extends State

class_name HeroStartPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroStartPhase"):
	hero = unit


func enter_state():
	.enter_state()
	print("Starting hero turn: " + hero.name)
	GUIManager.get_hero_gui().set_current_hero(hero)
	_change_state(HeroEquipPhase.new(_parent, hero))
