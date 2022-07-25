extends State

class_name HeroGroupPhase

var heroes: Array
var _have_finished_turn: Array
var _current_hero: Unit


func _init(sm: StateMachine, units: Array).(sm, "HeroGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")
	heroes = units
	_have_finished_turn = []
	GUIManager.get_hero_gui().set_hero_list(heroes)


func enter_state():
	.enter_state()
	print("Hero group turn started!")
	_start_hero_turn(_select_next_hero())


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "HeroEndPhase":
		_have_finished_turn.append(_current_hero)

		if _have_finished_turn.size() == heroes.size():
			_change_state(OverlordPhase.new(_parent))
		else:
			_start_hero_turn(_select_next_hero())


var counter := -1


func _select_next_hero():
	counter += 1
	return heroes[counter]


func _start_hero_turn(hero: Unit):
	_current_hero = hero
	_state_machine.change_state(HeroStartPhase.new(_state_machine, hero))
