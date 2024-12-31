extends State

class_name HeroEquipPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit):
	super(sm, "HeroEquipPhase")
	hero = unit


func enter_state():
	super.enter_state()
	_change_state(HeroActionPhase.new(_parent, hero))
