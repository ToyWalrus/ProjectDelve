extends StateMachine

class_name PhaseManager


func start_hero_turn():
	GUIManager.get_monster_selection_gui().set_visible(false)
	print("Phase manager: starting hero group phase")
	change_state(HeroGroupPhase.new(self, get_tree().get_nodes_in_group("heroes")))


func finish_round():
	print("Round ended!")
	start_hero_turn()
