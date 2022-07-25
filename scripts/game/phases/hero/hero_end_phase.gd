extends State

class_name HeroEndPhase


func _init(sm: StateMachine).(sm, "HeroEndPhase"):
	pass


func enter_state():
	.enter_state()
	GUIManager.get_hero_gui().set_current_hero(null)
	print("Hero end phase")
