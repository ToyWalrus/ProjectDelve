extends StateMachine

class_name PhaseManager


func start_hero_turn():
	print("Phase manager: starting hero group phase")
	change_state(HeroGroupPhase.new(self))
