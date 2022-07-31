extends State

class_name HeroGroupPhase

var heroes: Array
var _have_finished_turn: Array
var _current_hero: Unit
var _turn_gui


func _init(sm: StateMachine, units: Array).(sm, "HeroGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")
	heroes = units
	_have_finished_turn = []
	_turn_gui = GUIManager.get_unit_turn_gui()
	_turn_gui.set_avatar_list(heroes)


func enter_state():
	.enter_state()
	_select_next_hero()


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "HeroEndPhase":
		_have_finished_turn.append(_current_hero)

		if _have_finished_turn.size() == heroes.size():
			_change_state(OverlordStartPhase.new(_parent))
		else:
			_select_next_hero()


func _select_next_hero():
	_turn_gui.set_header_text("Select hero...")
	Utils.connect_signal(_turn_gui, "avatar_clicked", self, "_start_hero_turn", [], CONNECT_ONESHOT)
	_turn_gui.grayscale_avatars(_have_finished_turn)
	_turn_gui.enable_avatar_selection(_have_finished_turn)


func _start_hero_turn(hero: Unit):
	_current_hero = hero
	_turn_gui.disable_avatar_selection()
	_state_machine.change_state(HeroStartPhase.new(_state_machine, hero))
