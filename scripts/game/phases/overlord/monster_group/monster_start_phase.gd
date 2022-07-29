extends State

class_name MonsterStartPhase

var monster


func _init(sm: StateMachine, unit: Unit).(sm, "MonsterStartPhase"):
	monster = unit


func enter_state():
	.enter_state()
	GUIManager.get_unit_turn_gui()._hero_name.visible = true
	GUIManager.get_unit_turn_gui()._hero_name.text = monster.name
	print("Entered monster start phase - changing to Monster action phase")
	_change_state(MonsterActionPhase.new(_parent, monster))
