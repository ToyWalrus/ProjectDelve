extends State

class_name HeroStartPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroStartPhase"):
	hero = unit


func enter_state():
	.enter_state()
	print("Starting hero turn: " + hero.name)
	_change_state(HeroEquipPhase.new(_parent, hero))
