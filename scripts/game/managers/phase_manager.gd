extends StateMachine

class_name PhaseManager


func start_hero_turn():
	GUIManager.get_avatar_selection_gui().set_visible(false)
	print("Phase manager: starting hero group phase")
	change_state(HeroGroupPhase.new(self, get_tree().get_nodes_in_group("heroes")))


func start_overlord_turn_debug():
	change_state(OverlordStartPhase.new(self))


func finish_round():
	print("Round ended!")
	start_hero_turn()
