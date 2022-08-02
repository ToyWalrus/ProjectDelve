extends State

class_name HeroGroupPhase

var heroes: Array
var _have_finished_turn: Array
var _current_hero: Unit
var _avatar_gui


func _init(sm: StateMachine, units: Array).(sm, "HeroGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")
	heroes = units
	_have_finished_turn = []
	_avatar_gui = GUIManager.get_avatar_selection_gui()
	_avatar_gui.set_avatar_list(heroes)


func enter_state():
	.enter_state()
	_avatar_gui.set_visible(true)
	_select_next_hero()


func exit_state():
	_avatar_gui.set_visible(false)
	.exit_state()


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "HeroEndPhase":
		_have_finished_turn.append(_current_hero)

		if _have_finished_turn.size() == heroes.size():
			_change_state(OverlordStartPhase.new(_parent))
		else:
			_select_next_hero()


func _select_next_hero():
	_avatar_gui.set_header_text("Select hero...")
	Utils.connect_signal(_avatar_gui, "avatar_clicked", self, "_start_hero_turn", [], CONNECT_ONESHOT)
	_avatar_gui.grayscale_avatars(_have_finished_turn)
	_avatar_gui.enable_avatar_selection(_have_finished_turn)


func _start_hero_turn(hero: Unit):
	_current_hero = hero
	_avatar_gui.disable_avatar_selection()
	_state_machine.change_state(HeroStartPhase.new(_state_machine, hero))
