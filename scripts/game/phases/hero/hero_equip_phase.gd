extends State

class_name HeroEquipPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroEquipPhase"):
	hero = unit


func enter_state():
	.enter_state()
	_change_state(HeroActionPhase.new(_parent, hero))
