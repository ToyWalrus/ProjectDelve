extends State

class_name HeroEquipPhase

var hero: Unit


func _init(sm: StateMachine, unit: Unit).(sm, "HeroEquipPhase"):
	hero = unit


func enter_state():
	.enter_state()
	print("Entered hero equip phase - changing to action phase")
	_change_state(HeroActionPhase.new(_parent, hero))
