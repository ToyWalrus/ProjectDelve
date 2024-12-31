extends State

class_name MonsterStartPhase

var monster


func _init(sm: StateMachine, unit: Unit):
	super(sm, "MonsterStartPhase")
	monster = unit


func enter_state():
	super.enter_state()
	monster.toggle_highlight(true, Color.WHITE)
	GUIManager.get_avatar_selection_gui().set_current_unit(monster)
	_change_state(MonsterActionPhase.new(_parent, monster))
