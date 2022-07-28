extends State

class_name MonsterEndPhase


func _init(sm: StateMachine).(sm, "MonsterEndPhase"):
	pass


func enter_state():
	.enter_state()
	GUIManager.get_hero_gui()._hero_name.visible = false
	print("Entered monster end phase")
